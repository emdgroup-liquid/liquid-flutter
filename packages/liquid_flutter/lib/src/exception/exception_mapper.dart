import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

typedef LdExceptionLocalizeFunction = LdLocalizedException? Function(
  BuildContext context,
  LdException e,
);

class LdExceptionLocalizer extends StatelessWidget {
  final Widget child;
  final LdExceptionLocalizeFunction onException;

  const LdExceptionLocalizer({
    super.key,
    required this.child,
    required this.onException,
  });

  @override
  Widget build(BuildContext context) {
    final parent = context.read<LdExceptionLocalizerMapper?>();

    return Provider(
      create: (context) => LdExceptionLocalizerMapper(
        onException: onException,
        parent: parent,
      ),
      child: child,
    );
  }
}

/// A mapper that maps exceptions to LdExceptions that are displayed in the UI.
/// You can provide your own exception mapper to handle custom exceptions.
/// The default exception mapper will handle common exceptions like network errors.
class LdExceptionLocalizerMapper {
  /// A function that can be used to handle custom exceptions. If the function
  /// returns a non-null LdException, it will be used instead of the default
  /// exception mapper. Otherwise, the default exception mapper will be used.
  /// This function will never be called if the exception is already an LdException.
  final LdExceptionLocalizeFunction onException;

  final LdExceptionLocalizerMapper? parent;

  const LdExceptionLocalizerMapper({
    required this.onException,
    this.parent,
  });

  static LdExceptionLocalizerMapper of(BuildContext context) {
    return context.read<LdExceptionLocalizerMapper>();
  }

  LdLocalizedException handle({
    required BuildContext context,
    required LdException e,
  }) {
    final result = onException(
      context,
      e,
    );

    if (result != null) {
      return result;
    }

    if (parent != null) {
      return parent!.handle(
        context: context,
        e: e,
      );
    }

    final localizations = LiquidLocalizations.of(context);

    final exception = LdLocalizedException(
      message: localizations.unknownError,
      canRetry: true,
      stackTrace: e.stackTrace ?? StackTrace.current,
      moreInfo: e.toString(),
      exception: e,
    );

    if (e.exception is SocketException) {
      return LdLocalizedException.fromLdException(
        exception: exception,
        message: localizations.networkError,
      );
    }

    if (e.exception is TimeoutException) {
      return LdLocalizedException.fromLdException(
        exception: exception,
        message: localizations.timeoutError,
      );
    }

    if (e.exception is FormatException) {
      return LdLocalizedException.fromLdException(
        exception: exception,
        message: localizations.formatError,
        moreInfo: e.exception.toString(),
      );
    }

    return exception;
  }
}
