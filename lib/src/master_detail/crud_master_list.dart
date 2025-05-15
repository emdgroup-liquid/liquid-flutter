import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A wrapper around [LdSelectableList] that handles selection and item actions based
/// on the [LdCrudListState] of a [LdCrudMasterDetail]. It can be a good fit
/// for a master list in a [LdCrudMasterDetail].
///
/// For more complex use cases, you might want to use a custom master list
/// implementation.
class LdCrudMasterList<T extends CrudItemMixin<T>> extends StatelessWidget {
  final T? openItem;
  final LdMasterDetailController<T> controller;
  final LdCrudListState<T> listState;
  final Widget Function(BuildContext context, T item, T optimisticItem) titleBuilder;
  final Widget Function(BuildContext context, T item, T optimisticItem)? subtitleBuilder;
  final Widget Function(BuildContext context, T item, T optimisticItem)? subContentBuilder;
  final Widget Function(BuildContext context, T item, T optimisticItem)? leadingBuilder;
  final Widget Function(BuildContext context, T item, T optimisticItem)? trailingBuilder;
  final double assumedItemHeight;
  final bool isSeparatePage;

  const LdCrudMasterList({
    super.key,
    required this.controller,
    required this.titleBuilder,
    required this.listState,
    this.openItem,
    this.isSeparatePage = false,
    this.subtitleBuilder,
    this.subContentBuilder,
    this.leadingBuilder,
    this.trailingBuilder,
    this.assumedItemHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    final showSelectionControls = listState.isMultiSelectMode;
    return LdSelectableList<T, void>(
      multiSelect: true,
      paginator: listState,
      onSelectionChange: (selectedItems) {
        if (selectedItems.length == 1) {
          controller.openItem(selectedItems.first);
          return;
        }
        listState.updateItemSelection(selectedItems);
      },
      listBuilder: (context, scrollController, itemBuilder) {
        return LdList<T, void>(
          paginator: listState,
          assumedItemHeight: assumedItemHeight,
          scrollController: scrollController,
          itemBuilder: itemBuilder,
        );
      },
      itemBuilder: ({
        required BuildContext context,
        required T item,
        required int index,
        required bool selected,
        required bool isMultiSelect,
        required void Function(bool selected) onSelectionChange,
        required VoidCallback onTap,
      }) {
        final isActive = (openItem?.id ?? controller.getOpenItem()?.id) == item.id;
        final optimisticItem = listState.getItemOptimistically(item);

        return LdListItem(
          trailingForward: isSeparatePage,
          active: isActive,
          isSelected: selected,
          showSelectionControls: showSelectionControls,
          onTap: onTap,
          onLongPress: () {
            onTap();
            listState.updateItemSelection({item});
          },
          onSelectionChange: onSelectionChange,
          title: titleBuilder(context, item, optimisticItem),
          subtitle: subtitleBuilder?.call(context, item, optimisticItem),
          subContent: subContentBuilder?.call(context, item, optimisticItem),
          leading: leadingBuilder?.call(context, item, optimisticItem),
          trailing: Row(
            children: [
              if (listState.isItemLoading(item)) const LdLoader(size: 20),
              ldSpacerXS,
              trailingBuilder?.call(context, item, optimisticItem) ?? const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
