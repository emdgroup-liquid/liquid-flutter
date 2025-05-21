import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    if (masterDetail.listState.selectedItemCount == 0) {
      return const SizedBox.shrink();
    }

    return Builder(
      builder: (context) {
        if (context.findAncestorWidgetOfExactType<LdAppBar>() != null) {
          return IconButton(
            onPressed: triggerAction,
            icon: const Icon(LucideIcons.listX),
          );
        }

        if (context.findAncestorWidgetOfExactType<LdContextMenu>() != null) {
          return LdListItem(
            onTap: triggerAction,
            title: Text(LiquidLocalizations.of(context).deleteSelected),
            leading: const Icon(LucideIcons.listX),
          );
        }

        return LdButton(
          child: Text(LiquidLocalizations.of(context).deleteSelected),
          onPressed: triggerAction,
        );
      },
    );
  }
}
