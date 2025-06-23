import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdRepository<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<T> Function(IdType id) _getById;
  final Future<int?> Function(IdType id)? _getOffsetById;
  final Future<void> Function(Set<T> items)? _updateBatch;
  final Future<void> Function(IdType id)? _deleteItem;
  final Future<T?> Function(IdType id, T newItem)? _updateItem;
  final Future<T?> Function(IdType id, T? newItem)? _createItem;
  final Future<void> Function(Set<IdType> ids)? _deleteBatch;

  String singularItemTitle;
  String pluralItemTitle;

  LdRepository({
    required super.fetchListFunction,
    super.pageSize,
    required Future<T> Function(IdType id) getById,
    Future<int?> Function(IdType id)? getOffsetById,
    Future<void> Function(IdType id)? deleteItem,
    Future<T?> Function(IdType id, T newItem)? updateItem,
    Future<T?> Function(IdType id, T? newItem)? createItem,
    Future<void> Function(Set<IdType> ids)? deleteBatch,
    Future<void> Function(Set<T> items)? updateBatch,
    this.singularItemTitle = "Item",
    this.pluralItemTitle = "Items",
  })  : _getById = getById,
        _getOffsetById = getOffsetById,
        _deleteItem = deleteItem,
        _updateItem = updateItem,
        _createItem = createItem,
        _deleteBatch = deleteBatch,
        _updateBatch = updateBatch;

  static LdRepository<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>>();
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
