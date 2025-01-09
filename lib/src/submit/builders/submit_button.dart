import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSubmitButton extends StatelessWidget {
  final LdSubmitController controller;

  final Widget? leading;
  final Widget? trailing;
  final LdSize size;
  final LdColor? color;

  const LdSubmitButton(
      {super.key,
      required this.controller,
      this.leading,
      this.trailing,
      this.size = LdSize.m,
      this.color});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return LdButton(
      size: size,
      color: color,
      leading: leading,
      trailing: trailing,
      onPressed: controller.trigger,
      loadingText: controller.config.loadingText,
      loading: state.type == LdSubmitStateType.loading,
      disabled: !controller.canTrigger,
      child: Text(
        controller.config.submitText ?? LiquidLocalizations.of(context).submit,
      ),
    );
  }
}
