import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitNotificationBuilder<T, Arg> extends LdSubmitBuilder<T, Arg> {
  const LdSubmitNotificationBuilder({
    super.key,
    super.resultBuilder,
    super.submitButtonBuilder,
    this.showSubmitButton,
    this.successMessage,
  });

  final bool? showSubmitButton;

  final String? successMessage;

  Widget buildSubmitButton(
    BuildContext context,
    LdSubmitController<T, Arg> controller,
  ) {
    return LdSubmitButton(
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LdSubmitNotification<T, Arg>(
      resultBuilder: resultBuilder,
      submitButtonBuilder: submitButtonBuilder,
      showSubmitButton: showSubmitButton,
      successMessage: successMessage,
    );
  }
}

class _LdSubmitNotification<T, Arg> extends StatefulWidget {
  const _LdSubmitNotification({
    super.key,
    this.resultBuilder,
    this.submitButtonBuilder,
    this.showSubmitButton,
    required this.successMessage,
  });

  final LdSubmitResultBuilder<T, Arg>? resultBuilder;
  final String? successMessage;
  final LdSubmitButtonBuilder<T, Arg>? submitButtonBuilder;
  final bool? showSubmitButton;

  @override
  State<_LdSubmitNotification<T, Arg>> createState() => _LdSubmitNotificationState<T, Arg>();
}

class _LdSubmitNotificationState<T, Arg> extends State<_LdSubmitNotification<T, Arg>> {
  late LdSubmitController<T, Arg> _submitController;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _submitController = context.read<LdSubmitController<T, Arg>>();
    _subscription = _submitController.stateStream.listen((state) => _onStateChanged(state, _submitController));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  LdNotification? _loadingNotification;

  Future<void> _onStateChanged(LdSubmitState<T> state, LdSubmitController<T, Arg> controller) async {
    if (_loadingNotification != null) {
      LdNotificationsController.of(context).onDismissNotification(_loadingNotification!);
    }
    if (state.type == LdSubmitStateType.loading) {
      _loadingNotification = await LdNotificationsController.of(context).addNotification(
        LdNotification(
          message: controller.config.loadingText ?? LiquidLocalizations.of(context).loading,
          type: LdNotificationType.loading,
          canDismiss: _submitController.canCancel,
        ),
      );
    }
    if (state.type == LdSubmitStateType.error) {
      LdNotificationsController.of(context).addNotification(
        LdNotification(
          message: state.error!.message,
          subMessage: state.error!.moreInfo,
          type: LdNotificationType.error,
        ),
      );
    }
    if (state.type == LdSubmitStateType.result && widget.successMessage != null) {
      LdNotificationsController.of(context).addNotification(
        LdNotification(
          message: widget.successMessage!,
          type: LdNotificationType.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LdSubmitController<T, Arg>>();

    return StreamBuilder(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final state = controller.state;

        return LdAutoSpace(
          children: [
            if (widget.resultBuilder != null && state.type == LdSubmitStateType.result)
              widget.resultBuilder!(context, state.result!, controller),
            if (widget.submitButtonBuilder != null)
              widget.submitButtonBuilder!(context, controller)
            else if (widget.showSubmitButton == true || controller.config.autoTrigger == false)
              LdSubmitButton(
                controller: controller,
              ),
            LdReveal.quick(
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
