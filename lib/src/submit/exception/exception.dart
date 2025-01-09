import 'package:liquid_flutter/liquid_flutter.dart';

/// A renderable exception. Has a message, more info, and a type (LdHintType).
/// Can also contain a stack trace as well as the flag that the action causing
/// the exception can be retried.
class LdException extends Error {
  final String message;
  final String? moreInfo;
  final bool canRetry;
  final LdHintType type;

  final dynamic exception;

  @override
  final StackTrace? stackTrace;

  LdException({
    required this.message,
    this.canRetry = true,
    this.type = LdHintType.error,
    this.moreInfo,
    this.stackTrace,
    this.exception,
  });
}
