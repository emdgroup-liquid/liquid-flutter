import 'dart:async';

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
    super.key,
    this.resultBuilder,
    this.submitButtonBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });
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
  final Widget? child;
  final bool? disabled;
  final Arg? arg;
  final bool Function(Arg? oldArg, Arg? newArg)? argEquals;

  /// An optional exception mapper scoped to this [LdSubmit] instance.
  ///
  /// This lets you localize exceptions that only occur in this specific
  /// submit action without mounting a separate [LdExceptionLocalizer]
  /// widget above it. Because it is applied inside this widget's own
  /// subtree, it will never be visible to sibling widgets or unrelated
  /// descendants elsewhere on the page.
  ///
  /// If this returns `null` (or is not provided), lookup falls back to any
  /// ancestor [LdExceptionLocalizer] and finally to the built-in default
  /// mapper, same as [LdExceptionLocalizer]'s own chaining behavior.
  final LdExceptionLocalizeFunction? onException;

  const LdSubmit({
    super.key,
    this.arg,
    this.config,
    this.controller,
    this.disabled,

    /// Will default to [LdSubmitInlineBuilder] if not provided
    this.child,
    this.argEquals,
    this.onException,
  });

  @override
  State<LdSubmit<T, Arg>> createState() => _LdSubmitState<T, Arg>();
}

class _LdSubmitState<T, Arg> extends State<LdSubmit<T, Arg>> {
  Widget get submitBuilder => widget.child ?? LdSubmitInlineBuilder<T, Arg>();

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
    if (widget.disabled != null) {
      _controller?.disabled = widget.disabled!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller?.init();
    });
  }

  @override
  void didUpdateWidget(covariant LdSubmit<T, Arg> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.argEquals != null) {
      if (!widget.argEquals!(oldWidget.arg, widget.arg)) {
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
        _controller?.init();
      });
    }

    if (widget.disabled != oldWidget.disabled && widget.disabled != null) {
      _controller?.disabled = widget.disabled!;
    }
  }

  @override
  void dispose() {
    _argNotifier.dispose();
    if (_createdController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  Widget _buildProvider(BuildContext context) {
    final provider = ListenableProvider.value(
      value: _controller,
      child: submitBuilder,
    );

    final onException = widget.onException;
    if (onException == null) {
      return provider;
    }

    return LdExceptionLocalizer(
      onException: onException,
      child: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.config != null || widget.controller != null,
      "You must provide either a config or a controller",
    );

    return _buildProvider(context);
  }
}
