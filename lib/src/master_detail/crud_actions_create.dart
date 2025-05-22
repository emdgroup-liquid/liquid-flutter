import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCrudCreateAction<T extends CrudItemMixin<T>> extends LdCrudAction<T, T, T> {
  LdCrudCreateAction({
    super.key,
    required FutureOr<T?> Function() getNewItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T newItem)? onItemCreated,
    LdCrudActionBuilder<T>? builder,
  }) : super(
          builder: builder ?? _defaultBuilder,
          action: (crud, newItem) => crud.create(newItem),
          onActionCompleted: (masterDetail, controller, arg, result) => onItemCreated?.call(masterDetail, result),
          obtainArg: (masterDetail, controller) async => getNewItem(),
        );

  static Widget _defaultBuilder<T extends CrudItemMixin<T>>(
      LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction) {
    return LdContextAwareCrudActionBuilder.create(masterDetail: masterDetail, triggerAction: triggerAction);
  }
}
