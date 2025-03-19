import 'package:liquid_flutter/liquid_flutter.dart';

/// A renderable exception. Has a message, more info, and a type (LdHintType).
/// Can also contain a stack trace as well as the flag that the action causing
/// the exception can be retried.
class LdException extends Error {
  /// The message of the exception.
  final String message;

  /// Additional information about the exception, e.g. a detailed explanation
  /// of what went wrong.
  final String? moreInfo;

  /// Whether the action causing the exception can be retried.
  final bool canRetry;

  /// The type of the exception. By default, it is [LdHintType.error].
  final LdHintType type;

  /// The actual [Exception] that caused this exception.
  final dynamic exception;

  /// The number of attempts that have been made to resolve the exception.
  /// This can be useful for debugging.
  final int? attempt;

  /// The stack trace of the exception.
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
}
