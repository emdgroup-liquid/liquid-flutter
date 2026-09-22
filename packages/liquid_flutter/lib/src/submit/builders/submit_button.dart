import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdSubmitButton<T, Arg> extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final LdColor? color;

  const LdSubmitButton({
    super.key,
    this.leading,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, Arg>>();
    final state = controller.state;

    return LdButton(
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
