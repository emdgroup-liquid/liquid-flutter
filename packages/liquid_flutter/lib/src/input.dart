import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// An input field
class LdInput extends StatefulWidget {
  final String? label;
  final String hint;
  final Function(String)? onChanged;
  final Function(String)? onBlurred;

  /// Called when the user submits the field (e.g. soft keyboard action).
  ///
  /// On desktop, multiline inputs (`maxLines` null or greater than 1) treat
  /// Enter as submit and Shift+Enter as a new line.
  final Function(String)? onSubmitted;
  final Function()? onCleared;
  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool autofocus;
  final Widget? trailing;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final LdSize size;
  final bool valid;
  final bool showClear;
  final bool disabled;
  final bool loading;
  final Widget? leading;
  final bool allowTapOutside;
  final bool selectAllOnFocus;

  final Widget? trailingHint;

  final EdgeInsets? padding;

  final int? maxLines;
  final int? minLines;

  /// When set, paste (keyboard and context menu) tries this first. Return true
  /// when paste was handled (e.g. image attachment). Otherwise plain text is pasted.
  final Future<bool> Function()? onCustomPaste;

  const LdInput({
    required this.hint,
    this.controller,
    this.trailing,
    this.label,
    this.obscureText = false,
    this.leading,
    this.selectAllOnFocus = false,
    this.maxLines = 1,
    this.minLines,
    this.padding,
    this.autofocus = false,
    this.showClear = false,
    this.size = LdSize.m,
    this.allowTapOutside = false,
    this.onBlurred,
    this.valid = true,
    this.loading = false,
    this.focusNode,
    this.autofillHints,
    this.disabled = false,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
    this.onChanged,
    this.trailingHint,
    this.onCleared,
    this.onCustomPaste,
    super.key,
  });

  @override
  State<LdInput> createState() => _LdInputState();
}

class _LdInputState extends State<LdInput> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  late final FocusNode _focusNode;
  bool _createdFocusNode = false;

  late final TextEditingController _controller;
  bool _createdController = false;

  @override
  void initState() {
    _createdController = widget.controller == null;

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _createdFocusNode = widget.focusNode == null;
    _focusScopeNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusScopeNode.removeListener(_onFocusChange);
    _focusScopeNode.dispose();
    _controller.removeListener(_onTextChange);
    if (_createdFocusNode) {
      _focusNode.dispose();
    }
    if (_createdController) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onPasteShortcut() {
    _runCustomPaste();
  }

  void _submitFromKeyboard() {
    widget.onSubmitted?.call(_controller.text);
  }

  void _insertNewline() {
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : _controller.text.length;
    final end = selection.isValid ? selection.end : _controller.text.length;
    final newText = _controller.text.replaceRange(start, end, '\n');
    _controller.value = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
      composing: TextRange.empty,
    );
  }

  bool get _isMultiline => widget.maxLines == null || widget.maxLines! > 1;

  bool _shouldSubmitOnEnter(BuildContext context) {
    return _isMultiline && widget.onSubmitted != null && !widget.disabled && LdTheme.of(context).platform.isDesktop;
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): () {
        _focusScopeNode.unfocus();
      },
    };
    if (widget.onCustomPaste != null) {
      bindings[const SingleActivator(LogicalKeyboardKey.keyV, control: true)] = _onPasteShortcut;
      bindings[const SingleActivator(LogicalKeyboardKey.keyV, meta: true)] = _onPasteShortcut;
    }
    if (_shouldSubmitOnEnter(context)) {
      bindings[const SingleActivator(LogicalKeyboardKey.enter)] = _submitFromKeyboard;
      bindings[const SingleActivator(LogicalKeyboardKey.numpadEnter)] = _submitFromKeyboard;
      bindings[const SingleActivator(LogicalKeyboardKey.enter, shift: true)] = _insertNewline;
      bindings[const SingleActivator(LogicalKeyboardKey.numpadEnter, shift: true)] = _insertNewline;
    }
    return bindings;
  }

  Future<void> _runCustomPaste() async {
    final onCustomPaste = widget.onCustomPaste;
    if (onCustomPaste == null) {
      return;
    }
    final handled = await onCustomPaste();
    if (!handled && mounted) {
      await _pastePlainTextFallback();
    }
  }

  Future<void> _pastePlainTextFallback() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboard?.text;
    if (text == null || text.isEmpty) {
      return;
    }
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : _controller.text.length;
    final end = selection.end >= 0 ? selection.end : _controller.text.length;
    final newText = _controller.text.replaceRange(start, end, text);
    _controller.value = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
      composing: TextRange.empty,
    );
  }

  void _onTextChange() {
    widget.onChanged?.call(_controller.text);
    setState(() {});
  }

  void _onFocusChange() {
    if (!_focusScopeNode.hasFocus) {
      widget.onBlurred?.call(widget.controller?.text ?? '');
    }

    setState(() {});
  }

  Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (SystemContextMenu.isSupportedByField(editableTextState)) {
      return SystemContextMenu.editableText(editableTextState: editableTextState);
    }
    return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
  }

  Widget _buildContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final buttonItems = editableTextState.contextMenuButtonItems.map((item) {
      if (item.type != ContextMenuButtonType.paste) {
        return item;
      }
      return ContextMenuButtonItem(
        label: item.label,
        onPressed: () {
          _runCustomPaste();
        },
      );
    }).toList();
    return AdaptiveTextSelectionToolbar.buttonItems(
      buttonItems: buttonItems,
      anchors: editableTextState.contextMenuAnchors,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final contentPadding = widget.padding ?? EdgeInsets.zero;

    final labelStyle = ldBuildTextStyle(theme, LdTextType.label, widget.size);
    final hintStyle = labelStyle.copyWith(color: theme.textMuted);
    final lineBoxHeight = labelStyle.fontSize! * labelStyle.height!;
    final cursorHeight = lineBoxHeight;
    final fieldPadding = theme.controlContentPadding(widget.size) - EdgeInsets.all(theme.borderWidth);

    var clearButton = widget.showClear && _controller.text.isNotEmpty && !widget.disabled
        ? GestureDetector(
            onTap: () {
              _controller.clear();
              widget.onCleared?.call();
            },
            child: Icon(LucideIcons.x, size: theme.labelSize(widget.size), color: theme.primaryColor))
        : null;

    final suffix = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: switch (_controller.text.isEmpty && widget.trailingHint != null) {
        true => DefaultTextStyle(style: hintStyle, child: widget.trailingHint!),
        false => clearButton,
      },
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            LdText.l(
              widget.label!,
              size: widget.size,
            ),
          CallbackShortcuts(
            bindings: _shortcutBindings(context),
            child: LdTouchableSurface(
              allowTapOutside: widget.allowTapOutside,
              textFieldTapRegion: true,
              focusNode: _focusScopeNode,
              onPressed: () {
                _focusNode.requestFocus();
              },
              active: _focusScopeNode.hasFocus,
              disabled: widget.disabled,
              onPressedKeys: {},
              builder: (context, status, _) => Builder(builder: (context) {
                final colors = inputColor(theme, status, isValid: widget.valid);
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: theme.radius(LdSize.s),
                    border: Border.all(
                      color: colors.border,
                      width: theme.borderWidth,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: contentPadding,
                        child: Padding(
                          padding: fieldPadding,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: lineBoxHeight,
                            ),
                            child: Row(
                              children: [
                                if (widget.leading != null) ...[
                                  IconTheme(
                                    data: IconThemeData(
                                      color: colors.icon,
                                      size: theme.labelSize(widget.size),
                                    ),
                                    child: widget.leading!,
                                  ),
                                  ldSpacerS
                                ],
                                Flexible(
                                  child: TextField(
                                    focusNode: _focusNode,
                                    contextMenuBuilder:
                                        widget.onCustomPaste == null ? _defaultContextMenuBuilder : _buildContextMenu,
                                    enabled: !widget.disabled,
                                    controller: _controller,
                                    cursorColor: theme.palette.primary.idle(
                                      theme.isDark,
                                    ),
                                    selectAllOnFocus: widget.selectAllOnFocus,
                                    cursorHeight: cursorHeight,
                                    maxLines: widget.maxLines,
                                    autofillHints: widget.autofillHints,
                                    keyboardType: widget.keyboardType,
                                    enableInteractiveSelection: true,
                                    minLines: widget.minLines,
                                    decoration: InputDecoration(
                                      hintText: widget.hint,
                                      border: InputBorder.none,
                                      hintStyle: hintStyle,
                                      isCollapsed: true,
                                      filled: false,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    obscureText: widget.obscureText,
                                    autofocus: widget.autofocus,
                                    textInputAction: widget.textInputAction,
                                    scrollPadding: theme.pad() * 5,
                                    onSubmitted: widget.onSubmitted,
                                    cursorWidth: 1,
                                    style: labelStyle.copyWith(color: colors.text),
                                  ),
                                ),
                                suffix,
                                if (widget.trailing != null) widget.trailing!,
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.loading)
                        LinearProgressIndicator(
                          minHeight: theme.borderWidth,
                          color: colors.icon,
                          backgroundColor: Colors.transparent,
                        )
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ).spaceS(),
    );
  }
}

class LdShortcutIndicator extends StatelessWidget {
  final SingleActivator shortcut;

  const LdShortcutIndicator({super.key, required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final key = shortcut.trigger.keyLabel;
    final theme = LdTheme.of(context, listen: true);
    return LdTag(
      color: theme.palette.neutral,
      size: LdSize.s,
      child: Row(
        children: [
          if (shortcut.meta)
            const Icon(
              LucideIcons.command,
            ),
          if (shortcut.shift)
            const Icon(
              LucideIcons.arrowBigUp,
            ),
          if (shortcut.alt)
            const Icon(
              LucideIcons.option,
            ),
          if (shortcut.control)
            const Icon(
              LucideIcons.chevronUp,
            ),
          if (shortcut.shift)
            const Icon(
              LucideIcons.arrowBigUp,
            ),
          if (key == "Enter")
            const Icon(
              LucideIcons.cornerDownLeft,
            )
          else if (key == "Escape")
            const Icon(
              LucideIcons.circleArrowOutUpLeft,
            )
          else
            Text(key),
        ],
      ),
    );
  }
}
