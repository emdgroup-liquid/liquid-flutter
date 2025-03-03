import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitCenteredBuilder<T> extends LdSubmitBuilder<T> {
  const LdSubmitCenteredBuilder({
    super.key,
    super.resultBuilder,
    super.submitButtonBuilder,
    super.loadingBuilder,
    super.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T>>();

    return StreamBuilder(
      stream: controller.stateStream,
      builder: (context, snapshot) {
        final state = controller.state;

        if (resultBuilder != null && state.type == LdSubmitStateType.result) {
          return resultBuilder!(context, state.result!, controller);
        }

        return Center(
          child: LdAutoSpace(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (state.type == LdSubmitStateType.error)
                errorBuilder != null
                    ? errorBuilder!(context, state.error!, controller)
                    : LdAutoSpace(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LdExceptionView(
                            exception: state.error!,
                            direction: Axis.vertical,
                            retry:
                                controller.canRetry ? controller.trigger : null,
                          ),
                          if (controller.showRetryIndicator)
                            LdExceptionRetryIndicator(
                              attempt: state.attempt,
                              remainingTime:
                                  state.remainingRetryTime ?? Duration.zero,
                              totalRetryTime: controller.totalRetryTime,
                            ),
                        ],
                      )
              else if (state.type == LdSubmitStateType.idle)
                submitButtonBuilder != null
                    ? submitButtonBuilder!(context, controller)
                    : LdSubmitButton(
                        controller: controller,
                      )
              else if (state.type == LdSubmitStateType.loading)
                loadingBuilder != null
                    ? loadingBuilder!(context, controller)
                    : LdAutoSpace(
                        animate: true,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const LdLoader(),
                          if (controller.config.loadingText != null)
                            Text(controller.config.loadingText!),
                          if (controller.canCancel)
                            LdButtonGhost(
                              onPressed: controller.cancel,
                              child:
                                  Text(LiquidLocalizations.of(context).cancel),
                            ),
                        ],
                      ),
            ],
          ),
        );
      },
    );
  }
}
