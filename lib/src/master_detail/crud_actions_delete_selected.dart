import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCrudDeleteSelectedAction<T extends CrudItemMixin<T>> extends LdCrudAction<T, List<T>, void> {
  LdCrudDeleteSelectedAction({
    super.key,
    String? confirmationMessage,
    LdCrudActionBuilder<T>? actionButtonBuilder,
  }) : super(
          builder: actionButtonBuilder ?? _defaultBuilder,
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

  static Widget _defaultBuilder<T extends CrudItemMixin<T>>(
      LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction) {
    return LdContextAwareCrudActionBuilder.deleteMultiple(masterDetail: masterDetail, triggerAction: triggerAction);
  }
}
