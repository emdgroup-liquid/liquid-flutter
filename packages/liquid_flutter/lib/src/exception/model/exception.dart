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

  factory LdException.fromDynamic(BuildContext context, dynamic e) {
    final exceptionMapper = context.read<LdExceptionMapper?>() ??
        LdExceptionMapper(
          localizations: LiquidLocalizations.of(context),
        );
    final ldException = exceptionMapper.handle(e);

    return ldException;
  }

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

  LdLocalizedException localize(BuildContext context) {
    final exceptionMapper = context.read<LdExceptionMapper?>() ??
        LdExceptionMapper(
          localizations: LiquidLocalizations.of(context),
        );
    return exceptionMapper.handle(this);
  }
}

class LdLocalizedException extends LdException {
  final String message;
  final String? moreInfo;

  LdLocalizedException({
    required this.message,
    this.moreInfo,
    super.canRetry = true,
    super.type = LdHintType.error,
    super.attempt,
    super.stackTrace,
    super.exception,
  });

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
