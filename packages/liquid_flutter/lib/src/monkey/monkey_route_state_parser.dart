import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyRouteStateParser {
  const LdMonkeyRouteStateParser._();

  static LdMonkeySelection<T, IdType> parseSelection<T extends Identifiable<IdType>, IdType>({
    required LdMonkeyRouteConfig<T, IdType> routeConfig,
    required Map<String, String> query,
    required Map<String, String> pathParameters,
  }) {
    return LdMonkeySelection<T, IdType>(
      selection: _parseIdsOrEmpty(routeConfig, query[routeConfig.selectionQueryKey]),
      viewing: _parseIdsOrEmpty(routeConfig, pathParameters[routeConfig.viewingParamName]),
      showSelectionControls: query[routeConfig.showSelectionControlsQueryKey] == 'true',
    );
  }

  static LdMonkeySortAndFilterState<T, IdType> parseSortAndFilter<T extends Identifiable<IdType>, IdType>({
    required LdMonkeyRouteConfig<T, IdType> routeConfig,
    required Iterable<LdFilterOption<T, IdType>> baseFilters,
    required Iterable<LdSortOption<T, IdType>> baseSortOptions,
    required Map<String, String> query,
  }) {
    final filters = baseFilters.map((filter) {
      final queryKey = routeConfig.filterQueryKey(filter.name);
      final serializedFilter = query[queryKey];
      if (serializedFilter == null) {
        return filter.copyWith(isOn: false);
      }
      return filter.marshalSerialized(serializedFilter);
    }).toSet();

    final sortOptionsLeft = baseSortOptions.map((sortOption) => sortOption.copyWith(isOn: false)).toList();
    final parsedSortOptions = <LdSortOption<T, IdType>>[];

    final sortQuery = query[routeConfig.sortQueryKey];
    if (sortQuery != null && sortQuery.isNotEmpty) {
      for (final sortEntry in sortQuery.split("_").toSet()) {
        final sortName = sortEntry.split("-")[0];
        final matchIndex = sortOptionsLeft.indexWhere((sortOption) => sortOption.name == sortName);
        if (matchIndex == -1) {
          continue;
        }

        final sortOption = sortOptionsLeft.removeAt(matchIndex);
        parsedSortOptions.add(sortOption.marshalSerialized(sortEntry));
      }
    }

    return LdMonkeySortAndFilterState<T, IdType>(
      filters: filters,
      sortOptions: [...parsedSortOptions, ...sortOptionsLeft],
    );
  }

  static Set<IdType> _parseIdsOrEmpty<T extends Identifiable<IdType>, IdType>(
    LdMonkeyRouteConfig<T, IdType> routeConfig,
    String? value,
  ) {
    if (value == null) {
      return <IdType>{};
    }
    return routeConfig.parseIdType(value);
  }
}
