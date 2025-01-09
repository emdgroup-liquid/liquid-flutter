import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A callback that triggers the action
typedef LdSubmitCallback<T> = Future<T> Function();

typedef LdSubmitResultBuilder<T> = Widget Function(
  BuildContext context,
  T result,
  LdSubmitController<T> controller,
);

typedef LdSubmitButtonBuilder<T> = Widget Function(
  BuildContext submitButtonBuilder,
  LdSubmitController<T> controller,
);

typedef LdSubmitLoadingBuilder<T> = Widget Function(
  BuildContext submitLoadingBuilder,
  LdSubmitController<T> controller,
);

typedef LdSubmitErrorBuilder<T> = Widget Function(
  BuildContext context,
  LdException exception,
  LdSubmitController<T> controller,
);

enum LdSubmitStateType { idle, loading, error, result }

// Builder for the submitting widget
abstract class LdSubmitBuilder<T> extends StatelessWidget {
  final LdSubmitResultBuilder<T>? resultBuilder;
  final LdSubmitButtonBuilder<T>? submitButtonBuilder;
  final LdSubmitLoadingBuilder<T>? loadingBuilder;
  final LdSubmitErrorBuilder<T>? errorBuilder;

  const LdSubmitBuilder(
      {Key? key,
      this.resultBuilder,
      this.submitButtonBuilder,
      this.loadingBuilder,
      this.errorBuilder})
      : super(key: key);
}

/// A component that handles making requests and displaying errors.
/// You can use this component to wrap around a button that makes a request.
/// It will handle the loading state and display errors.
/// It also has a default exception mapper that will handle common exceptions.
/// You can also provide your own exception mapper.
/// The default builder is a button that will display a loading spinner when loading.
class LdSubmit<T> extends StatelessWidget {
  final LdSubmitConfig<T>? config;
  final LdSubmitController<T>? controller;
  final Widget? builder;

  const LdSubmit({
    super.key,
    this.config,
    this.controller,

    /// Will default to [LdSubmitInlineBuilder] if not provided
    this.builder,
  });

  Widget get submitBuilder => builder ?? LdSubmitInlineBuilder<T>();

  Widget _buildProvider(BuildContext context) {
    if (controller != null) {
      return Provider.value(
        value: controller,
        child: FutureBuilder(
          future: controller!.init(),
          builder: (context, snapshot) {
            return submitBuilder;
          },
        ),
      );
    }

    return Provider<LdSubmitController<T>>(
      create: (context) {
        final controller = LdSubmitController<T>(
          config: config!,
          exceptionMapper: LdExceptionMapper.of(context),
        );

        // Add post frame callback to trigger the action
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.init();
        });

        return controller;
      },
      dispose: (context, controller) => controller.dispose(),
      child: submitBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      config != null || controller != null,
      "You must provide either a config or a controller",
    );

    return LdExceptionMapperProvider(
      child: _buildProvider(context),
    );
  }
}
