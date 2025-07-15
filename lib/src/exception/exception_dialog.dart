import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdTextH(
          localizedError.message,
          textAlign: TextAlign.center,
        ),
        if (localizedError.moreInfo != null)
          LdMute(
            child: LdTextPs(
              localizedError.moreInfo!,
              textAlign: TextAlign.center,
            ),
          ),
        primaryButton ??
            LdButtonGhost(
              width: double.infinity,
              child: Text(LiquidLocalizations.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
      ],
    );
  }

  Future<dynamic> show(BuildContext context) async {
    return LdModal(
      noHeader: true,
      modalContent: (context) => this,
      userCanDismiss: true,
      title: Text(LiquidLocalizations.of(context).errorOccurred),
    ).show(context);
  }
}
