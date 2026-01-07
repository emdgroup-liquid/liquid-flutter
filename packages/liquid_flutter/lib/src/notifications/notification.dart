import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdNotification {
  /// Message of the notification
  final String message;

  /// Submessage of the notification
  final String? subMessage;

  /// Duration of the notification. If null the notification will not be dismissed automatically
  final Duration? duration;

  /// If the notification is a big notification

  final LdColor? color;
  final LdNotificationType type;

  late final HapticsType? haptics;

  bool removing;
  bool didConfirm;

  bool get showBackdrop {
    return type == LdNotificationType.acknowledge;
  }

  final Key key = UniqueKey();

  final bool canDismiss;

  LdNotification({
    required this.message,
    required this.type,
    this.subMessage,
    this.color,
    this.canDismiss = true,
    this.removing = false,
    HapticsType? haptics,
    this.didConfirm = false,
    this.duration = const Duration(seconds: 5),
  }) {
    if (haptics == null) {
      switch (type) {
        case LdNotificationType.loading:
          this.haptics = HapticsType.light;
          break;
        case LdNotificationType.acknowledge:
          this.haptics = HapticsType.warning;
          break;
        case LdNotificationType.info:
          this.haptics = HapticsType.light;
          break;
        case LdNotificationType.success:
          this.haptics = HapticsType.success;
          break;
        case LdNotificationType.error:
          this.haptics = HapticsType.error;
          break;
        case LdNotificationType.warning:
          this.haptics = HapticsType.warning;
          break;
      }
    }
  }
}

class LdAcknowledgeNotification extends LdNotification {
  final Key dismissKey = UniqueKey();

  final String? acknowledgeText;

  LdAcknowledgeNotification({
    required super.message,
    required super.type,
    super.subMessage,
    super.color,
    super.canDismiss = true,
    super.duration = null,
    this.acknowledgeText,
  });
}
