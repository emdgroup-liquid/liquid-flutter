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

    final shellState = LdMonkeyShellState.of<T, IdType>(context, watch: true);
    final repository = LdRepository.of<T, IdType>(context);
    final selection = LdMonkeySelection.adaptive<T, IdType>(context, location: location);

    final effectiveLayoutMode = context.read<LdMonkeyEffectiveLayoutMode>();

    // Use viewing items for detail page actions, selection for master page actions

    if (!visibility.any((e) => e.location == location)) {
      return false;
    }

    final selectedItems = selection.map((e) => repository.getItemById(e)).whereType<LdPaginatorItem<T>>().toList();

    for (final visibility in this.visibility) {
      if (visibility.location != location) continue;

      if (!visibility.layoutModes.contains(effectiveLayoutMode)) {
        continue;
      }
      if (visibility.visibleWhenShowingSelectionControls == false && shellState.showSelectionControls) {
        return false;
      }

      if (visibility.applyFilters.isNotEmpty) {
        final filters = visibility.applyFilters.map(
          (filterName) => repository.filters[filterName]!,
        );

        for (final filter in filters) {
          if (selectedItems.any((e) => !filter.optimisticFilter(e.value!))) {
            return false;
          }
        }
      }

      if ((visibility.maxSelectionCount == null || selection.length <= visibility.maxSelectionCount!) &&
          selection.length >= visibility.minSelectionCount) {
        return true;
      }
    }

    return false;
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
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    assert(builder != null || (child != null), "You must provide a builder, child, or icon");
    return LdSubmit<Result, void>(
      config: config(context),
      builder: builder ??
          LdSubmitNotificationBuilder<Result, void>(
            submitButtonBuilder: (submitButtonBuilder, controller) {
              return LdAppBarAction(
                color: color,
                loading: controller.state.type == LdSubmitStateType.loading,
                loadingText: config(context).loadingText,
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
