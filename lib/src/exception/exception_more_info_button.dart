import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// LdExceptionMoreInfoButton is a button that will open a dialog with more info
class LdExceptionMoreInfoButton extends StatelessWidget {
  final LdException? error;

  const LdExceptionMoreInfoButton({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.moreInfo == null) {
      return const SizedBox();
    }

    final theme = LdTheme.of(context, listen: true);

    return LdModalBuilder(
      builder: (context, open) => LdButton(
        child: Text(LiquidLocalizations.of(context).moreInfo),
        mode: LdButtonMode.outline,
        color: theme.error,
        onPressed: open,
      ),
      modal: LdModal(
        noHeader: true,
        showDismissButton: false,
        modalContent: (context) => LdExceptionDialog(
          error: error!,
        ),
        actions: (context) => [
          LdButtonGhost(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LiquidLocalizations.of(context).close),
          ),
        ],
        title: Text(LiquidLocalizations.of(context).errorOccurred),
      ),
    );
  }
}
