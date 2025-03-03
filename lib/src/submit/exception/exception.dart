import 'package:liquid_flutter/liquid_flutter.dart';

/// The state of the retry mechanism.
class LdExceptionRetryState {
  /// The current retry count
  final int retryCount;

  /// The left time to retry in milliseconds.
  /// It will be decremented each second by the [LdSubmitController].
  final Duration delay;

  LdExceptionRetryState({
    required this.retryCount,
    required this.delay,
  });

  copyWith({
    int? retryCount,
    Duration? delay,
  }) {
    return LdExceptionRetryState(
      retryCount: retryCount ?? this.retryCount,
      delay: delay ?? this.delay,
    );
  }

  @override
  String toString() {
    return 'LdExceptionRetryState(retryCount: $retryCount, delay: $delay)';
  }
}

/// A renderable exception. Has a message, more info, and a type (LdHintType).
/// Can also contain a stack trace as well as the flag that the action causing
/// the exception can be retried.
class LdException extends Error {
  final String message;
  final String? moreInfo;
  final bool canRetry;
  final LdHintType type;
  final int? attempt;

  final dynamic exception;

  @override
  final StackTrace? stackTrace;

  LdException({
    required this.message,
    this.canRetry = true,
    this.type = LdHintType.error,
    this.moreInfo,
    this.attempt,
    this.stackTrace,
    this.exception,
  });

  LdException copyWith({
    String? message,
    String? moreInfo,
    bool? canRetry,
    LdHintType? type,
    int? attempt,
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    return LdException(
      message: message ?? this.message,
      moreInfo: moreInfo ?? this.moreInfo,
      canRetry: canRetry ?? this.canRetry,
      type: type ?? this.type,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'LdException(message: $message, moreInfo: $moreInfo, canRetry: $canRetry, type: $type, retryState: $attempt, exception: $exception, stackTrace: $stackTrace)';
  }
}
