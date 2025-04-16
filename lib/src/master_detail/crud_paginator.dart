part of '../list/list_paginator.dart';

enum CrudLoadingStateType { initial, loading, success, error }

class CrudItemState<T> {
  final CrudLoadingStateType type;
  final LdException? error;
  final T? data;

  CrudItemState({
    required this.type,
    this.error,
    this.data,
  });

  factory CrudItemState.initial() =>
      CrudItemState(type: CrudLoadingStateType.initial);

  factory CrudItemState.loading() =>
      CrudItemState(type: CrudLoadingStateType.loading);

  /// In case data is null, it was a successful delete operation
  factory CrudItemState.success(T? data) =>
      CrudItemState(type: CrudLoadingStateType.success, data: data);

  factory CrudItemState.deleted() =>
      CrudItemState(type: CrudLoadingStateType.success, data: null);

  factory CrudItemState.error(LdException error) =>
      CrudItemState(type: CrudLoadingStateType.error, error: error);
}

/// Extends [LdPaginator] to add CRUD operations and item states.
class LdCrudPaginator<T extends CrudItemMixin<T>> extends LdPaginator<T> {
  final Map<dynamic, CrudItemState<T>> itemStates = {};

  // Add multiselect properties
  final Set<T> _selectedItems = {};
  Set<T> get selectedItems => Set.from(_selectedItems);
  int get selectedItemCount => _selectedItems.length;

  bool _isMultiSelectMode = false;
  bool get isMultiSelectMode => _isMultiSelectMode;

  LdCrudPaginator({required super.fetchListFunction});

  void updateItemState(dynamic id, CrudItemState<T> state) {
    // Update item state
    if (id != null) {
      itemStates[id] = state;
    } else {
      // let's just set the general busy state, if we can't to it on item level
      _setBusy(state.type == CrudLoadingStateType.loading);
      if (state.type == CrudLoadingStateType.error) {
        // same goes for error state
        _setError(state.error!);
      }
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
      _setBusy(false);
    }
    notifyListeners();
  }

  CrudItemState<T>? getItemState(dynamic id) {
    return itemStates[id];
  }

  void toggleMultiSelectMode({bool? forceValue}) {
    _isMultiSelectMode = forceValue ?? !_isMultiSelectMode;
    if (!_isMultiSelectMode) {
      _selectedItems.clear();
    }
    notifyListeners();
  }

  void toggleItemSelection(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  bool isItemSelected(T item) {
    return _selectedItems.contains(item);
  }

  void _add(T item) {
    // Add item to the list
    _items.add(item);
    _totalItems += 1;
    notifyListeners();
  }

  bool _update(T item) {
    // Update item in the list
    for (var i = 0; i < _items.length; i++) {
      if (_items[i]?.id == item.id) {
        _items[i] = item;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> _delete(dynamic id) async {
    // Delete item from the list
    for (var i = 0; i < _items.length; i++) {
      if (_items[i]?.id == id) {
        _items.removeAt(i);
        _totalItems -= 1;
        notifyListeners();
        return;
      }
    }
  }
}
