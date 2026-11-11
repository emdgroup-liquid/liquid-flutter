import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.pad(size: LdSize.s).vertical,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LdLoader(),
          const SizedBox(width: 8),
          LdText.l('Generating...'),
        ],
      ),
    );
  }
}
