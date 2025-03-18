/// Configuration for retry behavior
class LdRetryConfig {
  /// Maximum number of attempts (including the initial attempt).
  /// If set to 1, the retry button will be hidden immediately.
  /// Defaults to 4 (i.e. 3 retries).
  final int maxAttempts;

  /// Whether to enable automatic retries
  final bool enableAutomaticRetries;

  /// Base delay for retries (will be multiplied by exponential backoff)
  /// Can only be used in combination with [enableAutomaticRetries].
  final Duration baseDelay;

  /// Whether to disable the manual retry button.
  /// Can only be used in combination with [enableAutomaticRetries].
  final bool disableRetryButton;

  /// Whether to add jitter to retry delays
  /// Can only be used in combination with [enableAutomaticRetries].
  final bool useJitter;

  const LdRetryConfig({
    this.maxAttempts = 4,
    this.enableAutomaticRetries = false,
    this.disableRetryButton = false,
    this.baseDelay = const Duration(seconds: 3),
    this.useJitter = true,
  })  : assert(
          !enableAutomaticRetries ||
              !disableRetryButton ||
              baseDelay > Duration.zero,
          "If enableAutomaticRetries is true, disableRetryButton must be false and baseDelay must be greater than 0",
        ),
        assert(
          maxAttempts >= 1,
          "maxRetryAttempts must be greater than 1",
        );

  /// A configuration that does not allow any retries.
  factory LdRetryConfig.noRetries() => const LdRetryConfig(
        maxAttempts: 1,
      );

  /// A configuration that allows unlimited retries that have to be triggered manually.
  factory LdRetryConfig.unlimitedManualRetries() => const LdRetryConfig(
        enableAutomaticRetries: false,
        maxAttempts: 999999,
      );

  /// A configuration that allows 3 automatic retries with exponential backoff.
  factory LdRetryConfig.defaultAutomaticRetries() => const LdRetryConfig(
        enableAutomaticRetries: true,
      );
}
