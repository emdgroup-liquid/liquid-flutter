import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A renderable exception. Has a message, more info, and a type (LdHintType).
/// Can also contain a stack trace as well as the flag that the action causing
/// the exception can be retried.
class LdException extends Error {
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
    this.canRetry = true,
    this.type = LdHintType.error,
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
      canRetry: canRetry ?? this.canRetry,
      type: type ?? this.type,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return "LdException(canRetry: $canRetry, type: $type, exception: $exception, stackTrace: $stackTrace, attempt: $attempt)";
  }

  LdLocalizedException localize(BuildContext context) {
    if (this is LdLocalizedException) {
      return this as LdLocalizedException;
    }
    final exceptionMapper = context.read<LdExceptionLocalizerMapper?>();
    if (exceptionMapper == null) {
      return LdExceptionLocalizerMapper(
        onException: (context, e) => null,
      ).handle(
        context: context,
        e: this,
      );
    }
    return exceptionMapper.handle(
      context: context,
      e: this,
    );
  }
}

class LdLocalizedException extends LdException {
  final String message;
  final String? moreInfo;
  final Widget Function(BuildContext context)? additionalBuilder;
  final Widget Function(BuildContext context)? additionalDetailsBuilder;
  final Widget Function(BuildContext context)? customIconBuilder;

  LdLocalizedException({
    required this.message,
    this.moreInfo,
    this.additionalBuilder,
    this.additionalDetailsBuilder,
    this.customIconBuilder,
    super.canRetry = true,
    super.type = LdHintType.error,
    super.attempt,
    super.stackTrace,
    super.exception,
  });

  @override
  String toString() {
    return "LdLocalizedException(message: $message, moreInfo: $moreInfo, canRetry: $canRetry, type: $type, attempt: $attempt, stackTrace: $stackTrace, exception: $exception)";
  }

  factory LdLocalizedException.fromLdException({
    required LdException exception,
    required String message,
    String? moreInfo,
  }) {
    return LdLocalizedException(
      message: message,
      moreInfo: exception.exception.toString(),
      canRetry: exception.canRetry,
      type: exception.type,
      attempt: exception.attempt,
      stackTrace: exception.stackTrace,
      exception: exception.exception,
    );
  }
}
