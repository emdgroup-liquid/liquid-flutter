import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Renders an LdException in a dialog
class LdExceptionDialog extends StatelessWidget {
  final LdException? error;
  final void Function() close;

  const LdExceptionDialog(
      {super.key, required this.error, required this.close});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdTextH(
          error!.message,
          textAlign: TextAlign.center,
        ),
        if (error!.moreInfo != null)
          LdMute(
            child: LdTextPs(
              error!.moreInfo!,
              textAlign: TextAlign.center,
            ),
          ),
        LdButtonGhost(
          width: double.infinity,
          child: Text(LiquidLocalizations.of(context).close),
          onPressed: () {
            close();
          },
        )
      ],
    ).padL().padL();
  }
}
