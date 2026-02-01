import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyActionVisibility {
  final LdMonkeyActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool? visibleWhenShowingSelectionControls;
  final Set<LdMonkeyEffectiveLayoutMode> layoutModes;

  final bool Function(BuildContext context)? isVisible;

  final Set<String> applyFilters;

  LdMonkeyActionVisibility({
    required this.location,
    this.minSelectionCount = 0,
    this.maxSelectionCount,
    this.applyFilters = const {},
    this.layoutModes = const {
      LdMonkeyEffectiveLayoutMode.master,
      LdMonkeyEffectiveLayoutMode.detail,
      LdMonkeyEffectiveLayoutMode.sideBySide,
    },
    this.visibleWhenShowingSelectionControls,
    this.isVisible,
  });

  bool isVisibleInContext<T extends Identifiable<IdType>, IdType>(BuildContext context,
      {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();
    if (isVisible != null) {
      if (!isVisible!(context)) {
        return false;
      }
    }

    final shellState = LdMonkeyShellState.of<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);
    final selection = LdMonkeySelection.adaptive<T, IdType>(context, location: location);
    final selectedItems = selection.map((e) => repository.getItemById(e)).whereType<LdPaginatorItem<T>>().toList();

    if (location != this.location) {
      return false;
    }

    if (!layoutModes.contains(context.read<LdMonkeyEffectiveLayoutMode>())) {
      return false;
    }

    if (visibleWhenShowingSelectionControls == false && shellState.showSelectionControls) {
      return false;
    }

    if ((maxSelectionCount != null && selection.length > maxSelectionCount!) ||
        (minSelectionCount != 0 && selection.length < minSelectionCount)) {
      return false;
    }

    if (applyFilters.isNotEmpty) {
      final filters = applyFilters.map(
        (filterName) => repository.filters[filterName]!,
      );

      for (final filter in filters) {
        if (selectedItems.any((e) => !filter.optimisticFilter(e.value!))) {
          return false;
        }
      }
    }

    return true;
  }
}
