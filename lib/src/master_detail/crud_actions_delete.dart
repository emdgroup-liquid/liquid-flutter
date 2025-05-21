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
    return Builder(
      builder: (context) {
        final isInAppBar = context.findAncestorWidgetOfExactType<LdAppBar>() != null;
        if (isInAppBar) {
          return IconButton(
            onPressed: triggerAction,
            icon: const Icon(Icons.delete),
          );
        }

        final isInContextMenu = context.findAncestorWidgetOfExactType<LdContextMenu>() != null;
        if (isInContextMenu) {
          return LdListItem(
            onTap: triggerAction,
            title: Text(LiquidLocalizations.of(context).delete),
            leading: const Icon(Icons.delete),
          );
        }

        return LdButton(
          child: Text(LiquidLocalizations.of(context).delete),
          onPressed: triggerAction,
        );
      },
    );
  }
}
