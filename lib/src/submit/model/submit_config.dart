import 'dart:ui';

import 'package:liquid_flutter/liquid_flutter.dart';

/// Configuration for (automatic) retries of a submit action.
class LdSubmitRetryConfig {
  final bool performAutomaticRetry;
  final int maxRetryAttempts;
  final int initialRetryCountdown;
  final bool disableRetryButton;

  const LdSubmitRetryConfig({
    /// If set to false, you can still use [LdSubmitRetryConfig] in order to block
    /// the retry button for a certain amount of time.
    this.performAutomaticRetry = true,

    /// The maximum number of retry attempts. After this number is reached, the
    /// retry button will be hidden. If set to 0, the retry button will be hidden
    /// immediately.
    this.maxRetryAttempts = 3,

    /// The initial countdown in milliseconds for the retry button. This value
    /// will be doubled after each failed attempt.
    this.initialRetryCountdown = 1000,

    /// If set to true, the retry button will be disabled while the delay is
    /// counting down. Hence, the user cannot trigger a retry manually.
    this.disableRetryButton = false,
  })  : assert(
          !performAutomaticRetry ||
              !disableRetryButton ||
              initialRetryCountdown > 0,
          "If either performAutomaticRetry or disableRetryButton is true, the initialRetryCountdown must be greater than 0",
        ),
        assert(
          maxRetryAttempts >= 0,
          "maxRetryAttempts must be greater than 0",
        );

  /// A configuration that does not allow any retries.
  factory LdSubmitRetryConfig.noRetries() => const LdSubmitRetryConfig(
        performAutomaticRetry: false,
        maxRetryAttempts: 0,
      );
}

/// A configuration for a submit action.
class LdSubmitConfig<T> {
  final String? loadingText;
  final String? submitText;
  final bool? allowResubmit;
  final bool withHaptics;
  final bool autoTrigger;
  final Duration? timeout;
  final bool? allowCancel;
  final LdSubmitCallback<T> action;
  final VoidCallback? onCanceled;
  final LdSubmitRetryConfig? retryConfig;

  const LdSubmitConfig({
    /// The text to display when the action is loading
    this.loadingText,

    /// The text to display on the button
    this.submitText,

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

    /// The configuration for (automatic) retries
    /// If null, the user can manually trigger a retry as often as they want,
    /// but no automatic retries will be performed.
    this.retryConfig,

    /// The action to trigger that will return  T
    required this.action,
  });
}
