import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

typedef FetchListWithParameters<T extends Identifiable<IdType>, IdType> = Future<LdListPage<T>> Function({
  required int offset,
  required int pageSize,
  String? pageToken,
  Set<LdFilterOption<T, IdType>>? filters,
  List<LdSortOption<T, IdType>>? sortOptions,
});

class LdRepository<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<T> Function(IdType id) _getById;
  final Future<int?> Function(IdType id,
      {Set<LdFilterOption<T, IdType>>? filters, List<LdSortOption<T, IdType>>? sortOptions})? _getOffsetById;
  final Future<void> Function(Set<T> items)? _updateBatch;
  final Future<void> Function(IdType id)? _deleteItem;
  final Future<T?> Function(IdType id, T newItem)? _updateItem;
  final Future<T?> Function(T? newItem)? _createItem;
  final Future<void> Function(Set<IdType> ids)? _deleteBatch;

  final FetchListWithParameters<T, IdType> _fetchListWithParameters;

  String singularItemTitle;
  String pluralItemTitle;

  final Map<String, LdFilterOption<T, IdType>> _filters;
  final List<LdSortOption<T, IdType>> _sortOptions;

  Map<String, LdFilterOption<T, IdType>> get filters => Map.unmodifiable(_filters);
  List<LdSortOption<T, IdType>> get sortOptions => List.unmodifiable(_sortOptions);

  final _filterStreamController = StreamController<Set<LdFilterOption<T, IdType>>>.broadcast();
  Stream<Set<LdFilterOption<T, IdType>>> get filterStream => _filterStreamController.stream;

  final _sortStreamController = StreamController<List<LdSortOption<T, IdType>>>.broadcast();
  Stream<List<LdSortOption<T, IdType>>> get sortStream => _sortStreamController.stream;

  LdRepository({
    required FetchListWithParameters<T, IdType> fetchListWithParameters,
    super.pageSize,
    required Future<T> Function(IdType id) getById,
    Set<LdFilterOption<T, IdType>>? filters,
    List<LdSortOption<T, IdType>>? sortOptions,
    Future<int?> Function(IdType id,
            {Set<LdFilterOption<T, IdType>>? filters, List<LdSortOption<T, IdType>>? sortOptions})?
        getOffsetById,
    Future<void> Function(IdType id)? deleteItem,
    Future<T?> Function(IdType id, T newItem)? updateItem,
    Future<T?> Function(T? newItem)? createItem,
    Future<void> Function(Set<IdType> ids)? deleteBatch,
    Future<void> Function(Set<T> items)? updateBatch,
    this.singularItemTitle = "Item",
    this.pluralItemTitle = "Items",
  })  : _fetchListWithParameters = fetchListWithParameters,
        _getById = getById,
        _getOffsetById = getOffsetById,
        _deleteItem = deleteItem,
        _updateItem = updateItem,
        _filters = Map.fromEntries(filters?.map((e) => MapEntry(e.name, e)) ?? []),
        _createItem = createItem,
        _sortOptions = sortOptions ?? [],
        _deleteBatch = deleteBatch,
        _updateBatch = updateBatch {
    fetchListFunction = _fetchListPaginator;
  }

  static LdRepository<L, IdType> fromList<L extends Identifiable<IdType>, IdType>({
    required List<L> list,
    Set<LdFilterOption<L, IdType>>? filters,
    List<LdSortOption<L, IdType>>? sortOptions,
  }) {
    return LdRepository<L, IdType>(
      filters: filters,
      sortOptions: sortOptions,
      fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
        final filtered =
            list.where((item) => filters?.every((filter) => filter.optimisticFilter(item)) ?? true).toList();
        for (final sortOption in sortOptions ?? []) {
          filtered.sort((a, b) => sortOption.optimisticSort(a, b));
        }
        return LdListPage<L>(
          newItems: filtered.skip(offset).take(pageSize).toList(),
          hasMore: offset + pageSize < filtered.length,
          total: filtered.length,
        );
      },
      getById: (id) async => list.firstWhere((item) => item.id == id),
    );
  }

  // Adapter for the LdPaginator
  Future<LdListPage<T>> _fetchListPaginator({
    required int offset,
    required int pageSize,
    String? pageToken,
  }) {
    return _fetchListWithParameters(
      offset: offset,
      pageSize: pageSize,
      pageToken: pageToken,
      filters: activeFilters.toSet(),
      sortOptions: _sortOptions.where((e) => e.isOn).toList(),
    );
  }

  static LdRepository<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>>();
  }

  static LdRepository<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>?>();
  }

  Map<String, dynamic> get queryParameters {
    var parameters = <String, dynamic>{};

    for (final filter in _filters.values) {
      if (filter.isOn) {
        parameters[filter.name] = filter.serialize();
      }
    }

    final sort = _sortOptions.where((e) => e.isOn).toList();

    if (sort.isNotEmpty) {
      parameters['sort'] = sort.map((e) => e.serialize()).join(',');
    }

    return parameters;
  }

  Future<void> updateFilter(
      String name, LdFilterOption<T, IdType> Function(LdFilterOption<T, IdType>? filter) updater) async {
    final existingFilter = _filters[name];
    assert(existingFilter != null, 'Cannot update filter. Filter with name $name does not exist');
    _filters[name] = updater(existingFilter);
    _filterStreamController.add(_filters.values.toSet());
    await applyOptimisticFilterAndSorting();
  }

  Future<void> updateSortOption(LdSortOption<T, IdType> sortOption) async {
    final existingSortOption = _sortOptions.firstWhereOrNull((e) => e.name == sortOption.name);
    assert(existingSortOption != null,
        'Cannot update sort option. Sort option with name ${sortOption.name} does not exist');
    _sortOptions.remove(existingSortOption);
    _sortOptions.add(sortOption);
    _sortStreamController.add(_sortOptions);
    await applyOptimisticFilterAndSorting();
  }

  Future<void> setActiveSortOption(String name) async {
    final newOptions = _sortOptions.map((e) => e.copyWith(isOn: e.name == name)).toList();

    _sortOptions.clear();
    _sortOptions.addAll(newOptions);
    _sortStreamController.add(_sortOptions);
    await applyOptimisticFilterAndSorting();
  }

  Future<void> applyOptimisticFilterAndSorting() async {
    final filters = activeFilters.toList();
    final sortOptions = _sortOptions.where((e) => e.isOn).toList();

    if (filters.isEmpty && sortOptions.isEmpty) {
      await refreshList();
      return;
    }

    await mutex.acquire();
    var filteredItems = Map.fromEntries(
      itemsMap.entries.where((item) => item.value.value != null).map((item) {
        final filterApplies = filters.every((filter) => filter.optimisticFilter(item.value.value!));

        var newState = filterApplies ? item.value.state : LdPaginatorItemState.filteredOut;

        if (newState == LdPaginatorItemState.filteredOut && filterApplies) {
          newState = LdPaginatorItemState.loaded;
        }

        return MapEntry(
          item.key,
          item.value.copyWith(
            state: newState,
          ),
        );
      }),
    );

    replaceItems(filteredItems);

    await Future.delayed(const Duration(milliseconds: 500));

    filteredItems.removeWhere((key, value) => value.state == LdPaginatorItemState.filteredOut || value.value == null);

    final sortedItems = filteredItems.values.toList();

    totalItems = filteredItems.length;

    for (final sortOption in sortOptions) {
      if (sortOption.optimisticSort != null) {
        sortedItems.sort((a, b) => sortOption.optimisticSort!(a.value!, b.value!));
      }
    }

    // Apply the sorting to the previous list

    setItems(sortedItems);
    mutex.release();
    await refreshList();
  }

  Iterable<LdFilterOption<T, IdType>> get activeFilters => _filters.values.where((e) => e.isOn);

  Future<void> initWithSelection(Set<IdType> selection) async {
    if (_getOffsetById == null) {
      return;
    }
    final currentFilters = activeFilters.toSet();
    final currentSortOptions = _sortOptions.where((e) => e.isOn).toList();

    final firstOffset = await _getOffsetById!(
      selection.first,
      filters: currentFilters,
      sortOptions: currentSortOptions,
    );

    initialOffset = firstOffset ?? 0;

    if (firstOffset == null) {
      return;
    }

    await fetchItemsAtOffset(firstOffset);
  }

  Future<T> getById(IdType id, {bool skipCache = false}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!skipCache) {
      final item = getItemById(id);
      if (item != null) {
        return item.value!;
      }
    }
    return await _getById(id);
  }

  Future<void> delete(IdType id) async {
    if (_deleteItem != null) {
      scheduleItemDeletion(id);
      try {
        await _deleteItem!(id);
        confirmItemDeletion(id);
      } catch (e) {
        rollbackItemDeletion(id);
        rethrow;
      }
    }
  }

  Future<void> updateBatch(Set<T> items) async {
    for (final item in items) {
      scheduleItemUpdate(item.id, item);
    }
    if (_updateBatch != null) {
      try {
        await _updateBatch!(items);
        for (final item in items) {
          confirmItemUpdate(item.id, item);
        }
      } catch (e) {
        for (final item in items) {
          await rollbackItemUpdate(item.id);
        }
        rethrow;
      }
      await applyOptimisticFilterAndSorting();
    } else {
      final exceptions = <dynamic>[];
      for (final item in items) {
        try {
          final newItem = await _updateItem!(item.id, item);
          confirmItemUpdate(item.id, newItem ?? item);
        } catch (e) {
          await rollbackItemUpdate(item.id);
          exceptions.add(e);
        }
      }

      await applyOptimisticFilterAndSorting();
      if (exceptions.isNotEmpty) {
        throw Exception(exceptions);
      }
    }
  }

  Future<void> update(IdType id, T newValue) async {
    if (_updateItem != null) {
      scheduleItemUpdate(id, newValue);
      try {
        final newItemFromServer = await _updateItem!(id, newValue);
        final newItem = newItemFromServer ?? newValue;
        confirmItemUpdate(id, newItem);

        await applyOptimisticFilterAndSorting();
      } catch (e) {
        await rollbackItemUpdate(id);
        //await applyOptimisticFilterAndSorting();
        rethrow;
      }
    }
  }

  Future<T?> create(T? newValue, {int? index}) async {
    if (_createItem != null) {
      final newIndex = scheduleItemCreation(newValue, index: index);
      //applyOptimisticFilterAndSorting();
      try {
        final newItem = await _createItem!(newValue);
        confirmItemCreation(newIndex, newValue: newItem);
        applyOptimisticFilterAndSorting();
        return newItem;
      } catch (e, stackTrace) {
        if (ldPrintDebugMessages) {
          debugPrint("Error creating item: $e");
          debugPrint(stackTrace.toString());
        }

        rollbackItemCreation(newIndex);
        rethrow;
      }
    }
    return null;
  }

  Future<void> deleteBatch(Set<IdType> ids) async {
    if (_deleteBatch == null) {
      for (var id in ids) {
        await delete(id);
      }
    } else {
      final exceptions = <dynamic>[];
      for (final id in ids) {
        scheduleItemDeletion(id);
      }
      try {
        await _deleteBatch!(ids);
        for (final id in ids) {
          confirmItemDeletion(id, refresh: false);
        }
      } catch (e) {
        for (final id in ids) {
          rollbackItemDeletion(id);
        }
        exceptions.add(e);
      }

      if (exceptions.isNotEmpty) {
        refreshList();
        throw Exception(exceptions);
      }
    }
  }

  LdSearchConfig? getSearchConfig() {
    final searchFilter = filters.values.firstWhereOrNull((filter) => filter is LdFilterSearchOption)
        as LdFilterSearchOption<T, IdType, dynamic>?;
    if (searchFilter != null) {
      return searchFilter.searchConfig((query) {
        updateFilter(searchFilter.name, (filter) {
          filter as LdFilterSearchOption<T, IdType, dynamic>;
          return filter.copyWith(
            isOn: query.isNotEmpty,
            searchText: query,
          );
        });
      });
    }
    return null;
  }

  @override
  void dispose() {
    _filterStreamController.close();
    _sortStreamController.close();
    super.dispose();
  }
}
