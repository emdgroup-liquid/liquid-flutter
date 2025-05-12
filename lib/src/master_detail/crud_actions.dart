import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdCrudActionLoadingStyle { dialog, actionBar }

/// A builder for a widget that can be used to perform an action on a master detail item
/// or a list of master detail items.
///
/// The builder is called with a function that performs the action.
/// The function is called with the arguments of the action.
typedef LdCrudActionWidgetBuilder = Widget Function(
  Function performActionCallback,
);

/// The definition of a callback for an action that can be used to perform an action on a master detail item
/// or a list of master detail items.
typedef LdCrudActionCallback<T extends CrudItemMixin<T>, Arg>
    = FutureOr<dynamic> Function(
  Arg arg, {
  required BuildContext context,
  required LdMasterDetailController<T> controller,
  required LdCrudListState<T> listState,
  required LdCrudOperations<T> crud,
});

/// A master detail action contains a widget that can be used to perform an action on a master detail item
/// or a list of master detail items.
///
/// It can be used to provide UI for actions like create, update, delete, etc.
///
/// The action is executed optimistically, meaning that the new state of the item
/// is immediately reflected in [CrudListState#getItemOptimistically].
///
/// If the action is successful, the item is updated in the list.
/// If the action fails, the item state is set to [CrudItemStateEvent.error].
class LdMasterDetailAction<T extends CrudItemMixin<T>, Arg> {
  final LdCrudActionWidgetBuilder? kebabMenuBuilder;
  final LdCrudActionWidgetBuilder? masterActionBarIconBuilder;
  final LdCrudActionWidgetBuilder? masterActionMultiSelectBarIconBuilder;
  final LdCrudActionWidgetBuilder? detailActionBarIconBuilder;
  final LdCrudActionCallback<T, Arg> onAction;
  final bool showErrorNotification;
  final String? errorMessage;

  const LdMasterDetailAction({
    this.kebabMenuBuilder,
    this.masterActionBarIconBuilder,
    this.masterActionMultiSelectBarIconBuilder,
    this.detailActionBarIconBuilder,
    required this.onAction,
    this.showErrorNotification = true,
    this.errorMessage,
  }) : assert(
          kebabMenuBuilder != null ||
              masterActionBarIconBuilder != null ||
              masterActionMultiSelectBarIconBuilder != null ||
              detailActionBarIconBuilder != null,
        );

  static Future<R> optimisticExecution<T extends CrudItemMixin<T>, R>(
    T item,
    Future<R> Function() crudAction,
    LdCrudListState<T> listState, {
    required BuildContext context,
    T Function(R result)? parseResult,
    bool showErrorNotification = true,
    String? errorMessage,
  }) async {
    listState.handleItemStateEvent(item, CrudItemStateEvent.loading(item));
    try {
      final result = await crudAction();
      // if R is not void and result is null, throw an exception
      if (result == null && R == T) {
        throw LdException(message: "Operation failed");
      }
      listState.handleItemStateEvent(
        item,
        result == null
            ? CrudItemStateEvent.deleted()
            : CrudItemStateEvent.success(
                parseResult?.call(result) ?? result as T,
              ),
      );
      return result;
    } catch (error) {
      listState.handleItemStateEvent(
        item,
        CrudItemStateEvent.error(error),
      );

      // Show error notification if configured and context is available
      if (showErrorNotification) {
        _showErrorNotification(
          context,
          LdException.fromDynamic(context, error),
          errorMessage,
        );
      }

      rethrow;
    }
  }

  static void _showErrorNotification(
    BuildContext context,
    LdException error,
    String? customErrorMessage,
  ) async {
    final notificationsController = LdNotificationsController.of(context);
    const defaultErrorMessage = 'An error occurred during the operation';
    final notification = LdConfirmNotification(
      message: customErrorMessage ?? defaultErrorMessage,
      type: LdNotificationType.error,
      confirmText: 'Close',
      cancelText: 'More info',
      duration: const Duration(seconds: 5),
    );

    notificationsController.addNotification(notification);
    if (await notification.confirmationCompleter.future == false) {
      LdExceptionDialog(error: error).show(context);
    }
  }
}

class LdMasterDetailListAction<T extends CrudItemMixin<T>>
    extends LdMasterDetailAction<T, List<T?>> {
  const LdMasterDetailListAction({
    super.kebabMenuBuilder,
    super.masterActionBarIconBuilder,
    super.masterActionMultiSelectBarIconBuilder,
    super.detailActionBarIconBuilder,
    required super.onAction,
  });

  factory LdMasterDetailListAction.newItemAction({
    required Future<T?> Function() getNewItem,
    LdMasterDetailCrudItemCallback<T>? onItemCreated,
  }) {
    return LdMasterDetailListAction<T>(
      masterActionBarIconBuilder: (actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.add),
        );
      },
      onAction: (
        List<T?> list, {
        required BuildContext context,
        required LdMasterDetailController<T> controller,
        required LdCrudListState<T> listState,
        required LdCrudOperations<T> crud,
      }) async {
        final newItem = await getNewItem();
        if (newItem == null) return false;
        await LdMasterDetailAction.optimisticExecution<T, T>(
                newItem, () => crud.create(newItem), listState,
                context: context)
            .then((createdItem) {
          onItemCreated?.call(createdItem);
        });
        return true;
      },
    );
  }

  factory LdMasterDetailListAction.batchDeleteItems({
    LdMasterDetailCrudItemCallback<T>? onItemDeleted,
    Future<void> Function(List<T?>)? onItemsDeleted,
  }) {
    return LdMasterDetailListAction<T>(
      masterActionMultiSelectBarIconBuilder: (actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.delete_forever),
        );
      },
      onAction: (
        List<T?> list, {
        required BuildContext context,
        required LdMasterDetailController<T> controller,
        required LdCrudListState<T> listState,
        required LdCrudOperations<T> crud,
      }) async {
        final itemsToDeleteIds = list.map((e) => e?.id).toSet();
        final newList = listState.items
            .where((e) => !itemsToDeleteIds.contains(e?.id))
            .toList();

        // set list busy in general
        listState.handleItemStateEvent(
          null,
          CrudItemStateEvent.loading(),
        );
        for (final item in list) {
          if (item == null) continue;
          // set item busy
          listState.handleItemStateEvent(
            item,
            CrudItemStateEvent.loading(item),
          );
        }
        try {
          await crud.batchDelete(list.map((e) => e!));
          for (final item in list) {
            if (item == null) continue;
            // remove all items from list
            listState.handleItemStateEvent(
              item,
              CrudItemStateEvent.deleted(),
            );
            onItemDeleted?.call(item);
          }
          onItemsDeleted?.call(newList);
          listState.toggleMultiSelectMode(forceValue: false);
        } catch (e) {
          // set list error
          listState.handleItemStateEvent(
            null,
            CrudItemStateEvent.error(e as LdException),
          );
        }
      },
    );
  }
}

class LdMasterDetailItemAction<T extends CrudItemMixin<T>>
    extends LdMasterDetailAction<T, T> {
  const LdMasterDetailItemAction({
    super.kebabMenuBuilder,
    super.masterActionBarIconBuilder,
    super.masterActionMultiSelectBarIconBuilder,
    super.detailActionBarIconBuilder,
    required super.onAction,
  });

  factory LdMasterDetailItemAction.deleteItem({
    LdMasterDetailCrudItemCallback<T>? onItemDeleted,
  }) {
    return LdMasterDetailItemAction(
      detailActionBarIconBuilder: (actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.delete),
        );
      },
      onAction: (
        T item, {
        required BuildContext context,
        required LdMasterDetailController<T> controller,
        required LdCrudListState<T> listState,
        required LdCrudOperations<T> crud,
      }) async {
        await LdMasterDetailAction.optimisticExecution<T, void>(
          item,
          () async => await crud.delete(item),
          listState,
          context: context,
        ).then((value) {
          onItemDeleted?.call(item);
          if (controller.getOpenItem()?.id == item.id) {
            controller.closeItem();
          }
        });
        return true;
      },
    );
  }

  factory LdMasterDetailItemAction.updateItem({
    required Future<T?> Function(T) getNewItem,
    LdCrudActionWidgetBuilder? detailActionBarIconBuilder,
    LdMasterDetailCrudItemCallback<T>? onItemUpdated,
  }) {
    return LdMasterDetailItemAction(
      detailActionBarIconBuilder: detailActionBarIconBuilder ??
          (actionCallback) {
            return IconButton(
              onPressed: () => actionCallback(),
              icon: const Icon(Icons.edit),
            );
          },
      onAction: (
        T item, {
        required BuildContext context,
        required LdMasterDetailController<T> controller,
        required LdCrudListState<T> listState,
        required LdCrudOperations<T> crud,
      }) async {
        final newItem = await getNewItem(item);
        if (newItem == null) return false;
        await LdMasterDetailAction.optimisticExecution<T, T>(
          item,
          () => crud.update(newItem),
          listState,
          context: context,
        ).then((updatedItem) {
          onItemUpdated?.call(updatedItem);
          if (updatedItem.id == controller.getOpenItem()?.id) {
            controller.openItem(updatedItem);
          }
          return updatedItem;
        });
        return true;
      },
    );
  }
}
