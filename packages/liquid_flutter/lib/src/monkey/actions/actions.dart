import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';

import 'package:provider/provider.dart';

enum LdMonkeyActionLocation {
  masterAppBar,
  masterSecondary,
  detailAppBar,
  detailSecondary,
  context,
}

abstract class LdMonkeyAction<T extends Identifiable<IdType>, IdType> {
  final Set<LdMonkeyActionVisibility> visibility;

  final bool multiSelect;

  final Set<ShortcutActivator> shortcutActivators;

  Future<void> onShortcutPressed(BuildContext context);

  LdMonkeyAction({
    required this.visibility,
    this.multiSelect = true,
    this.shortcutActivators = const {},
  });

  bool isVisible(BuildContext context, {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();

    // Use viewing items for detail page actions, selection for master page actions

    if (!visibility.any((e) => e.location == location)) {
      return false;
    }

    return visibility.any((e) => e.isVisibleInContext<T, IdType>(context, location: location));
  }

  Widget build(BuildContext context);
}

class LdMonkeyBareChildAction<T extends Identifiable<IdType>, IdType> extends LdMonkeyAction<T, IdType> {
  final Widget Function(BuildContext context) builder;
  final FutureOr<void> Function(BuildContext context) onShortcutTrigger;

  @override
  Future<void> onShortcutPressed(BuildContext context) async {
    await onShortcutTrigger(context);
  }

  LdMonkeyBareChildAction({
    required this.builder,
    super.visibility = const {},
    super.multiSelect = true,
    super.shortcutActivators = const {},
    required this.onShortcutTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

class LdMonkeySubmitAction<T extends Identifiable<IdType>, IdType, Result> extends LdMonkeyAction<T, IdType> {
  final LdSubmitConfig<Result, void> Function(BuildContext context) config;
  final Widget? child;
  final Widget? icon;
  final LdColor? color;
  final String? Function(BuildContext context) tooltip;
  final LdSubmitBuilder<Result, BuildContext>? builder;

  LdSubmitController<Result, BuildContext>? controller;

  @override
  Future<void> onShortcutPressed(BuildContext context) async {
    // Todo: Implement shortcut trigger
  }

  LdMonkeySubmitAction({
    required this.config,
    this.child,
    this.icon,
    super.visibility = const {},
    super.multiSelect = true,
    super.shortcutActivators = const {},
    this.builder,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    assert(builder != null || (child != null), "You must provide a builder, child, or icon");
    return LdSubmit<Result, void>(
      config: config(context),
      child: builder ??
          LdSubmitNotificationBuilder<Result, void>(
            submitButtonBuilder: (submitButtonBuilder, controller) {
              return LdAppBarAction(
                color: color,
                loading: controller.state.type == LdSubmitStateType.loading,
                loadingText: config(context).loadingText,
                tooltip: tooltip(context),
                disabled: !controller.canTrigger,
                onPressed: () async {
                  await maybePopContextMenu(context);
                  await controller.trigger();
                },
                leading: icon,
                child: child!,
              );
            },
          ),
    );
  }
}

class OpenDrawerAction extends Action<OpenDrawerIntent> {
  final VoidCallback onOpenDrawer;

  OpenDrawerAction({required this.onOpenDrawer});

  @override
  void invoke(OpenDrawerIntent intent) {
    onOpenDrawer();
  }
}

class CloseDrawerAction extends Action<CloseDrawerIntent> {
  final VoidCallback onCloseDrawer;

  CloseDrawerAction({required this.onCloseDrawer});

  @override
  void invoke(CloseDrawerIntent intent) {
    onCloseDrawer();
  }
}

class ToggleDrawerAction extends Action<ToggleDrawerIntent> {
  final VoidCallback onToggleDrawer;

  final bool _isActionEnabled;

  ToggleDrawerAction({required this.onToggleDrawer, bool isActionEnabled = true}) : _isActionEnabled = isActionEnabled;

  @override
  bool get isActionEnabled {
    return _isActionEnabled;
  }

  @override
  void invoke(ToggleDrawerIntent intent) {
    onToggleDrawer();
  }
}
