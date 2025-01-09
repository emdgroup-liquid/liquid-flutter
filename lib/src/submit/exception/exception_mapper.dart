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
      // If an exception mapper is already provided, don't override it.
      if (context.read<LdExceptionMapper?>() != null) {
        return child;
      }

      return Provider<LdExceptionMapper>.value(
        value: exceptionMapper!,
        child: child,
      );
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

  const LdExceptionMapper({required this.localizations});

  static LdExceptionMapper of(BuildContext context) {
    return context.read<LdExceptionMapper>();
  }

  LdException? handle(dynamic e, {StackTrace? stackTrace}) {
    if (e is LdException) {
      return e;
    }

    if (e is SocketException) {
      return LdException(
        message: localizations.networkError,
        canRetry: true,
        stackTrace: stackTrace,
        moreInfo: e.toString(),
        exception: e,
      );
    }

    if (e is TimeoutException) {
      return LdException(
        message: localizations.timeoutError,
        canRetry: true,
        stackTrace: stackTrace,
        moreInfo: e.toString(),
        exception: e,
      );
    }

    if (e is FormatException) {
      return LdException(
        message: localizations.formatError,
        canRetry: true,
        stackTrace: stackTrace,
        moreInfo: e.toString(),
        exception: e,
      );
    }

    return LdException(
      message: localizations.unknownError,
      canRetry: true,
      stackTrace: stackTrace,
      moreInfo: e.toString(),
      exception: e,
    );
  }
}
