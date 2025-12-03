import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A callback that triggers the action
typedef LdSubmitCallback<T, Arg> = Future<T> Function(Arg? arg);

typedef LdSubmitResultBuilder<T, Arg> = Widget Function(
  BuildContext context,
  T result,
  LdSubmitController<T, Arg> controller,
);

typedef LdSubmitButtonBuilder<T, Arg> = Widget Function(
  BuildContext submitButtonBuilder,
  LdSubmitController<T, Arg> controller,
);

typedef LdSubmitLoadingBuilder<T, Arg> = Widget Function(
  BuildContext submitLoadingBuilder,
  LdSubmitController<T, Arg> controller,
);

typedef LdSubmitErrorBuilder<T, Arg> = Widget Function(
  BuildContext context,
  LdException exception,
  LdSubmitController<T, Arg> controller,
);

enum LdSubmitStateType { idle, loading, error, result }

// Builder for the submitting widget
abstract class LdSubmitBuilder<T, Arg> extends StatelessWidget {
  final LdSubmitResultBuilder<T, Arg>? resultBuilder;
  final LdSubmitButtonBuilder<T, Arg>? submitButtonBuilder;
  final LdSubmitLoadingBuilder<T, Arg>? loadingBuilder;
  final LdSubmitErrorBuilder<T, Arg>? errorBuilder;

  const LdSubmitBuilder({
    Key? key,
    this.resultBuilder,
    this.submitButtonBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);
}

/// A component that handles making requests and displaying errors.
/// You can use this component to wrap around a button that makes a request.
/// It will handle the loading state and display errors.
/// It also has a default exception mapper that will handle common exceptions.
/// You can also provide your own exception mapper.
/// The default builder is a button that will display a loading spinner when loading.
class LdSubmit<T, Arg> extends StatefulWidget {
  final LdSubmitConfig<T, Arg>? config;
  final LdSubmitController<T, Arg>? controller;
  final Widget? builder;
  final Arg? arg;

  const LdSubmit({
    super.key,
    this.arg,
    this.config,
    this.controller,

    /// Will default to [LdSubmitInlineBuilder] if not provided
    this.builder,
  });

  @override
  State<LdSubmit<T, Arg>> createState() => _LdSubmitState<T, Arg>();
}

class _LdSubmitState<T, Arg> extends State<LdSubmit<T, Arg>> {
  Widget get submitBuilder => widget.builder ?? LdSubmitInlineBuilder<T, Arg>();

  late final _argNotifier = ValueNotifier<Arg?>(widget.arg);

  LdSubmitController<T, Arg>? _controller;
  bool _createdController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _controller = LdSubmitController<T, Arg>(config: widget.config!, arg: _argNotifier);
      _createdController = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller?.init();
    });
  }

  @override
  void didUpdateWidget(covariant LdSubmit<T, Arg> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.arg is Set && widget.arg is Set) {
      if (!setEquals(oldWidget.arg as Set, widget.arg as Set)) {
        _argNotifier.value = widget.arg;
      }
    } else {
      if (_argNotifier.value != widget.arg || oldWidget.arg != widget.arg) {
        _argNotifier.value = widget.arg;
      }
    }

    if (widget.config != oldWidget.config) {
      if (_createdController) {
        _controller?.dispose();
        _createdController = false;
      }
      _controller = LdSubmitController<T, Arg>(
        config: widget.config!,
        arg: _argNotifier,
      );
      _createdController = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("init controller, due to config change");
        _controller?.init();
      });
    }
  }

  @override
  void dispose() {
    _argNotifier.dispose();
    super.dispose();
  }

  Widget _buildProvider(BuildContext context) {
    return Provider.value(
      value: _controller,
      child: submitBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.config != null || widget.controller != null,
      "You must provide either a config or a controller",
    );

    return LdExceptionMapperProvider(
      child: _buildProvider(context),
    );
  }
}
