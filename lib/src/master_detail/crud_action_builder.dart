import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  final VoidCallback triggerAction;

  /// The master detail state for accessing multi-select mode and other state
  final LdCrudMasterDetailState<T> masterDetail;

  /// Icon to use in the app bar and context menu default builders
  final IconData? actionIcon;

  /// Text to display in context menu and default button
  final String? actionText;

  /// Icon to use in the app bar context
  final bool hideInAppBarInSingleSelectMode;

  /// Whether to hide the widget in single-select mode when in context menu
  final bool hideInContextMenuInSingleSelectMode;

  /// Whether to hide the widget in single-select mode when in app bar
  final bool? hideInAppBarInMultiSelectMode;

  /// Whether to hide the widget in multi-select mode when in context menu
  final bool? hideInContextMenuInMultiSelectMode;

  const LdContextAwareCrudActionBuilder({
    super.key,
    required this.triggerAction,
    required this.masterDetail,
    this.appBarActionBuilder,
    this.contextMenuActionBuilder,
    this.defaultBuilder,
    this.actionIcon,
    this.actionText,
    this.hideInAppBarInSingleSelectMode = false,
    this.hideInContextMenuInSingleSelectMode = false,
    this.hideInAppBarInMultiSelectMode,
    this.hideInContextMenuInMultiSelectMode,
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
      hideInAppBarInSingleSelectMode: false,
      hideInContextMenuInSingleSelectMode: false,
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
      hideInContextMenuInMultiSelectMode: true,
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
      hideInContextMenuInMultiSelectMode: true,
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
      hideInAppBarInSingleSelectMode: true,
      hideInContextMenuInSingleSelectMode: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInMultiSelectMode = masterDetail.listState.isMultiSelectMode;

    // Check if we're in an app bar context
    final isInAppBar = context.findAncestorWidgetOfExactType<LdAppBar>() != null;
    if (isInAppBar) {
      if (appBarActionBuilder != null) {
        return appBarActionBuilder!(context, triggerAction);
      }

      if (hideInAppBarInSingleSelectMode && !isInMultiSelectMode ||
          ((hideInAppBarInMultiSelectMode ?? !hideInAppBarInSingleSelectMode) && isInMultiSelectMode)) {
        return const SizedBox.shrink();
      }

      return IconButton(
        onPressed: triggerAction,
        icon: Icon(actionIcon),
      );
    }

    // Check if we're in a context menu
    final isInContextMenu = context.findAncestorWidgetOfExactType<LdContextMenu>() != null;
    if (isInContextMenu) {
      if (contextMenuActionBuilder != null) {
        return contextMenuActionBuilder!(context, triggerAction);
      }

      if (hideInContextMenuInSingleSelectMode && !isInMultiSelectMode ||
          ((hideInContextMenuInMultiSelectMode ?? !hideInContextMenuInSingleSelectMode) && isInMultiSelectMode)) {
        return const SizedBox.shrink();
      }

      return LdListItem(
        onTap: triggerAction,
        title: Text(actionText ?? ""),
        leading: Icon(actionIcon),
      );
    }

    // Default context
    if (defaultBuilder != null) {
      return defaultBuilder!(context, triggerAction);
    }

    return LdButton(
      child: Text(actionText ?? ""),
      onPressed: triggerAction,
    );
  }
}
