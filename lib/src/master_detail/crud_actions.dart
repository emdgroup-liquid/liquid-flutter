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
  Arg arg,
  LdMasterDetailController<T> controller,
  LdCrudListState<T> listState,
  LdCrudOperations<T> crud,
);

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

  const LdMasterDetailAction({
    this.kebabMenuBuilder,
    this.masterActionBarIconBuilder,
    this.masterActionMultiSelectBarIconBuilder,
    this.detailActionBarIconBuilder,
    required this.onAction,
  }) : assert(
          kebabMenuBuilder != null ||
              masterActionBarIconBuilder != null ||
              masterActionMultiSelectBarIconBuilder != null ||
              detailActionBarIconBuilder != null,
        );

  static Stream<R>
      executeOperationOptimistically<T extends CrudItemMixin<T>, R>(
    T item,
    Future<R> Function() operation,
    LdCrudListState<T> listState, {
    T Function(R result)? parseResult,
  }) async* {
    listState.handleItemStateEvent(item.id, CrudItemStateEvent.loading(item));
    try {
      final result = await operation();
      // if R is not void and result is null, throw an exception
      if (result == null && R == T) {
        throw LdException(message: "Operation failed");
      }
      listState.handleItemStateEvent(
        item.id,
        result == null
            ? CrudItemStateEvent.deleted()
            : CrudItemStateEvent.success(
                parseResult?.call(result) ?? result as T,
              ),
      );
      yield result;
    } catch (e) {
      listState.handleItemStateEvent(
        item.id,
        CrudItemStateEvent.error(e as LdException),
      );
      yield* Stream.error(e);
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
        List<T?> list,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        final newItem = await getNewItem();
        if (newItem == null) return false;
        await LdMasterDetailAction.executeOperationOptimistically<T, T>(
          newItem,
          () => crud.create(newItem),
          listState,
        ).first;
        onItemCreated?.call(newItem);
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
        List<T?> list,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        final itemsToDeleteIds = list.map((e) => e?.id).toSet();
        final newList = listState.items
            .where((e) => !itemsToDeleteIds.contains(e?.id))
            .toList();

        // set list busy in general
        listState.handleItemStateEvent(
          null,
          CrudItemStateEvent.loading(),
        );
        try {
          await crud.batchDelete(list.map((e) => e!));
          for (final item in list) {
            if (item == null) continue;
            // remove all items from list
            listState.handleItemStateEvent(
                item.id, CrudItemStateEvent.deleted());
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
        T item,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        await LdMasterDetailAction.executeOperationOptimistically<T, void>(
          item,
          () async => await crud.delete(item),
          listState,
        ).first;
        onItemDeleted?.call(item);
        if (controller.getOpenItem()?.id == item.id) {
          controller.closeItem();
        }
        return true;
      },
    );
  }

  factory LdMasterDetailItemAction.updateItem({
    required Future<T?> Function(T) getNewItem,
    LdMasterDetailCrudItemCallback<T>? onItemUpdated,
  }) {
    return LdMasterDetailItemAction(
      detailActionBarIconBuilder: (actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.edit),
        );
      },
      onAction: (
        T item,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        final newItem = await getNewItem(item);
        if (newItem == null) return false;
        final itemResult =
            await LdMasterDetailAction.executeOperationOptimistically<T, T>(
          item,
          () => crud.update(newItem),
          listState,
        ).first;
        onItemUpdated?.call(item);
        if (itemResult.id == controller.getOpenItem()?.id) {
          controller.openItem(itemResult);
        }
        return true;
      },
    );
  }
}
