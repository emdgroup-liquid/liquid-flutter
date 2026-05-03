import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// An input field
class LdInput extends StatefulWidget {
  final String? label;
  final String hint;
  final Function(String)? onChanged;
  final Function(String)? onBlurred;
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

  final Widget? trailingHint;

  final int? maxLines;
  final int? minLines;

  const LdInput({
    required this.hint,
    this.controller,
    this.trailing,
    this.label,
    this.obscureText = false,
    this.leading,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.showClear = false,
    this.size = LdSize.m,
    this.allowTapOutside = true,
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

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final contentPadding = theme.pad() -
        EdgeInsets.all(theme.borderWidth) -
        (widget.showClear ? EdgeInsets.only(top: 4, bottom: 4) : EdgeInsets.zero);

    final cursorHeight = theme.labelSize(widget.size);

    var hintStyle = TextStyle(
      color: theme.textMuted,
      package: theme.fontFamilyPackage,
      fontFamily: theme.fontFamily,
      fontSize: theme.labelSize(widget.size),
      height: 1,
    );

    var clearButton = widget.showClear
        ? LdButton.vague(
            size: widget.size == LdSize.l ? LdSize.s : LdSize.xs,
            onPressed: () {
              _controller.clear();
              widget.onCleared?.call();
            },
            child: const Icon(LucideIcons.x))
        : null;

    final suffix = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: switch (_controller.text.isEmpty && widget.trailingHint != null) {
        true => DefaultTextStyle(style: hintStyle, child: widget.trailingHint!),
        false => widget.trailing ?? clearButton,
      },
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LdFormLabel(
            label: widget.label,
            size: widget.size,
            disabled: widget.disabled,
          ),
          CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  _focusScopeNode.unfocus();
                },
              },
              child: LdTouchableSurface(
                allowTapOutside: widget.allowTapOutside,
                mode: LdTouchableSurfaceMode.input,
                isInput: true,
                focusNode: _focusScopeNode,
                onPressed: () {
                  _focusNode.requestFocus();
                },
                active: _focusScopeNode.hasFocus,
                disabled: widget.disabled,
                builder: (context, colors, status, _) => Container(
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
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: cursorHeight,
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
                                  enabled: !widget.disabled,
                                  controller: _controller,
                                  cursorColor: theme.palette.primary.idle(
                                    theme.isDark,
                                  ),
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
                                    suffix: suffix,
                                  ),
                                  obscureText: widget.obscureText,
                                  autofocus: widget.autofocus,
                                  textInputAction: widget.textInputAction,
                                  scrollPadding: theme.pad(),
                                  onSubmitted: widget.onSubmitted,
                                  cursorWidth: 1,
                                  style: TextStyle(
                                    color: colors.text,
                                    package: theme.fontFamilyPackage,
                                    fontFamily: theme.fontFamily,
                                    fontSize: theme.labelSize(widget.size),
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
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
                ),
              )),
        ],
      ),
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
          Flexible(child: Text(key)),
        ],
      ),
    );
  }
}
