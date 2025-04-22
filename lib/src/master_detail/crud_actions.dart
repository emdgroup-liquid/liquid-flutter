import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum ActionLoadingStyle { dialog, actionBar }

enum ActionDisplayModes {
  masterActionBar,
  detailActionBar,
  kebabMenu,
}

typedef ActionCallback<T extends CrudItemMixin<T>, Arg> = FutureOr<dynamic>
    Function(
  Arg arg,
  LdMasterDetailController<T> controller,
  LdCrudListState<T> listState,
  LdCrudOperations<T> crud,
);

class LdMasterDetailAction<T extends CrudItemMixin<T>, Arg> {
  final Widget Function(Function actionCallback) childBuilder;
  final Set<ActionDisplayModes> displayModes;
  final ActionCallback<T, Arg> onAction;

  const LdMasterDetailAction({
    required this.childBuilder,
    required this.displayModes,
    required this.onAction,
  });

  static Stream<R> optimisticExecution<T extends CrudItemMixin<T>, R>(
      T item, Future<R> Function() operation, LdCrudListState<T> listState,
      {T Function(R result)? parseResult}) async* {
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
    required super.childBuilder,
    required super.displayModes,
    required super.onAction,
  });

  factory LdMasterDetailListAction.newItemAction({
    required Future<T?> Function() getNewItem,
    LdMasterDetailCrudItemCallback<T>? onItemCreated,
  }) {
    return LdMasterDetailListAction<T>(
      childBuilder: (Function actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.add),
        );
      },
      displayModes: {
        ActionDisplayModes.masterActionBar,
      },
      onAction: (
        List<T?> list,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        final newItem = await getNewItem();
        if (newItem != null) {
          await LdMasterDetailAction.optimisticExecution<T, T>(
            newItem,
            () => crud.create(newItem),
            listState,
          ).first;
          onItemCreated?.call(newItem);
          return true;
        }
        return false;
      },
    );
  }
}

class LdMasterDetailItemAction<T extends CrudItemMixin<T>>
    extends LdMasterDetailAction<T, T> {
  const LdMasterDetailItemAction({
    required Widget Function(Function actionCallback) childBuilder,
    Set<ActionDisplayModes> displayModes = const {
      ActionDisplayModes.detailActionBar
    },
    required ActionCallback<T, T> onAction,
  }) : super(
          childBuilder: childBuilder,
          displayModes: displayModes,
          onAction: onAction,
        );

  factory LdMasterDetailItemAction.deleteItem({
    LdMasterDetailCrudItemCallback<T>? onItemDeleted,
  }) {
    return LdMasterDetailItemAction(
      childBuilder: (Function actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.delete),
        );
      },
      displayModes: {
        ActionDisplayModes.detailActionBar,
      },
      onAction: (
        T item,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        await LdMasterDetailAction.optimisticExecution<T, void>(
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
      childBuilder: (Function actionCallback) {
        return IconButton(
          onPressed: () => actionCallback(),
          icon: const Icon(Icons.edit),
        );
      },
      displayModes: {
        ActionDisplayModes.detailActionBar,
      },
      onAction: (
        T item,
        LdMasterDetailController<T> controller,
        LdCrudListState<T> listState,
        LdCrudOperations<T> crud,
      ) async {
        final newItem = await getNewItem(item);
        final itemResult = await LdMasterDetailAction.optimisticExecution<T, T>(
          item,
          () => crud.update(newItem!),
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
