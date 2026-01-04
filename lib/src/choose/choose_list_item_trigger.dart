import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/intersperse.dart';

class LdChooseListItemTrigger<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdChooseListItemTrigger({
    required this.config,
    this.separator,
    super.key,
  });

  final LdChooseTriggerConfig<T, IdType> config;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    final selectedIds = config.selectedIds;
    final selectedItems = config.selectedItems;
    final truncateDisplay = config.truncateDisplay;
    final selectedItemsCount = selectedIds.length;

    int displayItems = selectedItems.length;
    int left = 0;

    displayItems = min(displayItems, truncateDisplay);
    left = selectedItemsCount - displayItems;

    return LdListItem.trailingForward(
      disabled: config.disabled,
      onPressed: config.onTap,
      title: Text(config.label),
      subtitle: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          if (selectedItemsCount == 0) config.hint!,
          ...config.selectedItems
              .sublist(0, displayItems)
              .map((item) => config.selectedItemBuilder(context, item))
              .intersperse(separator ?? const Text(", "))
              .toList(),
          if (left > 0)
            Text(
              " +$left",
            )
        ],
      ),
    );
  }
}
