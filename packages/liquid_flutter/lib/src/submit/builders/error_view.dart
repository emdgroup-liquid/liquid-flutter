import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdSubmitErrorView<T, Arg> extends StatelessWidget {
  const LdSubmitErrorView({super.key, this.direction = Axis.vertical});

  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, Arg>>();
    final state = controller.state;

    return LdExceptionView(
      exception: state.error!,
      direction: direction,
      retryController: controller.retryController,
    );
  }
}
