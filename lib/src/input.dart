import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/input_color_bundle.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// An input field
class LdInput extends StatefulWidget {
  final String? label;
  final String hint;
  final Function(String?)? onChanged;
  final Function(String?)? onBlur;
  final Function(String?)? onSubmitted;
  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final LdSize size;
  final bool valid;
  final bool showClear;
  final bool disabled;
  final bool loading;

  final Widget? trailingHint;

  final int? maxLines;
  final int? minLines;

  const LdInput(
      {required this.hint,
      this.controller,
      this.label,
      this.obscureText = false,
      this.maxLines = 1,
      this.minLines,
      this.autofocus = false,
      this.showClear = false,
      this.size = LdSize.m,
      this.onBlur,
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
      Key? key})
      : super(key: key);

  @override
  State<LdInput> createState() => _LdInputState();
}

class _LdInputState extends State<LdInput> {
  late final FocusNode _focusNode;
  bool _createdFocusNode = false;

  late final TextEditingController _controller;
  bool _createdController = false;

  bool _hovering = false;

  @override
  void initState() {
    _createdFocusNode = widget.focusNode == null;
    _createdController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (_createdController) {
      _controller.dispose();
    }
    if (_createdFocusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _onTextChange() {
    widget.onChanged?.call(_controller.text);
    setState(() {});
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onBlur?.call(widget.controller?.text);
    } else {}

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final contentPadding =
        theme.balPad(widget.size) - EdgeInsets.all(theme.borderWidth);

    final cursorHeight = theme.labelSize(widget.size);

    final inputColors = LdInputColorBundle.fromTheme(
      theme,
      onSurface: LdSurfaceInfo.of(context, listen: true).isSurface,
      isValid: widget.valid,
    );

    late final Color fillColor;
    late final Color borderColor;
    late final Color textColor;
    late final Color placeholderColor;
    late final Color iconColor;

    if (widget.disabled) {
      fillColor = inputColors.backgroundDisabled;
      borderColor = inputColors.borderDisabled;
      textColor = inputColors.textDisabled;
      placeholderColor = inputColors.placeholderDisabled;
      iconColor = inputColors.iconDisabled;
    } else {
      if (_focusNode.hasFocus) {
        fillColor = inputColors.backgroundFocus;
        borderColor = inputColors.borderFocus;
        textColor = inputColors.textFocus;
        placeholderColor = inputColors.placeholderFocus;
        iconColor = inputColors.iconFocus;
      } else if (_hovering) {
        fillColor = inputColors.backgroundHover;
        borderColor = inputColors.borderHover;
        textColor = inputColors.textHover;
        placeholderColor = inputColors.placeholderHover;
        iconColor = inputColors.iconHover;
      } else {
        fillColor = inputColors.backgroundIdle;
        borderColor = inputColors.borderIdle;
        textColor = inputColors.textIdle;
        placeholderColor = inputColors.placeholderIdle;
        iconColor = inputColors.iconIdle;
      }
    }

    var hintStyle = TextStyle(
      color: placeholderColor,
      package: theme.fontFamilyPackage,
      fontFamily: theme.fontFamily,
      fontSize: theme.labelSize(widget.size),
      height: 1,
    );

    Widget? suffix;

    var clearButton = LdButtonVague(
        child: const Icon(LucideIcons.x),
        size: widget.size == LdSize.l ? LdSize.s : LdSize.xs,
        onPressed: () {
          _controller.clear();
        });

    if (widget.trailingHint != null) {
      final trailingHint = DefaultTextStyle(
        style: hintStyle,
        child: widget.trailingHint!,
      );

      if (widget.showClear) {
        suffix = AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _controller.text.isEmpty ? trailingHint : clearButton,
        );
      } else {
        suffix = trailingHint;
      }
    } else if (widget.showClear) {
      suffix = clearButton;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: widget.label,
          size: widget.size,
          disabled: widget.disabled,
        ),
        MouseRegion(
            onEnter: (event) {
              setState(() {
                _hovering = true;
              });
            },
            onExit: (event) {
              setState(() {
                _hovering = false;
              });
            },
            child: GestureDetector(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: theme.radius(LdSize.s),
                  border: Border.all(
                    color: borderColor,
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
                              onSubmitted: widget.onSubmitted,
                              cursorWidth: 1,
                              style: TextStyle(
                                color: textColor,
                                package: theme.fontFamilyPackage,
                                fontFamily: theme.fontFamily,
                                fontSize: theme.labelSize(widget.size),
                                height: 1,
                              ),
                            ))),
                    if (widget.loading)
                      LinearProgressIndicator(
                        minHeight: theme.borderWidth,
                        color: iconColor,
                        backgroundColor: Colors.transparent,
                      )
                  ],
                ),
              ),
            )),
      ],
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
