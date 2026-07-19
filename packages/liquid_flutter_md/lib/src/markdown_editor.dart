import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/src/markdown_editing_controller.dart';

/// A live WYSIWYG markdown editor in the style of Typora / Obsidian.
///
/// Renders markdown inline as the user types using a [TextField] with
/// [StrutStyle.forceStrutHeight] set to `false`, which allows [WidgetSpan]s
/// (tables, images, HR, blockquote bars, etc.) to size correctly inside
/// [EditableText].
///
/// ## Usage
/// ```dart
/// LdMarkdownEditor(
///   controller: LdMarkdownEditingController(text: '# Hello\n\nWorld'),
///   onLinkTap: (url, title) => launchUrl(Uri.parse(url)),
/// )
/// ```
class LdMarkdownEditor extends StatefulWidget {
  /// The controller that owns the text and drives the WYSIWYG rendering.
  /// If null, an internal controller is created.
  final LdMarkdownEditingController? controller;

  /// Initial text (used only when [controller] is null).
  final String? initialValue;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (e.g. presses the action key on
  /// the keyboard). Only fired when [textInputAction] is set to an action
  /// that triggers submission (e.g. [TextInputAction.done]).
  final ValueChanged<String>? onSubmitted;

  /// Called when the user taps a link.
  final void Function(String url, String title)? onLinkTap;

  /// Called when the user taps a hashtag (e.g. `#flutter`).
  /// `tag` is the text without the `#` prefix.
  final void Function(String tag)? onHashtagTap;

  /// Resolves images; return null to fall back to [Image.network].
  final Widget? Function(String src, String alt)? imageBuilder;

  /// Minimum number of lines to show.
  final int? minLines;

  /// Maximum number of lines before the editor scrolls.
  final int? maxLines;

  /// Hint text shown when the editor is empty.
  final String? hintText;

  /// Focus node.
  final FocusNode? focusNode;

  /// Whether the field is disabled.
  ///
  /// A disabled field does not respond to user input. Defaults to `false`.
  final bool disabled;

  /// Whether the field should be focused automatically when the widget is
  /// inserted into the tree. Defaults to `false`.
  final bool autofocus;

  /// The type of action button to show on the soft keyboard.
  ///
  /// Defaults to [TextInputAction.newline], which inserts a newline on press
  /// and is appropriate for a multiline markdown editor.
  final TextInputAction textInputAction;

  /// Optional input formatters applied to every text change.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to enable autocorrect. Defaults to `false` to avoid mangling
  /// markdown syntax such as `**bold**` or backtick code spans.
  final bool autocorrect;

  /// Whether to show input suggestions (e.g. emoji bar on iOS).
  /// Defaults to `false` to keep the editing experience predictable for
  /// structured markdown content.
  final bool enableSuggestions;

  /// Whether this field should expand to fill its parent.
  ///
  /// When `true`, [maxLines] must be `null` (unbounded). Defaults to `false`.
  final bool expands;

  const LdMarkdownEditor({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onLinkTap,
    this.onHashtagTap,
    this.imageBuilder,
    this.minLines,
    this.maxLines,
    this.hintText,
    this.focusNode,
    this.disabled = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.newline,
    this.inputFormatters,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.expands = false,
  });

  @override
  State<LdMarkdownEditor> createState() => _LdMarkdownEditorState();
}

class _LdMarkdownEditorState extends State<LdMarkdownEditor> {
  late LdMarkdownEditingController _controller;
  bool _ownsController = false;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = LdMarkdownEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.onLinkTap = widget.onLinkTap;
    _controller.onHashtagTap = widget.onHashtagTap;
    _controller.imageBuilder = widget.imageBuilder;

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _focusNode.onKeyEvent = _handleKeyEvent;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(LdMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
      _controller = widget.controller!;
    }
    _controller.onLinkTap = widget.onLinkTap;
    _controller.onHashtagTap = widget.onHashtagTap;
    _controller.imageBuilder = widget.imageBuilder;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    _controller.isEditing = _focusNode.hasFocus;
    setState(() {});
  }

  // -------------------------------------------------------------------------
  // Keyboard shortcuts
  // -------------------------------------------------------------------------

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final ctrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.tab:
        if (shift) {
          _unindent();
        } else {
          _indent();
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyB:
        if (ctrl) {
          _wrapSelection('**', '**');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      case LogicalKeyboardKey.keyI:
        if (ctrl) {
          _wrapSelection('*', '*');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      case LogicalKeyboardKey.keyE:
        if (ctrl) {
          _wrapSelection('`', '`');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      default:
        return KeyEventResult.ignored;
    }
  }

  void _indent() {
    final sel = _controller.selection;
    if (!sel.isValid) return;
    final text = _controller.text;
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);
    _controller.value = TextEditingValue(
      text: '$before  $after',
      selection: TextSelection.collapsed(offset: sel.start + 2),
    );
    widget.onChanged?.call(_controller.text);
  }

  void _unindent() {
    final sel = _controller.selection;
    if (!sel.isValid) return;
    final text = _controller.text;
    final lineStart = text.lastIndexOf('\n', sel.start - 1) + 1;
    final lineContent = text.substring(lineStart);
    int strip = 0;
    if (lineContent.startsWith('  ')) {
      strip = 2;
    } else if (lineContent.startsWith('\t')) {
      strip = 1;
    }
    if (strip == 0) return;
    final before = text.substring(0, lineStart);
    final after = text.substring(lineStart + strip);
    _controller.value = TextEditingValue(
      text: '$before$after',
      selection: TextSelection.collapsed(offset: (sel.start - strip).clamp(lineStart, before.length + after.length)),
    );
    widget.onChanged?.call(_controller.text);
  }

  void _wrapSelection(String open, String close) {
    final sel = _controller.selection;
    if (!sel.isValid) return;
    final text = _controller.text;
    final selected = text.substring(sel.start, sel.end);
    final newText = text.substring(0, sel.start) + open + selected + close + text.substring(sel.end);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: sel.start + open.length,
        extentOffset: sel.start + open.length + selected.length,
      ),
    );
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final textStyle = ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m)
        .copyWith(letterSpacing: 0, wordSpacing: 0);

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: theme.palette.neutral.relative(false, 5)),
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: widget.expands ? null : widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      keyboardType: TextInputType.multiline,
      textInputAction: widget.textInputAction,
      enabled: !widget.disabled,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      style: textStyle,
      strutStyle: StrutStyle(
        forceStrutHeight: false,
      ),
      readOnly: !_focusNode.hasFocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: theme.primaryColor,
      contextMenuBuilder: !widget.disabled
          ? (context, editableTextState) {
              final selection = editableTextState.textEditingValue.selection;
              final baseOffset = selection.baseOffset;

              final url = _controller.linkAtOffset(baseOffset);
              final tag = _controller.hashtagAtOffset(baseOffset);

              final buttons = <ContextMenuButtonItem>[
                ...editableTextState.contextMenuButtonItems,
              ];

              if (url != null && widget.onLinkTap != null) {
                buttons.insert(
                  0,
                  ContextMenuButtonItem(
                    label: 'Open link',
                    onPressed: () => widget.onLinkTap?.call(url, ''),
                  ),
                );
              }
              if (tag != null && widget.onHashtagTap != null) {
                buttons.insert(
                  0,
                  ContextMenuButtonItem(
                    label: 'Search tag',
                    onPressed: () => widget.onHashtagTap?.call(tag),
                  ),
                );
              }

              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: buttons,
                anchors: editableTextState.contextMenuAnchors,
              );
            }
          : null,
    );
  }
}