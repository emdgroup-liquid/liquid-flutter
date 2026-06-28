import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';


enum LdMonkeyActionLocation {
  masterAppBar,
  masterSecondary,
  detailAppBar,
  detailSecondary,
  context,
}

abstract class LdMonkeyAction<T extends Identifiable<IdType>, IdType> {
  final Set<LdMonkeyActionVisibility<T, IdType>> visibility;

  final bool multiSelect;

  final Set<ShortcutActivator> shortcutActivators;

  /// Whether this action's app bar trigger may move into the overflow menu.
  ///
  /// See [LdAppBarActionOverflowMode].
  final LdAppBarActionOverflowMode appBarOverflowMode;

  LdMonkeyAction({
    Set<LdMonkeyActionVisibility<T, IdType>>? visibility,
    this.multiSelect = true,
    this.shortcutActivators = const {},
    this.appBarOverflowMode = LdAppBarActionOverflowMode.overflowable,
  }) : visibility = visibility ?? <LdMonkeyActionVisibility<T, IdType>>{};

  bool isVisible(BuildContext context, {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();

    if (!visibility.any((e) => e.location == location)) {
      return false;
    }

    return visibility.any((e) => e.isVisibleInContext(context, location: location));
  }

  Future<void> onShortcutPressed(BuildContext triggerContext, LdMonkeyActionScope<T, IdType> scope);

  Widget buildTrigger(BuildContext triggerContext, LdMonkeyActionScope<T, IdType> scope);
}

class LdMonkeyBareChildAction<T extends Identifiable<IdType>, IdType> extends LdMonkeyAction<T, IdType> {
  final Widget Function(LdMonkeyActionContext<T, IdType> ctx, Future<void> Function() trigger) builder;
  final FutureOr<void> Function(LdMonkeyActionContext<T, IdType> ctx) onTrigger;

  LdMonkeyBareChildAction({
    required this.builder,
    super.visibility,
    super.multiSelect = true,
    super.shortcutActivators = const {},
    super.appBarOverflowMode = LdAppBarActionOverflowMode.overflowable,
    required this.onTrigger,
  });

  LdMonkeyActionContext<T, IdType>? _actionContext(
    BuildContext triggerContext,
    LdMonkeyActionScope<T, IdType> scope,
  ) {
    final appContext = scope.appContext;
    if (appContext == null) {
      return null;
    }
    return LdMonkeyActionContext.of<T, IdType>(triggerContext, appContext: appContext);
  }

  Future<void> _invokeTrigger(
    BuildContext triggerContext,
    LdMonkeyActionScope<T, IdType> scope,
  ) async {
    final appContext = scope.appContext;
    if (appContext == null) {
      return;
    }
    await maybePopContextMenu(triggerContext);
    if (!triggerContext.mounted) {
      return;
    }
    final ctx = LdMonkeyActionContext.of<T, IdType>(triggerContext, appContext: appContext);
    await onTrigger(ctx);
  }

  @override
  Future<void> onShortcutPressed(
    BuildContext triggerContext,
    LdMonkeyActionScope<T, IdType> scope,
  ) async {
    await _invokeTrigger(triggerContext, scope);
  }

  @override
  Widget buildTrigger(BuildContext triggerContext, LdMonkeyActionScope<T, IdType> scope) {
    final ctx = _actionContext(triggerContext, scope);
    if (ctx == null) {
      return const SizedBox.shrink();
    }
    return builder(ctx, () => _invokeTrigger(triggerContext, scope));
  }
}

class LdMonkeySubmitAction<T extends Identifiable<IdType>, IdType, Result> extends LdMonkeyAction<T, IdType> {
  final Object id;
  final LdMonkeySubmitConfig Function(BuildContext appContext) submitConfig;
  final Future<Result> Function(LdMonkeyActionContext<T, IdType> ctx) onSubmit;
  final Widget? child;
  final Widget Function(BuildContext triggerContext)? childBuilder;
  final Widget? icon;
  final LdColor Function(BuildContext context)? color;
  final String? Function(BuildContext context) tooltip;
  final LdSubmitBuilder<Result, LdMonkeyActionContext<T, IdType>>? builder;

  LdMonkeySubmitAction({
    required this.id,
    required this.submitConfig,
    required this.onSubmit,
    this.child,
    this.childBuilder,
    this.icon,
    super.visibility,
    super.multiSelect = true,
    super.shortcutActivators = const {},
    super.appBarOverflowMode = LdAppBarActionOverflowMode.overflowable,
    this.builder,
    required this.tooltip,
    this.color,
  });

  Future<void> _invokeSubmit(
    BuildContext triggerContext,
    LdMonkeyActionScope<T, IdType> scope,
  ) async {
    final controller = scope.submitController<Result>(id);
    final appContext = scope.appContext;
    if (controller == null || appContext == null) {
      return;
    }
    await maybePopContextMenu(triggerContext);
    if (!triggerContext.mounted) {
      return;
    }
    final ctx = LdMonkeyActionContext.of<T, IdType>(triggerContext, appContext: appContext);
    controller.arg!.value = ctx;
    await controller.trigger();
  }

  @override
  Future<void> onShortcutPressed(
    BuildContext triggerContext,
    LdMonkeyActionScope<T, IdType> scope,
  ) async {
    await _invokeSubmit(triggerContext, scope);
  }

  Widget buildHost(BuildContext appContext, LdMonkeyActionScope<T, IdType> scope) {
    return _LdMonkeySubmitActionHost<T, IdType, Result>(
      action: this,
      appContext: appContext,
      scope: scope,
    );
  }

  @override
  Widget buildTrigger(BuildContext triggerContext, LdMonkeyActionScope<T, IdType> scope) {
    assert(builder != null || (child != null || childBuilder != null),
        "You must provide a builder, child, or childBuilder");
    final controller = scope.submitController<Result>(id);
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LdAppBarAction(
          color: color?.call(triggerContext),
          loading: controller.state.type == LdSubmitStateType.loading,
          loadingText: controller.config.loadingText,
          tooltip: tooltip(triggerContext),
          disabled: !controller.canTrigger,
          onPressed: () => _invokeSubmit(triggerContext, scope),
          leading: icon,
          child: childBuilder?.call(triggerContext) ?? child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _LdMonkeySubmitActionHost<T extends Identifiable<IdType>, IdType, Result> extends StatefulWidget {
  const _LdMonkeySubmitActionHost({
    required this.action,
    required this.appContext,
    required this.scope,
  });

  final LdMonkeySubmitAction<T, IdType, Result> action;
  final BuildContext appContext;
  final LdMonkeyActionScope<T, IdType> scope;

  @override
  State<_LdMonkeySubmitActionHost<T, IdType, Result>> createState() =>
      _LdMonkeySubmitActionHostState<T, IdType, Result>();
}

class _LdMonkeySubmitActionHostState<T extends Identifiable<IdType>, IdType, Result>
    extends State<_LdMonkeySubmitActionHost<T, IdType, Result>> {
  LdSubmitController<Result, LdMonkeyActionContext<T, IdType>>? _controller;

  @override
  void dispose() {
    if (_controller != null) {
      widget.scope.unregisterSubmit(widget.action.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.action.submitConfig(widget.appContext).toSubmitConfig<T, IdType, Result>(
          onSubmit: widget.action.onSubmit,
        );

    return LdSubmit<Result, LdMonkeyActionContext<T, IdType>>(
      config: config,
      child: widget.action.builder ??
          LdSubmitNotificationBuilder<Result, LdMonkeyActionContext<T, IdType>>(
            submitButtonBuilder: (_, controller) {
              _registerController(controller);
              return const SizedBox.shrink();
            },
          ),
    );
  }

  void _registerController(LdSubmitController<Result, LdMonkeyActionContext<T, IdType>> controller) {
    if (!identical(_controller, controller)) {
      if (_controller != null) {
        widget.scope.unregisterSubmit(widget.action.id);
      }
      _controller = controller;
      widget.scope.registerSubmit(widget.action.id, controller);
    }
  }
}
