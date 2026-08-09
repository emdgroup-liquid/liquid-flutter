import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:flutter/foundation.dart';

/// Renders an LdException in a dialog
class LdExceptionDialog extends StatelessWidget {
  final LdException error;
  final Widget? primaryButton;

  const LdExceptionDialog({
    super.key,
    required this.error,
    this.primaryButton,
  });

  @override
  Widget build(BuildContext context) {
    final localizedError = error.localize(context);

    return LdScaffold(
      body: LdAppBar(
        title: Text(LiquidLocalizations.of(context).errorDetails),
        child: LdAppBar.bottom(
          actions: [
            LdFlexibleChild(
              child: primaryButton ??
                  LdButton.vague(
                    width: double.infinity,
                    child: Text(LiquidLocalizations.of(context).close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
            )
          ],
          child: LdScaffoldBody(
            children: [
              if (localizedError.customIconBuilder != null) ...[
                localizedError.customIconBuilder!(context),
              ],
              SelectableRegion(
                selectionControls: MaterialTextSelectionControls(),
                child: LdText.h(
                  localizedError.message,
                ),
              ),
              if (localizedError.moreInfo != null)
                SelectableRegion(
                  selectionControls: MaterialTextSelectionControls(),
                  child: LdMute(
                    child: LdText.ps(
                      localizedError.moreInfo!,
                    ),
                  ),
                ),
              if (localizedError.additionalDetailsBuilder != null) ...[
                localizedError.additionalDetailsBuilder!(context),
              ],
              if (kDebugMode && localizedError.stackTrace != null) ...[
                LdHint(
                  type: LdHintType.info,
                  child: Text("Stack trace only visible in debug mode."),
                ),
                LdRunnerLog(
                  messages: localizedError.stackTrace.toString().split("\n"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> show(BuildContext context) async {
    return LdModalRoute(
      context: context,
      pageBuilder: (context) => this,
    ).show(context, useRootNavigator: true);
  }
}
