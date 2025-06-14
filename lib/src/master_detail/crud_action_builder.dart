import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum LdCrudActionVisibility {
  standalone,
  contextMenu,
  appBar,
  appBarMulti,
  contextMenuMulti,
  standaloneMulti,
}

typedef LdCrudActionBuilder<T extends CrudItemMixin<T>> = Widget Function(
    LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction);

/// A builder that creates context-aware widgets based on the ancestor widget context.
/// Similar to Flutter's Builder widget but with built-in logic for different UI contexts.
///
/// It offers some default builders if you provide [actionIcon] and [actionText].
/// If you provide [appBarActionBuilder], [contextMenuActionBuilder], or [defaultBuilder], they will override the
/// default behavior.
class LdContextAwareCrudActionBuilder<T extends CrudItemMixin<T>> extends StatelessWidget {
  /// Builder function for app bar context
  final Widget Function(BuildContext context, VoidCallback triggerAction)? appBarActionBuilder;

  /// Builder function for context menu
  final Widget Function(BuildContext context, VoidCallback triggerAction)? contextMenuActionBuilder;

  /// Default builder function for other contexts
  final Widget Function(BuildContext context, VoidCallback triggerAction)? defaultBuilder;

  /// The action to trigger when the widget is interacted with
  final FutureOr<void> Function() triggerAction;

  /// The master detail state for accessing multi-select mode and other state
  final LdCrudMasterDetailState<T> masterDetail;

  /// Icon to use in the app bar and context menu default builders
  final IconData? actionIcon;

  /// Text to display in context menu and default button
  final String? actionText;

  /// Determines in which scenarios the action is visible
  final Set<LdCrudActionVisibility> visibility;

  /// The color of action
  final LdColor? color;

  const LdContextAwareCrudActionBuilder({
    super.key,
    required this.triggerAction,
    required this.masterDetail,
    this.appBarActionBuilder,
    this.contextMenuActionBuilder,
    this.defaultBuilder,
    this.actionIcon,
    this.actionText,
    this.visibility = const {
      LdCrudActionVisibility.standalone,
      LdCrudActionVisibility.contextMenu,
      LdCrudActionVisibility.appBar,
      LdCrudActionVisibility.appBarMulti,
      LdCrudActionVisibility.contextMenuMulti,
      LdCrudActionVisibility.standaloneMulti,
    },
    this.color,
  });

  factory LdContextAwareCrudActionBuilder.create({
    required LdCrudMasterDetailState<T> masterDetail,
    required VoidCallback triggerAction,
  }) {
    return LdContextAwareCrudActionBuilder(
      triggerAction: triggerAction,
      masterDetail: masterDetail,
      actionIcon: LucideIcons.circlePlus,
      actionText: LiquidLocalizations.of(masterDetail.context).createNew,
      visibility: const {
        LdCrudActionVisibility.standalone,
        LdCrudActionVisibility.appBar,
        LdCrudActionVisibility.contextMenu,
      },
    );
  }

  factory LdContextAwareCrudActionBuilder.edit({
    required LdCrudMasterDetailState<T> masterDetail,
    required VoidCallback triggerAction,
  }) {
    return LdContextAwareCrudActionBuilder(
      triggerAction: triggerAction,
      masterDetail: masterDetail,
      actionIcon: LucideIcons.pencil,
      actionText: LiquidLocalizations.of(masterDetail.context).edit,
      visibility: const {
        LdCrudActionVisibility.standalone,
        LdCrudActionVisibility.appBar,
        LdCrudActionVisibility.contextMenu,
      },
      color: LdTheme.of(masterDetail.context).primary,
    );
  }

  factory LdContextAwareCrudActionBuilder.delete({
    required LdCrudMasterDetailState<T> masterDetail,
    required VoidCallback triggerAction,
  }) {
    return LdContextAwareCrudActionBuilder(
      triggerAction: triggerAction,
      masterDetail: masterDetail,
      actionIcon: LucideIcons.trash2,
      actionText: LiquidLocalizations.of(masterDetail.context).delete,
      visibility: const {
        LdCrudActionVisibility.standalone,
        LdCrudActionVisibility.appBar,
        LdCrudActionVisibility.contextMenu,
      },
      color: LdTheme.of(masterDetail.context).error,
    );
  }

  factory LdContextAwareCrudActionBuilder.deleteMultiple({
    required LdCrudMasterDetailState<T> masterDetail,
    required VoidCallback triggerAction,
  }) {
    return LdContextAwareCrudActionBuilder(
      triggerAction: triggerAction,
      masterDetail: masterDetail,
      actionIcon: LucideIcons.listX,
      actionText: LiquidLocalizations.of(masterDetail.context).deleteSelected,
      visibility: const {
        LdCrudActionVisibility.standaloneMulti,
        LdCrudActionVisibility.appBarMulti,
        LdCrudActionVisibility.contextMenuMulti,
      },
      color: LdTheme.of(masterDetail.context).error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInMultiSelectMode = masterDetail.listState.isMultiSelectMode;
    final isInContextMenu = context.findAncestorWidgetOfExactType<LdContextMenu>() != null;
    final isInAppBar = context.findAncestorWidgetOfExactType<LdAppBar>() != null;

    LdCrudActionVisibility applicableMode;

    if (isInAppBar) {
      if (isInMultiSelectMode) {
        applicableMode = LdCrudActionVisibility.appBarMulti;
      } else {
        applicableMode = LdCrudActionVisibility.appBar;
      }
    } else if (isInContextMenu) {
      if (isInMultiSelectMode) {
        applicableMode = LdCrudActionVisibility.contextMenuMulti;
      } else {
        applicableMode = LdCrudActionVisibility.contextMenu;
      }
    } else {
      if (isInMultiSelectMode) {
        applicableMode = LdCrudActionVisibility.standaloneMulti;
      } else {
        applicableMode = LdCrudActionVisibility.standalone;
      }
    }

    if (!visibility.contains(applicableMode)) {
      return const SizedBox.shrink();
    }

    return switch (applicableMode) {
      (LdCrudActionVisibility.appBarMulti || LdCrudActionVisibility.appBar) =>
        appBarActionBuilder?.call(context, triggerAction) ??
            LdButtonGhost(
              color: color,
              onPressed: triggerAction,
              child: Icon(actionIcon),
            ),
      (LdCrudActionVisibility.contextMenuMulti || LdCrudActionVisibility.contextMenu) =>
        contextMenuActionBuilder?.call(context, triggerAction) ??
            LdListItem(
              onTap: triggerAction,
              title: Text(actionText ?? ""),
              leading: Icon(actionIcon, color: color?.center(LdTheme.of(context).isDark)),
            ),
      (LdCrudActionVisibility.standaloneMulti || LdCrudActionVisibility.standalone) =>
        defaultBuilder?.call(context, triggerAction) ??
            LdButton(
              child: Text(actionText ?? ""),
              onPressed: triggerAction,
            ),
    };
  }
}
