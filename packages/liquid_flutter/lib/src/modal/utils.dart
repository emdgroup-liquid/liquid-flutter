import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          appBars: [
            LdAppBar(
              title: title ?? Text(locale.confirm),
            ),
            LdAppBar(
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
            ),
          ],
          body: LdScaffoldBodyCentered(
            child: LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (indicatorType != null)
                  LdIndicator(
                    type: indicatorType,
                    customSize: 24,
                  ),
                if (description != null) LdText.p(description),
                if (additionalContent != null) additionalContent,
              ],
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
  bool allowDismiss = true,
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
  final bool allowDismiss;

  const _LdEnterTextModal({
    required this.description,
    required this.title,
    required this.additionalContent,
    required this.inputHint,
    required this.inputLabel,
    required this.allowDismiss,
    required this.initialValue,
  });

  @override
  State<_LdEnterTextModal> createState() => _LdEnterTextModalState();
}

class _LdEnterTextModalState extends State<_LdEnterTextModal> {
  final TextEditingController _controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      appBars: [
        LdAppBar(
          title: widget.title ?? Text(LiquidLocalizations.of(context).enterText),
        ),
        LdAppBar(
          positionMode: LdAppBarPositionMode.bottom,
          avoidViewInsets: true,
          attachedMode: LdAppBarAttachedMode.attached,
          actions: [
            if (widget.allowDismiss)
              LdFlexibleChild(
                child: LdButton.vague(
                  color: LdTheme.of(context).error,
                  width: double.infinity,
                  child: Text(LiquidLocalizations.of(context).cancel),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
            LdFlexibleChild(
              child: LdButton.filled(
                width: double.infinity,
                child: Text(LiquidLocalizations.of(context).done),
                onPressed: () => Navigator.of(context).pop(_controller.text),
              ),
            ),
          ],
        ),
      ],
      body: LdScaffoldBody(
        children: [
          LdAutoSpace(children: [
            if (widget.description != null) LdText.p(widget.description!),
            if (widget.additionalContent != null) widget.additionalContent!,
            LdInput(
              controller: _controller,
              autofocus: true,
              hint: widget.inputHint ?? LiquidLocalizations.of(context).enterText,
              label: widget.inputLabel ?? LiquidLocalizations.of(context).enterText,
              onSubmitted: (text) => Navigator.of(context).pop(text),
            ),
          ]),
        ],
      ),
    );
  }
}
