import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum ActionLoadingStyle { dialog, actionBar }

enum ActionDisplayModes {
  masterActionBar,
  detailActionBar,
}

typedef ActionCallback<T extends CrudItemMixin<T>, Arg> = FutureOr<dynamic>
    Function(Arg arg, LdCrudMasterDetailController<T> controller);

class LdMasterDetailAction<T extends CrudItemMixin<T>, Arg> {
  final Widget Function(Function actionCallback) childBuilder;
  final Set<ActionDisplayModes> displayModes;
  final ActionCallback<T, Arg> onAction;

  const LdMasterDetailAction({
    required this.childBuilder,
    required this.displayModes,
    required this.onAction,
  });
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
        LdCrudMasterDetailController<T> controller,
      ) async {
        final newItem = await getNewItem();
        if (newItem != null) {
          await controller.executeCrudOperation<T>(
            newItem,
            () => controller.crud.create(newItem),
          );
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
        LdCrudMasterDetailController<T> controller,
      ) async {
        await controller.executeCrudOperation<void>(
          item,
          () => controller.crud.delete(item),
        );
        onItemDeleted?.call(item);
        if (controller.getOpenItem()?.id == item.id) {
          controller.onCloseItem();
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
        LdCrudMasterDetailController<T> controller,
      ) async {
        final newItem = await getNewItem(item);
        final itemResult = await controller.executeCrudOperation<T>(
          item,
          () => controller.crud.update(newItem!),
        );
        onItemUpdated?.call(item);
        if (itemResult.id == controller.getOpenItem()?.id) {
          controller.onOpenItem(itemResult);
        }
        return true;
      },
    );
  }
}
