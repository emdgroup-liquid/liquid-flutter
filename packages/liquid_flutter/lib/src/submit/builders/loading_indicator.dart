import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdSubmitLoadingIndicator<T, Arg> extends StatelessWidget {
  const LdSubmitLoadingIndicator({
    super.key,
    this.centerHorizontally = true,
    this.loaderSize = 32,
  });

  final double loaderSize;
  final bool centerHorizontally;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, Arg>>();

    return LdAutoSpace(
      animate: true,
      crossAxisAlignment: switch (centerHorizontally) {
        true => CrossAxisAlignment.center,
        false => CrossAxisAlignment.start,
      },
      children: [
        LdLoader(
          size: loaderSize,
        ),
        if (controller.config.loadingText != null) Text(controller.config.loadingText!),
        if (controller.canCancel)
          LdButton.ghost(
            onPressed: controller.cancel,
            child: Text(LiquidLocalizations.of(context).cancel),
          ),
      ],
    );
  }
}
