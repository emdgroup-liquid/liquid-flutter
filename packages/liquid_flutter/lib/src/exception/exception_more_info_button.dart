import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// LdExceptionMoreInfoButton is a button that will open a dialog with more info
class LdExceptionMoreInfoButton extends StatelessWidget {
  final LdLocalizedException? error;

  const LdExceptionMoreInfoButton({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.moreInfo == null) {
      return const SizedBox();
    }

    final theme = LdTheme.of(context, listen: true);

    return LdModalBuilder(
      builder: (context, open) => LdButton(
        mode: LdButtonMode.outline,
        color: theme.error,
        onPressed: open,
        child: Text(LiquidLocalizations.of(context).moreInfo),
      ),
      modal: LdModalRoute(
        context: context,
        pageBuilder: (context) => LdExceptionDialog(
          error: error!,
        ),
      ),
    );
  }
}
