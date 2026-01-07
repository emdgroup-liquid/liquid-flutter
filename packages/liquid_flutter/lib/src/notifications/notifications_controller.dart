import 'dart:async';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/notifications/notification.dart';
import 'package:liquid_flutter/src/notifications/notification_type.dart';
import 'package:provider/provider.dart';

class LdNotificationsController extends ChangeNotifier {
  final String? debugLabel;
  final List<LdNotification> _notifications = [];

  LdNotificationsController({this.debugLabel});

  @override
  String toString() {
    return "LdNotificationsController(debugLabel: $debugLabel, notifications: $_notifications)";
  }

  bool _disposed = false;

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  List<LdNotification> get notifications => _notifications;

  LdNotification error(
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

  LdNotification success(
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

  LdNotification warning(
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

  LdNotification addNotification(LdNotification notification) {
    _notifications.add(notification);
    _safeNotifyListeners();
    if (notification.haptics != null) {
      LdHaptics.vibrate(notification.haptics!);
    }

    if (notification.duration != null) {
      Future.delayed(notification.duration!, () {
        _safeNotifyListeners();
      });
    }
    return notification;
  }

  Future<void> onDismissNotification(LdNotification notification) async {
    assert(_notifications.contains(notification), "Notification not found in list");
    notification.removing = true;

    await Future.delayed(const Duration(milliseconds: 0));

    _safeNotifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.remove(notification);

    _safeNotifyListeners();
  }

  void clearNotifications() {
    for (final notification in _notifications) {
      onDismissNotification(notification);
    }
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static LdNotificationsController of(BuildContext context) {
    return Provider.of<LdNotificationsController>(context, listen: false);
  }

  static LdNotificationsController? maybeOf(BuildContext context) {
    return context.read<LdNotificationsController?>();
  }
}
