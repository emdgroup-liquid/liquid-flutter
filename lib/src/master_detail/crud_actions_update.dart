import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCrudUpdateAction<T extends CrudItemMixin<T>> extends LdCrudAction<T, T, T> {
  LdCrudUpdateAction({
    super.key,
    required FutureOr<T?> Function() getUpdatedItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T updatedItem)? onItemUpdated,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) : super(
          builder: actionButtonBuilder ?? LdCrudUpdateAction._defaultBuilder,
          action: (crud, newItem) => crud.update(newItem),
          onActionCompleted: (masterDetail, controller, arg, result) {
            if (controller.getOpenItem()?.id == arg.id) {
              controller.openItem(result); // refresh the open item
            }
            onItemUpdated?.call(masterDetail, result);
          },
          obtainArg: (masterDetail, controller) async => getUpdatedItem(),
        );

  static Widget _defaultBuilder<T extends CrudItemMixin<T>>(
      LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction) {
    return IconButton(
      onPressed: triggerAction,
      icon: const Icon(Icons.save),
    );
  }
}
