import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/notifications/notification.dart';
import 'package:liquid_flutter/src/notifications/notification_type.dart';
import 'package:provider/provider.dart';

class LdNotificationsController extends ChangeNotifier {
  final List<LdNotification> _notifications = [];

  List<LdNotification> get notifications => _notifications;

  Future<LdNotification> error(
    String message, {
    Duration? duration = const Duration(seconds: 5),
    bool canDismiss = true,
    String? subMessage,
  }) {
    return addNotification(LdNotification(
      message: message,
      duration: duration,
      type: LdNotificationType.error,
      canDismiss: canDismiss,
      subMessage: subMessage,
    ));
  }

  Future<LdNotification> success(
    String message, {
    Duration? duration = const Duration(seconds: 5),
    bool canDismiss = true,
    String? subMessage,
  }) {
    return addNotification(LdNotification(
      message: message,
      duration: duration,
      type: LdNotificationType.success,
      canDismiss: canDismiss,
      subMessage: subMessage,
    ));
  }

  Future<LdNotification> warning(
    String message, {
    Duration? duration = const Duration(seconds: 5),
    bool canDismiss = true,
    String? subMessage,
  }) {
    return addNotification(LdNotification(
      message: message,
      duration: duration,
      type: LdNotificationType.warning,
      canDismiss: canDismiss,
      subMessage: subMessage,
    ));
  }

  Future<bool?> confirm(
    String message, {
    Duration? duration,
    bool canDismiss = true,
    String? subMessage,
    String? confirmText,
  }) {
    final notification = LdConfirmNotification(
      message: message,
      confirmText: confirmText,
      duration: duration,
      type: LdNotificationType.confirm,
      canDismiss: canDismiss,
      subMessage: subMessage,
    );
    addNotification(notification);
    return notification.confirmationCompleter.future;
  }

  LdInputNotification enterText({
    Duration? duration,
    required String message,
    required String inputHint,
    required String inputLabel,
    String? submitText,
    bool canDismiss = true,
    String? subMessage,
  }) {
    final notification = LdInputNotification(
      message: message,
      duration: duration,
      type: LdNotificationType.enterText,
      inputHint: inputHint,
      inputLabel: inputLabel,
      submitText: submitText,
      canDismiss: canDismiss,
      subMessage: subMessage,
    );
    addNotification(notification);
    return notification;
  }

  Future<LdNotification> addNotification(LdNotification notification) async {
    _notifications.add(notification);
    notifyListeners();
    if (notification.haptics != null) {
      LdHaptics.vibrate(notification.haptics!);
    }
    await Future.delayed(const Duration(milliseconds: 100));

    if (notification.duration != null) {
      Future.delayed(notification.duration!, () {
        onDismissNotification(notification);
      });
    }
    return notification;
  }

  Future<void> onConfirmedNotification(
    LdConfirmNotification notification,
  ) async {
    notification.didConfirm = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    notification.removing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    notification.confirmationCompleter.complete(true);
    _notifications.remove(notification);

    notifyListeners();
  }

  Future<void> onInputSubmitted(
    LdInputNotification notification,
    String result,
  ) async {
    notification.removing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.remove(notification);
    notification.inputCompleter.complete(result);
    notifyListeners();
  }

  Future<void> onDismissNotification(LdNotification notification) async {
    notification.removing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.remove(notification);

    if (notification is LdInputNotification) {
      notification.inputCompleter.complete(null);
    }

    if (notification is LdConfirmNotification) {
      notification.confirmationCompleter.complete(null);
    }

    notifyListeners();
  }

  Future<void> onCancelledNotification(
      LdConfirmNotification notification) async {
    notification.removing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.remove(notification);
    notification.confirmationCompleter.complete(false);
    notifyListeners();
  }

  void clearNotifications() {
    for (final notification in _notifications) {
      onDismissNotification(notification);
    }
    notifyListeners();
  }

  static LdNotificationsController of(BuildContext context) {
    return Provider.of<LdNotificationsController>(context, listen: false);
  }
}
