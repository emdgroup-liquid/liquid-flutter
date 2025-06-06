import 'dart:async';

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
    return type == LdNotificationType.confirm ||
        type == LdNotificationType.enterText ||
        type == LdNotificationType.confirm ||
        type == LdNotificationType.acknowledge;
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
        case LdNotificationType.confirm:
          this.haptics = HapticsType.warning;
          break;
        case LdNotificationType.acknowledge:
          this.haptics = HapticsType.warning;
          break;
        case LdNotificationType.enterText:
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
        default:
      }
    }
  }
}

class LdInputNotification extends LdNotification {
  final Key inputKey = UniqueKey();
  final String? inputHint;
  final String? inputLabel;
  final TextInputType inputType;
  final String? submitText;

  /// Completer that gets resolved when the user entered something in the input field
  final Completer<String?> inputCompleter = Completer<String?>();

  LdInputNotification({
    required super.message,
    required super.type,
    required this.inputHint,
    required this.inputLabel,
    this.submitText,
    this.inputType = TextInputType.text,
    super.subMessage,
    super.color,
    super.canDismiss = true,
    super.duration = null,
  });
}

class LdConfirmNotification extends LdNotification {
  final Key cancelKey = UniqueKey();
  final Key confirmKey = UniqueKey();
  final String? confirmText;
  final String? cancelText;

  /// Completer that gets resolved when the user confirms the notification or it is dismissed
  final Completer<bool?> confirmationCompleter = Completer<bool?>();

  LdConfirmNotification({
    required super.message,
    required super.type,
    super.subMessage,
    super.color,
    super.canDismiss = true,
    super.duration = null,
    this.confirmText,
    this.cancelText,
  });
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
