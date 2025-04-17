import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A wrapper around [LdList] that handles selection and item actions.
class LdCrudMasterList<T extends CrudItemMixin<T>> extends StatelessWidget {
  final LdCrudMasterDetailController<T> controller;
  final Widget Function(BuildContext context, T item) titleBuilder;
  final Widget Function(BuildContext context, T item)? subtitleBuilder;
  final Widget Function(BuildContext context, T item)? subContentBuilder;
  final double assumedItemHeight;
  final bool isSeparatePage;

  const LdCrudMasterList({
    super.key,
    required this.controller,
    required this.titleBuilder,
    this.isSeparatePage = false,
    this.subtitleBuilder,
    this.subContentBuilder,
    this.assumedItemHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    final showSelectionControls = controller.data.isMultiSelectMode;
    return LdList<T, void>(
      data: controller.data,
      assumedItemHeight: assumedItemHeight,
      itemBuilder: (context, item, index) {
        final isSelected = controller.data.isItemSelected(item);
        final isActive = controller.getOpenItem()?.id == item.id;

        return LdListItem(
          trailingForward: isSeparatePage,
          active: isActive,
          isSelected: isSelected,
          showSelectionControls: showSelectionControls,
          onTap: () => controller.onOpenItem(item),
          onSelectionChange: (selected) {
            controller.data.toggleItemSelection(item);
          },
          onLongPress: () {
            controller.data.toggleMultiSelectMode();
            if (controller.data.isMultiSelectMode) {
              controller.data.toggleItemSelection(item);
            }
          },
          title: titleBuilder(context, item),
          subtitle: subtitleBuilder?.call(context, item),
          subContent: subContentBuilder?.call(context, item),
        );
      },
    );
  }
}
