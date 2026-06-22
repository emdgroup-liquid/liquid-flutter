import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Future<bool> ldConfirmModal(
    {String? description,
    Widget? title,
    Widget? positive,
    Widget? negative,
    Widget? additionalContent,
    LdColor? confirmColor,
    LdColor? cancelColor,
    required BuildContext context,
    LdIndicatorType? indicatorType = LdIndicatorType.warning,
    bool useRootNavigator = false,
    bool allowDismiss = true}) async {
  final locale = LiquidLocalizations.of(context);

  final res = await LdModalRoute<bool>(
      context: context,
      dialogSize: LdSize.s,
      pageBuilder: (context) {
        return LdScaffold(
          body: LdAppBar(
            title: title ?? Text(locale.confirm),
            backgroundMode: LdAppBarBackgroundMode.whenScrolled,
            borderMode: LdAppBarBorderMode.whenScrolled,
            shadowMode: LdAppBarShadowMode.whenScrolled,
            child: LdAppBar(
              attachedMode: LdAppBarAttachedMode.attached,
              positionMode: LdAppBarPositionMode.bottom,
              actions: [
                LdFlexibleChild(
                  child: LdButton.vague(
                    size: LdSize.l,
                    width: double.infinity,
                    color: cancelColor ?? LdTheme.of(context).error,
                    child: negative ?? Text(locale.cancel),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                LdFlexibleChild(
                  child: LdButton.vague(
                    size: LdSize.l,
                    width: double.infinity,
                    color: confirmColor ?? LdTheme.of(context).primary,
                    child: positive ?? Text(locale.confirm),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
              child: LdScaffoldBody(
                minimumPadding: LdTheme.of(context).pad(size: LdSize.l),
                shrinkWrap: true,
                children: [
                  if (indicatorType != null)
                    Center(
                      child: LdIndicator(
                        type: indicatorType,
                        customSize: 24,
                      ).padVertical(size: LdSize.l),
                    ),
                  if (description != null) Center(child: LdText.p(description, textAlign: TextAlign.center)),
                  if (additionalContent != null) additionalContent,
                ],
              ),
            ),
          ),
        );
      }).show(context, useRootNavigator: useRootNavigator);

  return res == true;
}

Future<String?> ldEnterTextModal({
  String? description,
  Widget? title,
  Widget? additionalContent,
  required BuildContext context,
  bool useRootNavigator = false,
  String? initialValue,
  String? inputHint,
  String? inputLabel,
  bool allowEmpty = false,
  bool obscureText = false,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool Function(String input)? validate,
  bool allowDismiss = true,
  bool requireChange = false,
}) async {
  final res = await LdModalRoute<String?>(
      context: context,
      barrierDismissible: allowDismiss,
      dialogSize: LdSize.s,
      pageBuilder: (context) {
        return _LdEnterTextModal(
          description: description,
          title: title,
          additionalContent: additionalContent,
          inputHint: inputHint,
          inputLabel: inputLabel,
          allowDismiss: allowDismiss,
          initialValue: initialValue,
          allowEmpty: allowEmpty,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validate: validate,
          requireChange: requireChange,
        );
      }).show(context, useRootNavigator: useRootNavigator);
  return res;
}

class _LdEnterTextModal extends StatefulWidget {
  final String? description;
  final Widget? title;
  final Widget? additionalContent;
  final String? inputHint;
  final String? inputLabel;
  final String? initialValue;
  final bool allowEmpty;
  final bool allowDismiss;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool Function(String input)? validate;
  final TextInputAction? textInputAction;
  final bool requireChange;

  const _LdEnterTextModal({
    required this.description,
    required this.title,
    required this.additionalContent,
    required this.inputHint,
    required this.inputLabel,
    required this.allowDismiss,
    required this.allowEmpty,
    required this.obscureText,
    required this.keyboardType,
    required this.initialValue,
    required this.validate,
    required this.textInputAction,
    required this.requireChange,
  });

  @override
  State<_LdEnterTextModal> createState() => _LdEnterTextModalState();
}

class _LdEnterTextModalState extends State<_LdEnterTextModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = widget.initialValue ?? "";
    super.initState();
  }

  bool get _didChange => _controller.text != widget.initialValue;

  bool get _canSubmit =>
      (widget.allowEmpty || _controller.text.isNotEmpty) && _isValid && (_didChange || !widget.requireChange);

  void _onSubmitted(String text) {
    if (_canSubmit) {
      Navigator.of(context).pop(text);
    }
  }

  void _onChanged(String text) {
    setState(() {
      _isValid = widget.validate?.call(text) ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar(
        title: widget.title ?? Text(LiquidLocalizations.of(context).enterText),
        child: LdAppBar(
          positionMode: LdAppBarPositionMode.bottom,
          avoidViewInsets: true,
          attachedMode: LdAppBarAttachedMode.attached,
          actions: [
            if (widget.allowDismiss)
              LdFlexibleChild(
                child: LdButton.vague(
                  color: LdTheme.of(context).error,
                  width: double.infinity,
                  size: LdSize.l,
                  child: Text(LiquidLocalizations.of(context).cancel),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
            LdFlexibleChild(
              child: LdButton.filled(
                size: LdSize.l,
                width: double.infinity,
                disabled: !_canSubmit,
                child: Text(LiquidLocalizations.of(context).done),
                onPressed: () => _onSubmitted(_controller.text),
              ),
            ),
          ],
          child: LdScaffoldBody(
            shrinkWrap: true,
            children: [
              LdAutoSpace(children: [
                if (widget.description != null) LdText.p(widget.description!),
                if (widget.additionalContent != null) widget.additionalContent!,
                LdInput(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: widget.keyboardType,
                  onChanged: _onChanged,
                  obscureText: widget.obscureText,
                  valid: _isValid,
                  textInputAction: widget.textInputAction,
                  hint: widget.inputHint ?? LiquidLocalizations.of(context).enterText,
                  label: widget.inputLabel ?? LiquidLocalizations.of(context).enterText,
                  onSubmitted: (text) => _onSubmitted(text),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
