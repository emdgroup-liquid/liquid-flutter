import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Settings to configure the behavior of CRUD actions.
/// [showLoadingDialog] controls whether to show a loading dialog during the action.
/// [errorNotificationMessage] is a message to be displayed in case of an error.
/// You can customize these settings when creating a [LdCrudAction].
/// The default settings (from [LdCrudMasterDetail]) are used if not provided.
class LdCrudActionSettings {
  final bool showLoadingDialog;
  final String? errorNotificationMessage;

  const LdCrudActionSettings({
    this.showLoadingDialog = true,
    this.errorNotificationMessage,
  });
}

typedef LdCrudActionBuilder<T extends CrudItemMixin<T>> = Widget Function(
    LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction);

/// A widget that provides a CRUD action button for a [LdCrudMasterDetail].
/// It handles the action logic and provides a button to trigger the action.
///
/// There are several predefined actions available, such as [createItem], [updateItem],
/// [deleteItem], and [deleteSelectedItems].
///
/// You can also create custom actions by providing your own [action] and [obtainArg].
///
/// When the button is pressed, it will first obtain the argument using [obtainArg],
/// then trigger the action using [action]. If the action is successful, it will
/// call [onActionCompleted] with the result.
///
/// It uses [LdSubmit] to handle the loading state and error handling.
class LdCrudAction<T extends CrudItemMixin<T>, Arg, Result> extends StatefulWidget {
  final LdCrudActionBuilder<T> builder;
  final FutureOr<Arg?> Function(LdCrudMasterDetailState<T> masterDetail, LdMasterDetailController<T> controller)
      obtainArg;
  final FutureOr<Result> Function(LdCrudOperations<T> crud, Arg arg) action;
  final Function(
          LdCrudMasterDetailState<T> masterDetail, LdMasterDetailController<T> controller, Arg arg, Result result)?
      onActionCompleted;
  final LdCrudActionSettings? settings;

  /// Creates a new action for CRUD operations.
  /// [Arg] must be either [T] or [Iterable<T>].
  const LdCrudAction({
    required this.builder,
    required this.action,
    required this.obtainArg,
    this.onActionCompleted,
    this.settings,
    super.key,
  }) : assert(Arg == T || Arg == List<T>, 'Arg must be either T or Iterable<T> or List<T>');

  @override
  State<LdCrudAction<T, Arg, Result>> createState() => _LdCrudActionState<T, Arg, Result>();

  static LdCrudAction<T, T, T> createItem<T extends CrudItemMixin<T>>({
    required FutureOr<T?> Function() getNewItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T newItem)? onItemCreated,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, T, T>(
      builder: actionButtonBuilder ??
          (masterDetail, triggerAction) => masterDetail.listState.selectedItemCount > 0
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: triggerAction,
                  icon: const Icon(Icons.add),
                ),
      action: (crud, newItem) => crud.create(newItem),
      onActionCompleted: (masterDetail, controller, arg, result) => onItemCreated?.call(masterDetail, result),
      obtainArg: (masterDetail, controller) async => getNewItem(),
    );
  }

  static LdCrudAction<T, T, T> updateItem<T extends CrudItemMixin<T>>({
    required FutureOr<T?> Function() getUpdatedItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T updatedItem)? onItemUpdated,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, T, T>(
      builder: actionButtonBuilder ??
          (context, triggerAction) => IconButton(
                onPressed: triggerAction,
                icon: const Icon(LucideIcons.save),
              ),
      action: (crud, newItem) => crud.update(newItem),
      onActionCompleted: (masterDetail, controller, arg, result) {
        if (controller.getOpenItem()?.id == arg.id) {
          controller.openItem(result); // refresh the open item
        }
        onItemUpdated?.call(masterDetail, result);
      },
      obtainArg: (masterDetail, controller) async => getUpdatedItem(),
    );
  }

  static LdCrudAction<T, T, void> deleteItem<T extends CrudItemMixin<T>>({
    /// The item to be deleted. If null, the currently open item will be used.
    T? item,
    String? confirmationMessage,
    LdCrudActionBuilder<T>? builder,
  }) {
    defaultBuilder(masterDetail, triggerAction) => Builder(
          builder: (context) {
            final isInAppBar = context.findAncestorWidgetOfExactType<LdAppBar>() != null;
            if (isInAppBar) {
              return IconButton(
                onPressed: triggerAction,
                icon: const Icon(LucideIcons.trash),
              );
            }

            final isInContextMenu = context.findAncestorWidgetOfExactType<LdContextMenu>() != null;
            if (isInContextMenu) {
              return LdListItem(
                onTap: triggerAction,
                title: Text(LiquidLocalizations.of(context).delete),
                leading: const Icon(LucideIcons.trash),
              );
            }

            return LdButton(child: Text(LiquidLocalizations.of(context).delete), onPressed: triggerAction);
          },
        );
    return LdCrudAction<T, T, void>(
      builder: builder ?? defaultBuilder,
      action: (crud, item) => crud.delete(item),
      onActionCompleted: (masterDetail, controller, arg, result) {
        if (controller.getOpenItem()?.id == arg.id) {
          controller.closeItem();
        }
      },
      obtainArg: (masterDetail, controller) async {
        if (confirmationMessage?.isNotEmpty ?? false) {
          final confirmed = await LdNotificationsController.of(masterDetail.context).confirm(confirmationMessage!);
          if (confirmed != true) return null;
        }
        return item ?? controller.getOpenItem();
      },
    );
  }

  static LdCrudAction<T, List<T>, void> deleteSelectedItems<T extends CrudItemMixin<T>>({
    String? confirmationMessage,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) {
    defaultBuilder(masterDetail, triggerAction) => Builder(
          builder: (context) {
            if (masterDetail.listState.selectedItemCount == 0) {
              return const SizedBox.shrink();
            }

            final isInAppBar = context.findAncestorWidgetOfExactType<LdAppBar>() != null;
            if (isInAppBar) {
              return IconButton(
                onPressed: triggerAction,
                icon: const Icon(LucideIcons.listX),
              );
            }

            final isInContextMenu = context.findAncestorWidgetOfExactType<LdContextMenu>() != null;
            if (isInContextMenu) {
              return LdListItem(
                onTap: triggerAction,
                title: Text(LiquidLocalizations.of(context).deleteSelected),
                leading: const Icon(LucideIcons.listX),
              );
            }

            return LdButton(child: Text(LiquidLocalizations.of(context).deleteSelected), onPressed: triggerAction);
          },
        );

    return LdCrudAction<T, List<T>, void>(
      builder: actionButtonBuilder ?? defaultBuilder,
      action: (crud, items) => crud.batchDelete(items),
      onActionCompleted: (masterDetail, controller, arg, result) {
        masterDetail.listState.updateItemSelection({});
        final openItem = controller.getOpenItem();
        if (openItem != null && arg.any((item) => item.id == openItem.id)) {
          controller.closeItem();
        }
      },
      obtainArg: (masterDetail, controller) async {
        if (confirmationMessage?.isNotEmpty ?? false) {
          final confirmed = await LdNotificationsController.of(masterDetail.context).confirm(confirmationMessage!);
          if (confirmed != true) return null;
        }
        return masterDetail.listState.selectedItems.toList();
      },
    );
  }
}

class _LdCrudActionState<T extends CrudItemMixin<T>, Arg, Result> extends State<LdCrudAction<T, Arg, Result>> {
  Arg? _obtainedArg;
  LdSubmitController<Result>? _submitController;

  @override
  Widget build(BuildContext context) {
    final masterDetail = context.read<LdCrudMasterDetailState<T>>();
    final controller = context.read<LdMasterDetailController<T>>();
    final actionSettings = widget.settings ?? masterDetail.widget.defaultActionSettings;
    final ldSubmitBuilder = actionSettings.showLoadingDialog
        ? LdSubmitDialogBuilder<Result>(
            submitButtonBuilder: (submitButtonContext, submitController) =>
                _buildSubmitButton(masterDetail, controller, submitController))
        : LdSubmitInlineBuilder<Result>(
            submitButtonBuilder: (submitButtonContext, submitController) =>
                _buildSubmitButton(masterDetail, controller, submitController),
            errorBuilder: (context, exception, submitController) => _buildErrorButton(context, submitController),
          );

    return LdSubmit<Result>(
      builder: ldSubmitBuilder,
      config: LdSubmitConfig<Result>(
        action: () async {
          final arg = _obtainedArg;
          if (arg == null) {
            throw LdException(message: "Operation failed: No argument available");
          }

          final listState = masterDetail.listState;
          _handleArgEvent(listState, arg, LdSubmitStateType.loading, data: arg);
          try {
            final result = await widget.action(
              masterDetail.crud,
              arg,
            );
            _handleArgEvent(listState, arg, LdSubmitStateType.result, data: result);
            widget.onActionCompleted?.call(masterDetail, controller, arg, result);
            return result;
          } catch (error) {
            _handleArgEvent(listState, arg, LdSubmitStateType.error, error: error);
            if (actionSettings.errorNotificationMessage?.isNotEmpty ?? false) {
              final notification = LdConfirmNotification(
                message: actionSettings.errorNotificationMessage!,
                type: LdNotificationType.error,
                confirmText: LiquidLocalizations.of(context).moreInfo,
              );
              LdNotificationsController.of(context).addNotification(notification);
              notification.confirmationCompleter.future.then((confirmed) {
                if (confirmed == true) _showErrorDialog(context);
              });
            }
            rethrow;
          }
        },
      ),
    );
  }

  Widget _buildSubmitButton(
    LdCrudMasterDetailState<T> masterDetail,
    LdMasterDetailController<T> masterDetailController,
    LdSubmitController<Result> submitController,
  ) {
    _submitController = submitController;
    return widget.builder(masterDetail, () async {
      // Get and store the argument immediately before triggering
      final obtainedArg = await widget.obtainArg(masterDetail, masterDetailController);
      if (obtainedArg == null) return;
      _obtainedArg = obtainedArg;
      submitController.trigger();
    });
  }

  Widget _buildErrorButton(
    BuildContext context,
    LdSubmitController<Result> submitController,
  ) {
    _submitController = submitController;
    return LdButtonVague(
      onPressed: () => _showErrorDialog(context),
      child: const Icon(LucideIcons.x),
      color: LdTheme.of(context).error,
    );
  }

  void _showErrorDialog(
    BuildContext context,
  ) {
    LdModal(
      modalContent: (context) => LdExceptionView(
        exception: _submitController!.state.error!,
        retryController: _submitController!.retryController,
      ),
      title: Text(LiquidLocalizations.of(context).errorOccurred),
      userCanDismiss: true,
      onDismiss: () => _submitController!.reset(),
    ).show(context);
  }

  /// Passes a [CrudItemStateEvent] to the [listState] for the given [arg] and (optional) [result].
  /// If [arg] is a single item, it will pass the event to that item.
  /// If [arg] is a list of items, it will pass the event to each item in the list.
  /// If [arg] is null, it will pass the event to the list state itself.
  void _handleArgEvent(
    LdCrudListState<T> listState,
    Arg arg,
    LdSubmitStateType eventType, {
    dynamic data,
    dynamic error,
  }) {
    if (arg is T) {
      listState.handleItemStateEvent(arg, CrudItemStateEvent<T>(type: eventType, result: data, error: error));
      return;
    }
    if (arg is Iterable<T>) {
      if (data is Iterable<T>) {
        for (final item in arg) {
          listState.handleItemStateEvent(
            item,
            CrudItemStateEvent<T>(type: eventType, result: data.firstWhere((e) => e.id == item.id)),
          );
        }
        return;
      }
      for (final item in arg) {
        listState.handleItemStateEvent(
          item,
          CrudItemStateEvent<T>(type: eventType, result: data, error: error),
        );
      }
      return;
    }
    listState.handleItemStateEvent(null, CrudItemStateEvent<T>(type: eventType, result: data, error: error));
  }
}
