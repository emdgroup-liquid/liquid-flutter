import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitDialogBuilder<T> extends LdSubmitBuilder<T> {
  LdSubmitDialogBuilder({
    super.key,
    super.resultBuilder,
    super.errorBuilder,
    super.loadingBuilder,
    super.submitButtonBuilder,
    this.showSubmitButton,
  });

  final bool? showSubmitButton;

  final Key dialogKey = UniqueKey();

  Widget buildLoadingDialog(
    BuildContext context,
    LdSubmitController<T> controller,
  ) {
    return loadingBuilder != null
        ? loadingBuilder!(context, controller)
        : LdAutoSpace(
            animate: true,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LdLoader(
                size: 48,
              ),
              if (controller.config.loadingText != null)
                Text(controller.config.loadingText!)
              else
                Text(
                  LiquidLocalizations.of(context).loading,
                ),
              if (controller.canCancel)
                LdButtonGhost(
                  onPressed: controller.cancel,
                  child: Text(LiquidLocalizations.of(context).cancel),
                ),
            ],
          ).padL();
  }

  Widget buildErrorDialog(
    BuildContext context,
    LdSubmitController<T> controller,
  ) {
    return errorBuilder != null
        ? errorBuilder!(context, controller.state.error!, controller)
        : LdExceptionView(
            exception: controller.state.error!,
            direction: Axis.vertical,
            retry: controller.canRetry ? controller.trigger : null,
          ).padL();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T>>();
    return StreamBuilder(
      stream: controller.stateStream,
      builder: (context, snapshot) {
        final state = controller.state;
        final open = state.type == LdSubmitStateType.loading ||
            state.type == LdSubmitStateType.error;
        return PortalTarget(
          visible: open,
          child: LdAutoSpace(
            children: [
              if (resultBuilder != null &&
                  state.type == LdSubmitStateType.result)
                resultBuilder!(
                  context,
                  state.result!,
                  controller,
                ),
              if (submitButtonBuilder != null)
                submitButtonBuilder!(context, controller)
              else if (showSubmitButton == true ||
                  controller.config.autoTrigger == false)
                LdSubmitButton(
                  controller: controller,
                ),
            ],
          ),
          portalFollower: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: LdTheme.of(context).surface.withAlpha(204),
                ),
              ),
              ModalBarrier(onDismiss: () {
                if (controller.state.type == LdSubmitStateType.error) {
                  if (controller.canRetry) {
                    controller.reset();
                  }
                }
                if (controller.state.type == LdSubmitStateType.loading) {
                  if (controller.canCancel) {
                    controller.cancel();
                  }
                }
              }),
              Center(
                child: switch (controller.state.type) {
                  (LdSubmitStateType.loading) =>
                    buildLoadingDialog(context, controller),
                  (LdSubmitStateType.error) =>
                    buildErrorDialog(context, controller),
                  (_) => Container(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
