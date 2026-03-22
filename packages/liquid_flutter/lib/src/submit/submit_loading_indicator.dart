import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdSubmitLoadingIndicator<T, Arg> extends StatelessWidget {
  final Axis direction;

  const LdSubmitLoadingIndicator({
    super.key,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, Arg>>();

    return switch (direction) {
      (Axis.horizontal) => Row(
          children: [
            const LdLoader(),
            ldSpacerS,
            LdText.l(
              controller.config.loadingText ?? LiquidLocalizations.of(context).loading,
            ),
          ],
        ),
      (Axis.vertical) => Column(
          children: [
            const LdLoader(),
            ldSpacerS,
            LdText.l(
              controller.config.loadingText ?? LiquidLocalizations.of(context).loading,
            ),
          ],
        ),
    };
  }
}
