import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdExceptionMapperProvider extends StatelessWidget {
  final Widget child;
  final LdExceptionMapper? exceptionMapper;

  const LdExceptionMapperProvider({
    Key? key,
    required this.child,
    this.exceptionMapper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (exceptionMapper != null) {
      return Provider<LdExceptionMapper>.value(
        value: exceptionMapper!,
        child: child,
      );
    }
    // If an exception mapper is already provided, don't override it.
    if (context.read<LdExceptionMapper?>() != null) {
      return child;
    }
    final localizations = LiquidLocalizations.of(context);
    return Provider(
      create: (context) => LdExceptionMapper(
        localizations: localizations,
      ),
      child: child,
    );
  }
}

/// A mapper that maps exceptions to LdExceptions that are displayed in the UI.
/// You can provide your own exception mapper to handle custom exceptions.
/// The default exception mapper will handle common exceptions like network errors.
class LdExceptionMapper {
  final LiquidLocalizations localizations;

  /// A function that can be used to handle custom exceptions. If the function
  /// returns a non-null LdException, it will be used instead of the default
  /// exception mapper. Otherwise, the default exception mapper will be used.
  /// This function will never be called if the exception is already an LdException.
  final LdException? Function(dynamic e, {StackTrace? stackTrace})? onException;

  const LdExceptionMapper({
    required this.localizations,
    this.onException,
  });

  static LdExceptionMapper of(BuildContext context) {
    return context.read<LdExceptionMapper>();
  }

  LdException handle(
    dynamic e, {
    StackTrace? stackTrace,
  }) {
    if (e is LdException) {
      return e;
    }

    if (onException != null) {
      final exception = onException!(e, stackTrace: stackTrace);
      if (exception != null) {
        return exception;
      }
    }

    final exception = LdException(
      message: localizations.unknownError,
      canRetry: true,
      stackTrace: stackTrace,
      moreInfo: e.toString(),
      exception: e,
    );

    if (e is SocketException) {
      return exception.copyWith(
        message: localizations.networkError,
      );
    }

    if (e is TimeoutException) {
      return exception.copyWith(
        message: localizations.timeoutError,
      );
    }

    if (e is FormatException) {
      return exception.copyWith(
        message: localizations.formatError,
      );
    }

    return exception;
  }
}
