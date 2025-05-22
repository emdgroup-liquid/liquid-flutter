import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCrudDeleteAction<T extends CrudItemMixin<T>> extends LdCrudAction<T, T, void> {
  LdCrudDeleteAction({
    super.key,
    T? item,
    String? confirmationMessage,
    LdCrudActionBuilder<T>? builder,
  }) : super(
          builder: builder ?? _defaultBuilder,
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

  static Widget _defaultBuilder<T extends CrudItemMixin<T>>(
      LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction) {
    return LdContextAwareCrudActionBuilder.delete(masterDetail: masterDetail, triggerAction: triggerAction);
  }
}
