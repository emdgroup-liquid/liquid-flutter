import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdRepository<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? _getOffsetById;

  final Future<T?> Function(IdType id, T newItem)? _updateItem;
  final Future<T?> Function(T? newItem)? _createItem;
  final Future<T> Function(IdType id) _getById;
  final Future<void> Function(IdType id)? _deleteItem;
  final Future<void> Function(Set<IdType> ids)? _deleteBatch;
  final Future<void> Function(Set<T> items)? _updateBatch;

  IdType? _lastSelectionAnchorId;

  LdRepository({
    required Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    super.pageSize,
    super.initialItems,
    required Future<T> Function(IdType id) getById,
    Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? getOffsetById,
    Future<void> Function(IdType id)? deleteItem,
    Future<T?> Function(IdType id, T newItem)? updateItem,
    Future<T?> Function(T? newItem)? createItem,
    Future<void> Function(Set<IdType> ids)? deleteBatch,
    Future<void> Function(Set<T> items)? updateBatch,
  })  : _getById = getById,
        _getOffsetById = getOffsetById,
        _deleteItem = deleteItem,
        _updateItem = updateItem,
        _createItem = createItem,
        _deleteBatch = deleteBatch,
        _updateBatch = updateBatch {
    fetchListFunction = (parameters) {
      return fetchListWithParameters(
        FetchPageParameters(
          context: parameters.context,
          offset: parameters.offset,
          pageSize: parameters.pageSize,
          pageToken: parameters.pageToken,
        ),
      );
    };
  }

  Future<T?> create(T? newValue, {int? index}) async {
    assert(
      _createItem != null,
      'Cannot create item. createItem was not configured for this repository',
    );
    final newIndex = scheduleItemCreation(newValue, index: index);
    try {
      final newItem = await _createItem!(newValue);
      confirmItemCreation(newIndex, newValue: newItem);
      return newItem;
    } catch (e, stackTrace) {
      if (ldPrintDebugMessages) {
        debugPrint("Error creating item: $e");
        debugPrint(stackTrace.toString());
      }

      rollbackItemCreation(newIndex);
      return null;
    }
  }

  Future<void> delete({required BuildContext context, required IdType id}) async {
    if (_deleteItem != null) {
      scheduleItemDeletion(id);
      try {
        await _deleteItem(id);
        if (!context.mounted) {
          return;
        }
        confirmItemDeletion(context: context, id: id);
      } catch (e) {
        rollbackItemDeletion(id);
        rethrow;
      }
    }
  }

  Future<void> deleteBatch({required BuildContext context, required Set<IdType> ids}) async {
    if (_deleteBatch == null) {
      for (var id in ids) {
        await delete(context: context, id: id);
      }
    } else {
      final exceptions = <dynamic>[];
      for (final id in ids) {
        scheduleItemDeletion(id);
      }
      try {
        await _deleteBatch(ids);

        for (final id in ids) {
          if (!context.mounted) {
            break;
          }
          confirmItemDeletion(context: context, id: id, refresh: false);
        }
      } catch (e) {
        for (final id in ids) {
          rollbackItemDeletion(id);
        }
        exceptions.add(e);
      }

      if (exceptions.isNotEmpty && context.mounted) {
        refreshList(context: context);
        throw Exception(exceptions);
      }
    }
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

  Future<void> initWithSelection(BuildContext context, Set<IdType> selection) async {
    if (selection.isEmpty) {
      return;
    }
    _lastSelectionAnchorId = selection.first;
    if (_getOffsetById == null) {
      return;
    }

    final firstOffset = await _getOffsetById(FetchOffsetParameters(
      context: context,
      id: selection.first,
    ));

    initialOffset = firstOffset ?? 0;

    if (firstOffset == null || !context.mounted) {
      return;
    }

    await fetchPageAtOffset(context, firstOffset);
  }

  @override
  Future<void> refreshList({
    required BuildContext context,
    bool hard = false,
    IdType? anchorId,
  }) async {
    final effectiveAnchorId = anchorId ?? _resolveDefaultRefreshAnchorId();

    if (effectiveAnchorId != null && _getOffsetById != null) {
      final anchorOffset = await _getOffsetById(
        FetchOffsetParameters(
          context: context,
          id: effectiveAnchorId,
        ),
      );
      if (anchorOffset != null) {
        initialOffset = anchorOffset;
      }
    }

    if (!context.mounted) {
      return;
    }

    await super.refreshList(context: context, hard: hard);
  }

  Future<void> update(IdType id, T newValue) async {
    if (_updateItem != null) {
      scheduleItemUpdate(id, newValue);
      try {
        final newItemFromServer = await _updateItem(id, newValue);
        final newItem = newItemFromServer ?? newValue;
        confirmItemUpdate(id, newItem);
      } catch (e) {
        await rollbackItemUpdate(id);
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
        await _updateBatch(items);
        for (final item in items) {
          confirmItemUpdate(item.id, item);
        }
      } catch (e) {
        for (final item in items) {
          await rollbackItemUpdate(item.id);
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
          await rollbackItemUpdate(item.id);
          exceptions.add(e);
        }
      }

      if (exceptions.isNotEmpty) {
        throw Exception(exceptions);
      }
    }
  }

  IdType? _resolveDefaultRefreshAnchorId() {
    final currentItem = getItemAt(initialOffset);
    if (currentItem?.value != null) {
      return currentItem!.value!.id;
    }

    if (_lastSelectionAnchorId != null) {
      return _lastSelectionAnchorId;
    }

    return itemsMap.entries
        .where((entry) => entry.value.value != null)
        .map((entry) => entry.value.value!.id)
        .firstOrNull;
  }

  static LdRepository<L, IdType> fromList<L extends Identifiable<IdType>, IdType>({
    required List<L> list,
    bool Function(L item, Set<LdFilterOption<L, IdType>>? activeFilters)? filterFunction,
    int Function(L a, L b, List<LdSortOption<L, IdType>>? activeSortOptions)? sortFunction,
  }) {
    return LdRepository<L, IdType>(
      fetchListWithParameters: (parameters) async {
        var filtered = list.toList();
        final filters = parameters.filters;
        final sortOptions = parameters.sortOptions;

        if (filterFunction != null && filters.isNotEmpty) {
          filtered = filtered.where((item) => filterFunction(item, filters)).toList();
        }

        if (sortFunction != null && sortOptions.isNotEmpty) {
          filtered.sort((a, b) => sortFunction(a, b, sortOptions));
        }

        return LdListPage<L>(
          newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
          hasMore: parameters.offset + parameters.pageSize < filtered.length,
          total: filtered.length,
        );
      },
      getById: (id) async => list.firstWhere((item) => item.id == id),
    );
  }

  static LdRepository<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>?>();
  }

  static LdRepository<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>>();
  }
}
