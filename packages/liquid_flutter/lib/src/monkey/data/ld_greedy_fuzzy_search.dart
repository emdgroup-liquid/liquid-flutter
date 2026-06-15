import 'package:fuzzy/fuzzy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef LdSearchTextExtractor<T> = String Function(T item);

FuzzyOptions<T> _defaultFuzzyOptions<T>(LdSearchTextExtractor<T> searchText) {
  return FuzzyOptions<T>(
    keys: [
      WeightedKey<T>(
        name: 'text',
        getter: searchText,
        weight: 1,
      ),
    ],
    threshold: 0.4,
  );
}

/// Fuzzy-matches [items] against [query] using [searchText].
List<T> ldFuzzySearchItems<T>({
  required List<T> items,
  required String query,
  required LdSearchTextExtractor<T> searchText,
  FuzzyOptions<T>? options,
}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty || items.isEmpty) {
    return items;
  }

  final fuse = Fuzzy<T>(
    items,
    options: options ?? _defaultFuzzyOptions(searchText),
  );

  return fuse.search(trimmed).map((result) => result.item).toList();
}

/// Applies active [LdFilterSearch] from [filters] (default name `search`).
List<T> ldFuzzySearchFromFilters<T extends Identifiable<IdType>, IdType>({
  required List<T> items,
  required Set<LdFilterOption<T, IdType>> filters,
  required LdSearchTextExtractor<T> searchText,
  String searchFilterName = 'search',
  FuzzyOptions<T>? options,
}) {
  LdFilterSearch<T, IdType, dynamic>? searchFilter;
  for (final filter in filters) {
    if (filter.name == searchFilterName && filter is LdFilterSearch<T, IdType, dynamic>) {
      searchFilter = filter;
      break;
    }
  }

  if (searchFilter == null || !searchFilter.isOn || searchFilter.searchText.trim().isEmpty) {
    return items;
  }

  return ldFuzzySearchItems<T>(
    items: items,
    query: searchFilter.searchText,
    searchText: searchText,
    options: options,
  );
}

/// Composable wrapper for greedy repository [fetchListWithParameters].
Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters)
    ldGreedyFetchWithFuzzySearch<T extends Identifiable<IdType>, IdType>({
  required Future<List<T>> Function(FetchPageParameters<T, IdType> parameters) loadItems,
  required LdSearchTextExtractor<T> searchText,
  String searchFilterName = 'search',
  FuzzyOptions<T>? options,
}) {
  return (FetchPageParameters<T, IdType> parameters) async {
    final allItems = await loadItems(parameters);
    final filtered = ldFuzzySearchFromFilters<T, IdType>(
      items: allItems,
      filters: parameters.filters,
      searchText: searchText,
      searchFilterName: searchFilterName,
      options: options,
    );

    return LdListPage<T>(
      newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
      hasMore: parameters.offset + parameters.pageSize < filtered.length,
      total: filtered.length,
    );
  };
}

Future<LdListPage<T>> ldGreedyPaginateFiltered<T>({
  required List<T> filtered,
  required int offset,
  required int pageSize,
}) async {
  return LdListPage<T>(
    newItems: filtered.skip(offset).take(pageSize).toList(),
    hasMore: offset + pageSize < filtered.length,
    total: filtered.length,
  );
}
