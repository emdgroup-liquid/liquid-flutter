// ignore_for_file: implementation_imports
// @dart=ignore
part of '../list/list_paginator.dart';

/// Extends [LdPaginator] to add CRUD operations and item states.
class LdCrudPaginator<T extends CrudItemMixin<T>> extends LdPaginator<T> {
  final Map<dynamic, CrudItemState<T>> itemStates = {};

  LdCrudPaginator({required super.fetchListFunction});

  void _add(T item) {
    final lastPage = pages.entries.last.value;
    if (!lastPage.hasMore) {
      // if the last page has already been loaded, add the item to the last page
      lastPage.newItems.add(item);
      _totalItems += 1;
    }

    notifyListeners();
  }

  bool _update(T item) {
    for (var page in pages.values) {
      final index = page.newItems.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        page.newItems[index] = item;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> _delete(dynamic id) async {
    for (var e in _loadedPages.entries) {
      final index = e.value.newItems.indexWhere((e) => e.id == id);
      if (index != -1) {
        _loadedPages[e.key] = e.value.copyWith(
          newItems: List.from(e.value.newItems)..removeAt(index),
          total: e.value.total - 1,
        );
        _totalItems = e.value.total - 1;
        notifyListeners();
        continue;
      }
    }
  }

  void setBusy(isBusy) {
    _setBusy(isBusy);
  }

  void setError(error) {
    _setError(error);
  }

  void updateItemState(dynamic id, CrudItemState<T> state) {
    // Update item state
    if (id != null) {
      itemStates[id] = state;
    } else {
      setBusy(state.type == CrudLoadingStateType.loading);
    }
    if (state.type == CrudLoadingStateType.success) {
      // If the state is success, update the item in the list
      if (state.data == null) {
        _delete(id);
      } else if (id == null) {
        _add(state.data!);
      } else {
        _update(state.data!);
      }
      setBusy(false);
    }
    notifyListeners();
  }

  CrudItemState<T>? getItemState(dynamic id) {
    return itemStates[id];
  }
}
