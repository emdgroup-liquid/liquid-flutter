import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitCenteredBuilder<T, Arg> extends LdSubmitBuilder<T, Arg> {
  const LdSubmitCenteredBuilder({
    super.key,
    super.resultBuilder,
    super.submitButtonBuilder,
    super.loadingBuilder,
    super.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T, Arg>>();

    return StreamBuilder(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final state = controller.state;

        if (resultBuilder != null && state.type == LdSubmitStateType.result) {
          return resultBuilder!(context, state.result as T, controller);
        }

        final child = switch (state.type) {
          LdSubmitStateType.result => resultBuilder != null
              ? resultBuilder!(context, state.result as T, controller)
              : null,
          LdSubmitStateType.error => errorBuilder != null
              ? errorBuilder!(context, state.error!, controller)
              : LdExceptionView(
                  exception: state.error?.localize(context),
                  direction: Axis.vertical,
                  retryController: controller.retryController,
                ),
          LdSubmitStateType.idle => switch (controller.config.autoTrigger) {
              true => SizedBox.shrink(),
              false => submitButtonBuilder != null
                  ? submitButtonBuilder!(context, controller)
                  : LdSubmitButton(
                      controller: controller,
                    ),
            },
          false => submitButtonBuilder != null
              ? submitButtonBuilder!(context, controller)
              : LdSubmitButton(
                  controller: controller,
                ),
          LdSubmitStateType.loading => loadingBuilder != null
              ? loadingBuilder!(context, controller)
              : LdAutoSpace(
                  animate: true,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const LdLoader(),
                    if (controller.config.loadingText != null)
                      Text(controller.config.loadingText!),
                    if (controller.canCancel)
                      LdButton.ghost(
                        onPressed: controller.cancel,
                        child: Text(LiquidLocalizations.of(context).cancel),
                      ),
                  ],
                ),
        };

        return Center(
          child: child,
        );
      },
    );
  }
}
