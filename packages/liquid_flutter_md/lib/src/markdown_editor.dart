import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/src/markdown_editing_controller.dart';

/// A live WYSIWYG markdown editor in the style of Typora / Obsidian.
///
/// Renders markdown inline as the user types. The line containing the cursor
/// is always shown as raw source text; all other lines are rendered with
/// inline markdown styling.
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
    // Force a rebuild so the controller re-renders when focus changes
    // (focused line switches between raw and styled).
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
      // ---- Tab / Shift+Tab — indent / unindent ----
      case LogicalKeyboardKey.tab:
        if (shift) {
          _unindent();
        } else {
          _indent();
        }
        return KeyEventResult.handled;

      // ---- Meta+B — bold ----
      case LogicalKeyboardKey.keyB:
        if (ctrl) {
          _wrapSelection('**', '**');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      // ---- Meta+I — italic ----
      case LogicalKeyboardKey.keyI:
        if (ctrl) {
          _wrapSelection('*', '*');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      // ---- Meta+E — inline code ----
      case LogicalKeyboardKey.keyE:
        if (ctrl) {
          _wrapSelection('`', '`');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      // ---- Enter — smart continuation ----
      case LogicalKeyboardKey.enter:
        if (_handleEnter()) return KeyEventResult.handled;
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

  /// Returns true if Enter was handled (smart list/blockquote continuation).
  bool _handleEnter() {
    final sel = _controller.selection;
    if (!sel.isValid || !sel.isCollapsed) return false;
    final text = _controller.text;
    final lineStart = text.lastIndexOf('\n', sel.start - 1) + 1;
    final line = text.substring(lineStart, sel.start);

    // Do not intercept Enter on horizontal rules (--- / *** / ___).
    if (RegExp(r'^(\*{3,}|-{3,}|_{3,})\s*$').hasMatch(line)) return false;

    // Ordered list continuation.
    final orderedMatch = RegExp(r'^(\s*)(\d+)\.\s').firstMatch(line);
    if (orderedMatch != null) {
      final indent = orderedMatch.group(1)!;
      final num = int.parse(orderedMatch.group(2)!);
      // If line is just the marker with no content, remove it.
      if (line.trim() == '${orderedMatch.group(2)}.') {
        _replaceCurrentLine(lineStart, sel.start, '');
        return true;
      }
      _insertAtCursor('\n$indent${num + 1}. ');
      return true;
    }

    // Unordered list continuation.
    final unorderedMatch = RegExp(r'^(\s*)([-*+]) ').firstMatch(line);
    if (unorderedMatch != null) {
      final indent = unorderedMatch.group(1)!;
      final marker = unorderedMatch.group(2)!;
      if (line.trim() == marker) {
        _replaceCurrentLine(lineStart, sel.start, '');
        return true;
      }
      _insertAtCursor('\n$indent$marker ');
      return true;
    }

    // Blockquote continuation.
    if (line.startsWith('> ')) {
      if (line.trim() == '>') {
        _replaceCurrentLine(lineStart, sel.start, '');
        return true;
      }
      _insertAtCursor('\n> ');
      return true;
    }

    return false;
  }

  void _insertAtCursor(String insert) {
    final sel = _controller.selection;
    final text = _controller.text;
    final newText = text.substring(0, sel.start) + insert + text.substring(sel.end);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + insert.length),
    );
    widget.onChanged?.call(_controller.text);
  }

  void _replaceCurrentLine(int lineStart, int lineEnd, String replacement) {
    final text = _controller.text;
    final newText = text.substring(0, lineStart) + replacement + text.substring(lineEnd);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: lineStart + replacement.length),
    );
    widget.onChanged?.call(_controller.text);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  Widget _buildTextField(BuildContext context, LdTheme theme) {
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
      style: ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m).copyWith(letterSpacing: 0, wordSpacing: 0),
      strutStyle: StrutStyle.fromTextStyle(
        ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m).copyWith(letterSpacing: 0, wordSpacing: 0),
        forceStrutHeight: true,
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    final focused = _focusNode.hasFocus;
    _controller.isEditing = focused;

    // The TextField must always stay mounted so the FocusNode remains attached.
    // When blurred we show a Text.rich driven by the same controller (with
    // isEditing=false so tables render as real WidgetSpans) on top, with a
    // tap overlay to re-focus. Text.rich has no strut so WidgetSpan heights
    // work correctly.
    return Stack(
      children: [
        // Always mounted — keeps FocusNode attached.
        Offstage(
          offstage: !focused,
          child: TapRegion(onTapOutside: (_) => _focusNode.unfocus(), child: _buildTextField(context, theme)),
        ),

        // Shown when blurred: Text.rich from the same controller.
        // Match TextField's text metrics exactly:
        //  - same style (including letterSpacing:0 / wordSpacing:0 to match
        //    EditableText's internal behaviour and prevent layout shift)
        //  - strutStyle derived from that style (same as TextField does internally)
        //  - textHeightBehavior matching EditableText's default
        if ((!focused) && _controller.text.isNotEmpty) ...[
          Text.rich(
            _controller.buildTextSpan(
              context: context,
              style: ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m)
                  .copyWith(letterSpacing: 0, wordSpacing: 0),
              withComposing: false,
            ),
            // EditableText uses forceStrutHeight:true internally (see
            // StrutStyle getter in editable_text.dart), so we match that here.
            // No textHeightBehavior override — EditableText uses the Flutter
            // default (both ascent/descent applied), so omitting it here keeps
            // the two modes identical.
            strutStyle: StrutStyle.fromTextStyle(
              ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m)
                  .copyWith(letterSpacing: 0, wordSpacing: 0),
              forceStrutHeight: true,
            ),
          ),
          if (!widget.disabled)
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _focusNode.requestFocus()),
            ),
        ],
      ],
    );
  }
}