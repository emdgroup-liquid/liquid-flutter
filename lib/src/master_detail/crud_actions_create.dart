import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCrudCreateAction<T extends CrudItemMixin<T>> extends LdCrudAction<T, T, T> {
  LdCrudCreateAction({
    super.key,
    required FutureOr<T?> Function() getNewItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T newItem)? onItemCreated,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) : super(
          builder: actionButtonBuilder ?? _defaultBuilder,
          action: (crud, newItem) => crud.create(newItem),
          onActionCompleted: (masterDetail, controller, arg, result) => onItemCreated?.call(masterDetail, result),
          obtainArg: (masterDetail, controller) async => getNewItem(),
        );

  static Widget _defaultBuilder<T extends CrudItemMixin<T>>(
      LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction) {
    return masterDetail.listState.selectedItemCount > 0
        ? const SizedBox.shrink()
        : IconButton(
            onPressed: triggerAction,
            icon: const Icon(Icons.add),
          );
  }
}
