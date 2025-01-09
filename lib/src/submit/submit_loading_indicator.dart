import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSubmitLoadingIndicator extends StatelessWidget {
  final bool loading;
  final String? loadingText;
  final Axis direction;

  const LdSubmitLoadingIndicator(
      {super.key,
      required this.loading,
      this.loadingText,
      this.direction = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return const SizedBox();
    }

    return switch (direction) {
      (Axis.horizontal) => Row(
          children: [
            const LdLoader(),
            ldSpacerS,
            LdTextL(
              loadingText ?? LiquidLocalizations.of(context).loading,
            ),
          ],
        ),
      (Axis.vertical) => Column(
          children: [
            const LdLoader(),
            ldSpacerS,
            LdTextL(
              loadingText ?? LiquidLocalizations.of(context).loading,
            ),
          ],
        ),
    };
  }
}
