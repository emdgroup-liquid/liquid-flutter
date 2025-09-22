import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

enum LdMonkeyActionLocation {
  masterAppBar,
  masterSecondary,
  detailAppBar,
  detailSecondary,
  context,
}

class LdMonkeyAction<T extends Identifiable<IdType>, IdType> extends LdLabeledActionBuilder {
  final Set<LdMonkeyActionVisibility> visibility;

  LdMonkeySelection<T, IdType> selection(BuildContext context) {
    return LdMonkeySelection.of<T, IdType>(context);
  }

  @override
  bool isVisible(BuildContext context, {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();

    final isSideBySide = LdMonkeyContext.of<T, IdType>(context).isSideBySide;

    final route = LdMonkey.of<T, IdType>(context);

    final selection = LdMonkeySelection.of<T, IdType>(context, listen: false);

    final selectedItemCount = selection.items.length;

    if (!visibility.any((e) => e.location == location)) {
      return false;
    }

    final selectedItems =
        selection.items.map((e) => route.repository.getItemById(e)).whereType<LdPaginatorItem<T>>().toList();

    for (final visibility in this.visibility) {
      if (visibility.location != location) continue;

      if (isSideBySide && !visibility.visibleInSplitView) {
        continue;
      }

      if (visibility.applyFilters.isNotEmpty) {
        final filters = visibility.applyFilters.map(
          (filterName) => route.repository.filters.firstWhere((e) => e.name == filterName),
        );

        for (final filter in filters) {
          if (selectedItems.any((e) => !filter.optimisticFilter(e.value!))) {
            return false;
          }
        }
      }

      if ((visibility.maxSelectionCount == null || selectedItemCount <= visibility.maxSelectionCount!) &&
          selectedItemCount >= visibility.minSelectionCount) {
        return true;
      }
    }

    return false;
  }

  final bool multiSelect;

  LdMonkeyAction({
    required this.visibility,
    required super.buildLabel,
    required super.buildIcon,
    required super.action,
    super.buildLoadingText,
    super.buildContextMenu,
    super.color,
    super.isActive,
    super.submitType = LdLabeledActionType.notification,
    this.multiSelect = true,
    this.shortcutActivators = const {},
  });

  final Set<ShortcutActivator> shortcutActivators;
}
