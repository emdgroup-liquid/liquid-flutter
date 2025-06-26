import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/sort/ld_sort_option.dart';
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
  final Future<int?> Function(IdType id)? _getOffsetById;
  final Future<void> Function(Set<T> items)? _updateBatch;
  final Future<void> Function(IdType id)? _deleteItem;
  final Future<T?> Function(IdType id, T newItem)? _updateItem;
  final Future<T?> Function(IdType id, T? newItem)? _createItem;
  final Future<void> Function(Set<IdType> ids)? _deleteBatch;

  final FetchListWithParameters<T, IdType> _fetchListWithParameters;

  String singularItemTitle;
  String pluralItemTitle;

  final Set<LdFilterOption<T, IdType>> _filters;
  final List<LdSortOption<T, IdType>> _sortOptions;

  Set<LdFilterOption<T, IdType>> get filters => Set.unmodifiable(_filters);
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
    Future<int?> Function(IdType id)? getOffsetById,
    Future<void> Function(IdType id)? deleteItem,
    Future<T?> Function(IdType id, T newItem)? updateItem,
    Future<T?> Function(IdType id, T? newItem)? createItem,
    Future<void> Function(Set<IdType> ids)? deleteBatch,
    Future<void> Function(Set<T> items)? updateBatch,
    this.singularItemTitle = "Item",
    this.pluralItemTitle = "Items",
  })  : _fetchListWithParameters = fetchListWithParameters,
        _getById = getById,
        _getOffsetById = getOffsetById,
        _deleteItem = deleteItem,
        _updateItem = updateItem,
        _filters = filters ?? {},
        _createItem = createItem,
        _sortOptions = sortOptions ?? [],
        _deleteBatch = deleteBatch,
        _updateBatch = updateBatch {
    fetchListFunction = _fetchListPaginator;
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
      filters: _filters.where((e) => e.isOn).toSet(),
      sortOptions: _sortOptions.where((e) => e.isOn).toList(),
    );
  }

  static LdRepository<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>>();
  }

  Future<void> updateFilter(LdFilterOption<T, IdType> filter) async {
    final existingFilter = _filters.firstWhereOrNull((e) => e.name == filter.name);
    assert(existingFilter != null, 'Cannot update filter. Filter with name ${filter.name} does not exist');
    _filters.remove(existingFilter);
    _filters.add(filter);
    _filterStreamController.add(_filters);
    print("Updated filter: ${filter.name} ${filter.isOn}");
    applyOptimisticFilterAndSorting();
  }

  Future<void> updateSortOption(LdSortOption<T, IdType> sortOption) async {
    final existingSortOption = _sortOptions.firstWhereOrNull((e) => e.name == sortOption.name);
    assert(existingSortOption != null,
        'Cannot update sort option. Sort option with name ${sortOption.name} does not exist');
    _sortOptions.remove(existingSortOption);
    _sortOptions.add(sortOption);
    _sortStreamController.add(_sortOptions);
    applyOptimisticFilterAndSorting();
  }

  Future<void> applyOptimisticFilterAndSorting() async {
    final filters = _filters.where((e) => e.isOn).toList();
    final sortOptions = _sortOptions.where((e) => e.isOn).toList();

    final itemsFiltered = itemsMap.values.map((item) {
      return LdPaginatorItem<T>(
        value: item.value,
        state: item.value != null && filters.every((filter) => filter.optimisticFilter(item.value!))
            ? LdPaginatorItemState.loaded
            : LdPaginatorItemState.deleting,
      );
    }).toList();

    final sortableItems = itemsFiltered.where((e) => e.value != null).toList();

    for (final sortOption in sortOptions) {
      sortableItems.sort((a, b) => sortOption.optimisticSort!(a.value!, b.value!));
    }

    // Apply the sorting to the previous list

    for (var i = 0; i < itemsFiltered.length; i++) {
      if (itemsFiltered[i].value == null) {
        continue;
      }

      itemsFiltered[i] = sortableItems.removeAt(0);
    }

    setItems(itemsFiltered);
    refreshList();
  }

  Future<void> initWithSelection(Set<IdType> selection) async {
    if (_getOffsetById == null) {
      return;
    }
    final firstOffset = await _getOffsetById!(selection.first);

    initialOffset = firstOffset ?? 0;

    if (firstOffset == null) {
      return;
    }

    await fetchItemsAtOffset(firstOffset);
  }

  Future<T> getById(IdType id, {bool skipCache = false}) async {
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
          rollbackItemUpdate(item.id);
        }
        rethrow;
      }
    } else {
      final exceptions = <dynamic>[];
      for (final item in items) {
        try {
          final newItem = await _updateItem!(item.id, item);
          confirmItemUpdate(item.id, newItem ?? item);
        } catch (e) {
          rollbackItemUpdate(item.id);
          exceptions.add(e);
        }
      }
      if (exceptions.isNotEmpty) {
        throw Exception(exceptions);
      }
    }
  }

  Future<void> update(IdType id, T newValue) async {
    if (_updateItem != null) {
      scheduleItemUpdate(id, newValue);
      try {
        final newItem = await _updateItem!(id, newValue);
        confirmItemUpdate(
          id,
          newItem ?? newValue,
        );
      } catch (e) {
        rollbackItemUpdate(id);
        rethrow;
      }
    }
  }

  Future<void> create(IdType id, T? newValue, {int? index}) async {
    if (_createItem != null) {
      final newIndex = scheduleItemCreation(newValue, index: index);
      try {
        final newItem = await _createItem!(id, newValue);
        confirmItemCreation(newIndex, newValue: newItem);
      } catch (e) {
        rollbackItemCreation(id);
        rethrow;
      }
    }
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
}
