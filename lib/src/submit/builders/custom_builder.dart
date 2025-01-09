import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A custom builder that allows you to build your own submit widget.
class LdSubmitCustomBuilder<T> extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    LdSubmitController<T> controller,
    LdSubmitStateType stateType,
  ) builder;

  const LdSubmitCustomBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T>>();

    return StreamBuilder(
      stream: controller.stateStream,
      builder: (context, snapshot) {
        final state = controller.state;
        return builder(context, controller, state.type);
      },
    );
  }
}
