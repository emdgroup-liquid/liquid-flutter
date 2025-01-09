import 'dart:ui';

import 'package:liquid_flutter/liquid_flutter.dart';

/// A configuration for a submit action.
class LdSubmitConfig<T> {
  final String? loadingText;
  final String? submitText;
  final bool? allowRetry;
  final bool? allowResubmit;
  final bool withHaptics;
  final bool autoTrigger;
  final Duration? timeout;
  final bool? allowCancel;
  final LdSubmitCallback<T> action;
  final VoidCallback? onCanceled;

  const LdSubmitConfig({
    /// The text to display when the action is loading
    this.loadingText,

    /// The text to display on the button
    this.submitText,

    /// Whether to allow retrying the action when it fails
    this.allowRetry,

    /// Whether to allow resubmitting the action after it has succeeded
    this.allowResubmit,

    /// Whether to trigger haptics when the action is triggered
    this.withHaptics = true,

    /// Whether to automatically trigger the action when mounted
    this.autoTrigger = false,

    /// Whether to allow cancelling the action
    this.allowCancel,

    /// Callback when the controller is canceled
    this.onCanceled,

    /// The timeout for the action
    this.timeout = const Duration(seconds: 10),

    /// The action to trigger that will return  T
    required this.action,
  });
}
