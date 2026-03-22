import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdSubmitCancelButton<T, Arg> extends StatelessWidget {
  const LdSubmitCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, Arg>>();
    return LdButton.ghost(
      onPressed: controller.cancel,
      disabled: !controller.canCancel,
      child: Text(LiquidLocalizations.of(context).cancel),
    );
  }
}
