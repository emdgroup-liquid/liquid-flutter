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
  LdNotificationsController? _notificationsController;

  @override
  void initState() {
    super.initState();
    _submitController = context.read<LdSubmitController<T, Arg>>();
    _subscription = _submitController.stateStream.listen((state) => _onStateChanged(state, _submitController));
    _notificationsController = LdNotificationsController.of(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _dismissNotification();
    super.dispose();
  }

  void _dismissNotification() {
    if (_notification != null) {
      _notificationsController?.onDismissNotification(_notification!);
      _notification = null;
    } else {}
  }

  LdNotification? _notification;

  void _onStateChanged(LdSubmitState<T> state, LdSubmitController<T, Arg> controller) {
    _dismissNotification();
    if (state.type == LdSubmitStateType.loading) {
      _notification = _notificationsController?.addNotification(
        LdNotification(
          message: controller.config.loadingText ?? LiquidLocalizations.of(context).loading,
          type: LdNotificationType.loading,
          canDismiss: _submitController.canCancel,
        ),
      );
    }
    if (state.type == LdSubmitStateType.error) {
      final localizedError = state.error!.localize(context);
      _notification = _notificationsController?.addNotification(
        LdNotification(
          message: localizedError.message,
          type: LdNotificationType.error,
        ),
      );
    }

    if (state.type == LdSubmitStateType.result && widget.successMessage != null) {
      _notification = _notificationsController?.addNotification(
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.resultBuilder != null && state.type == LdSubmitStateType.result)
              widget.resultBuilder!(context, state.result as T, controller),
            if (widget.submitButtonBuilder != null)
              widget.submitButtonBuilder!(context, controller)
            else if (widget.showSubmitButton == true || controller.config.autoTrigger == false)
              LdSubmitButton<T, Arg>(),
            LdReveal.quick(
              revealed: controller.canCancel,
              child: LdButton.ghost(
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
