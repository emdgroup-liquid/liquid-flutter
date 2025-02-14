import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitInlineBuilder<T> extends LdSubmitBuilder<T> {
  const LdSubmitInlineBuilder({
    super.key,
    super.resultBuilder,
    super.submitButtonBuilder,
    super.errorBuilder,
    this.showSubmitButton,
  });

  final bool? showSubmitButton;

  Widget buildSubmitButton(
    BuildContext context,
    LdSubmitController<T> controller,
  ) {
    return LdSubmitButton(
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T>>();

    return StreamBuilder(
      stream: controller.stateStream,
      builder: (context, snapshot) {
        final state = controller.state;

        return LdAutoSpace(
          children: [
            if (resultBuilder != null && state.type == LdSubmitStateType.result)
              resultBuilder!(context, state.result!, controller),
            if (state.type == LdSubmitStateType.error)
              if (errorBuilder != null)
                errorBuilder!(context, state.error!, controller)
              else
                LdExceptionView(
                  exception: state.error!,
                  direction: Axis.horizontal,
                  retry: controller.canRetry ? controller.trigger : null,
                  retryState: controller.state.retryState,
                )
            else if (submitButtonBuilder != null)
              submitButtonBuilder!(context, controller)
            else if (showSubmitButton == true ||
                controller.config.autoTrigger == false)
              LdSubmitButton(
                controller: controller,
              ),
            LdReveal(
              revealed: controller.canCancel,
              child: LdButtonGhost(
                onPressed: controller.cancel,
                child: Text(LiquidLocalizations.of(context).cancel),
              ),
            )
          ],
        );
      },
    );
  }
}
