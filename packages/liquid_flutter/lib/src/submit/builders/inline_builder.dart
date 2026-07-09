import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/cancel_button.dart';
import 'package:liquid_flutter/src/submit/builders/error_view.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitInlineBuilder<T, Arg> extends LdSubmitBuilder<T, Arg> {
  const LdSubmitInlineBuilder({
    super.key,
    super.resultBuilder,
    super.submitButtonBuilder,
    super.errorBuilder,
    this.showSubmitButton,
  });

  final bool? showSubmitButton;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T, Arg>>();

    return StreamBuilder(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final state = controller.state;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resultBuilder != null && state.type == LdSubmitStateType.result)
              resultBuilder!(context, state.result as T, controller),
            if (state.type == LdSubmitStateType.error)
              if (errorBuilder != null)
                errorBuilder!(context, state.error!, controller)
              else
                LdSubmitErrorView<T, Arg>(
                  direction: Axis.horizontal,
                )
            else if (submitButtonBuilder != null)
              submitButtonBuilder!(context, controller)
            else if ((showSubmitButton == true || controller.config.autoTrigger == false))
              LdSubmitButton<T, Arg>(),
            if (controller.canCancel) LdSubmitCancelButton<T, Arg>(),
          ],
        ).spaceM();
      },
    );
  }
}
