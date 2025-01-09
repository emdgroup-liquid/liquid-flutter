import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/input_color_bundle.dart';

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

  LdTheme get theme => LdTheme.of(context, listen: true);

  double cursorHeight(LdSize size) {
    return theme.labelSize(size);
  }

  EdgeInsets contentPadding(LdSize size) {
    return theme.balPad(size) - EdgeInsets.all(theme.borderWidth);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.showClear == false || widget.controller != null);

    final inputColors = LdInputColorBundle.fromTheme(
      theme,
      onSurface: LdSurfaceInfo.of(context).isSurface,
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
                        padding: contentPadding(widget.size),
                        child: Container(
                            constraints: BoxConstraints(
                              minHeight: theme.labelSize(widget.size),
                            ),
                            child: TextField(
                              focusNode: _focusNode,
                              enabled: !widget.disabled,
                              controller: _controller,
                              cursorColor: theme.palette.primary.idle(
                                theme.isDark,
                              ),
                              cursorHeight: cursorHeight(widget.size),
                              maxLines: widget.maxLines,
                              autofillHints: widget.autofillHints,
                              keyboardType: widget.keyboardType,
                              enableInteractiveSelection: true,
                              minLines: widget.minLines,
                              decoration: InputDecoration(
                                hintText: widget.hint,
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: placeholderColor,
                                  package: theme.fontFamilyPackage,
                                  fontFamily: theme.fontFamily,
                                  fontSize: theme.labelSize(widget.size),
                                  height: 1,
                                ),
                                isCollapsed: true,
                                filled: false,
                                isDense: true,
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
                        minHeight: 3,
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


/*

*/