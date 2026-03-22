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
    final controller = context.watch<LdSubmitController<T, Arg>>();
    final state = controller.state;

    final child = switch (state.type) {
      LdSubmitStateType.result => resultBuilder != null
          ? resultBuilder!(
              context,
              state.result as T,
              controller,
            )
          : null,
      LdSubmitStateType.error => errorBuilder != null
          ? errorBuilder!(context, state.error!, controller)
          : LdExceptionView(
              exception: state.error!.localize(context),
              direction: Axis.vertical,
              retryController: controller.retryController,
            ),
      LdSubmitStateType.idle => switch (controller.config.autoTrigger) {
          true => SizedBox.shrink(),
          false => submitButtonBuilder != null ? submitButtonBuilder!(context, controller) : LdSubmitButton<T, Arg>(),
        },
      LdSubmitStateType.loading => loadingBuilder != null
          ? loadingBuilder!(context, controller)
          : LdSubmitLoadingIndicator<T, Arg>(
              direction: Axis.vertical,
            ),
    };

    return Center(
      child: child,
    );
  }
}
