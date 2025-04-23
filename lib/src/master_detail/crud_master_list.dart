import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A wrapper around [LdList] that handles selection and item actions based
/// on the [LdCrudListState] of a [LdCrudMasterDetail]. It can be a good fit
/// for a master list in a [LdCrudMasterDetail].
///
/// For more complex use cases, you might want to use a custom master list
/// implementation.
class LdCrudMasterList<T extends CrudItemMixin<T>> extends StatelessWidget {
  final LdCrudListState<T> data;
  final T? openItem;
  final LdMasterDetailController<T> controller;
  final Widget Function(BuildContext context, T item) titleBuilder;
  final Widget Function(BuildContext context, T item)? subtitleBuilder;
  final Widget Function(BuildContext context, T item)? subContentBuilder;
  final double assumedItemHeight;
  final bool isSeparatePage;

  const LdCrudMasterList({
    super.key,
    required this.data,
    required this.controller,
    required this.titleBuilder,
    this.openItem,
    this.isSeparatePage = false,
    this.subtitleBuilder,
    this.subContentBuilder,
    this.assumedItemHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    final showSelectionControls = data.isMultiSelectMode;
    return LdList<T, void>(
      data: data,
      assumedItemHeight: assumedItemHeight,
      itemBuilder: (context, item, index) {
        final isSelected = data.isItemSelected(item);
        final isActive = openItem?.id == item.id;

        return LdListItem(
          trailingForward: isSeparatePage,
          active: isActive,
          isSelected: isSelected,
          showSelectionControls: showSelectionControls,
          onTap: () => controller.openItem(item),
          onSelectionChange: (selected) {
            data.toggleItemSelection(item);
          },
          onLongPress: () {
            data.toggleMultiSelectMode();
            if (data.isMultiSelectMode) {
              data.toggleItemSelection(item);
            }
          },
          title: titleBuilder(context, item),
          subtitle: subtitleBuilder?.call(context, item),
          subContent: subContentBuilder?.call(context, item),
          trailing: data.isItemLoading(item) ? const LdLoader(size: 24) : null,
        );
      },
    );
  }
}
