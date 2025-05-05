part of '../list/list_paginator.dart';

enum CrudLoadingStateType { loading, success, error }

/// A state event for a CRUD item.
/// It can be loading, success, error or deleted.
/// If an operation fails, the error is set.
/// If the operation is successful, the data is set (for create and update),
/// or null (for delete).
class CrudItemStateEvent<T> {
  final CrudLoadingStateType type;
  final dynamic error;
  final T? data;

  CrudItemStateEvent._({
    required this.type,
    this.error,
    this.data,
  });

  factory CrudItemStateEvent.loading([T? data]) =>
      CrudItemStateEvent._(type: CrudLoadingStateType.loading, data: data);

  factory CrudItemStateEvent.success(T data) =>
      CrudItemStateEvent._(type: CrudLoadingStateType.success, data: data);

  factory CrudItemStateEvent.deleted() =>
      CrudItemStateEvent._(type: CrudLoadingStateType.success, data: null);

  factory CrudItemStateEvent.error(dynamic error) =>
      CrudItemStateEvent._(type: CrudLoadingStateType.error, error: error);

  @override
  String toString() {
    return "CrudItemStateEvent(type: $type, data: $data, error: $error)";
  }
}

/// Extends [LdPaginator] to add CRUD operations and item states.
class LdCrudListState<T extends CrudItemMixin<T>> extends LdPaginator<T> {
  final Map<dynamic, CrudItemStateEvent<T>> itemStates = {};

  // Add multiselect properties
  final Set<T> _selectedItems = {};
  Set<T> get selectedItems => Set.from(_selectedItems);
  int get selectedItemCount => _selectedItems.length;

  bool _isMultiSelectMode = false;
  bool get isMultiSelectMode => _isMultiSelectMode;

  LdCrudListState({required super.fetchListFunction});

  /// Intelligently handles item state events, e.g. loading, success, error.
  /// It knows which state was caused by which operation and updates the
  /// item list accordingly.
  void handleItemStateEvent(T? item, CrudItemStateEvent<T> state) {
    final id = item?.id;
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
      } else if (item?.isNew ?? false) {
        _add(state.data!);
      } else {
        _update(state.data!);
      }
      _setBusy(false);
    }
    notifyListeners();
  }

  void clearItemState(T? item) {
    if (item != null) {
      itemStates.remove(item.id);
      notifyListeners();
    }
  }

  T? getItemOptimistically(T? item) {
    return itemStates[item?.id]?.data ?? item;
  }

  Error? getItemError(T? item) {
    return itemStates[item?.id]?.error;
  }

  bool isItemLoading(T? item) {
    return itemStates[item?.id]?.type == CrudLoadingStateType.loading;
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
      if (_selectedItems.isEmpty) {
        _isMultiSelectMode = false;
      }
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
        _selectedItems.remove(_items[i]); // remove potential selection
        _items.removeAt(i);
        _totalItems -= 1;
        notifyListeners();
        return;
      }
    }
  }
}
