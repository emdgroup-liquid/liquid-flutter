import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function({
  required int offset,
  required int pageSize,
  String? pageToken,
});

enum LdPaginatorItemState {
  fetching,
  loaded,
  refreshing,
  updating,
  deleting,
  rolledBackDeletion,
  rolledBackUpdate,
  creating,
  rolledBackCreation,
  deleted,
  pendingRefresh,
}

class LdPaginatorItem<T extends Identifiable> {
  final T? value;
  final LdPaginatorItemState state;
  final T? previousValue; // for optimistic update/rollback
  LdPaginatorItem({
    required this.value,
    required this.state,
    this.previousValue,
  });

  LdPaginatorItem<T> copyWith({
    T? value,
    LdPaginatorItemState? state,
    T? previousValue,
  }) {
    return LdPaginatorItem<T>(
      value: value ?? this.value,
      state: state ?? this.state,
      previousValue: previousValue ?? this.previousValue,
    );
  }

  @override
  String toString() {
    return 'LdPaginatorItem(value: $value, state: $state, previousValue: $previousValue, id: ${value?.id})';
  }
}

class LdPaginatorLoadedItem<T extends Identifiable> extends LdPaginatorItem<T> {
  @override
  T get value => super.value!;

  LdPaginatorLoadedItem({
    required super.value,
    required super.state,
    super.previousValue,
  });
}

class LdPaginator<T extends Identifiable<IdType>, IdType> extends ChangeNotifier {
  FetchListFunction<T>? fetchListFunction;
  final int pageSize;
  int initialOffset;
  final Duration debounceTime;

  final StreamController<List<LdPaginatorItem<T>>> _itemsStreamController =
      StreamController<List<LdPaginatorItem<T>>>.broadcast();

  final StreamController<LdPaginatorItem<T>> _itemStreamController = StreamController<LdPaginatorItem<T>>.broadcast();

  Stream<List<LdPaginatorItem<T>>> get itemsStream => _itemsStreamController.stream;

  /// Stream of items that have been updated.
  Stream<LdPaginatorItem<T>> get updatedItems => _itemStreamController.stream;
  Stream<LdPaginatorItem<T>> watchItem(IdType id) {
    return updatedItems.where((item) => item.value?.id == id);
  }

  // Internal method to notify listeners that the items have been updated.
  void _updated(LdPaginatorItem<T>? item) {
    _itemsStreamController.add(_items.values.toList());

    // Single item update
    if (item != null) {
      _itemStreamController.add(item);
    } else {
      // All items update
      for (var element in _items.values) {
        _itemStreamController.add(element);
      }
    }
    notifyListeners();
  }

  LdPaginator({
    this.fetchListFunction,

    /// The number of items that are fetched at once.
    /// The [pageSize] will be passed to the [FetchListFunction] and used to
    /// "normalize" the offset to the nearest page size in the
    /// [fetchPageAtOffset] method.
    this.pageSize = 10,
    bool autoLoad = true,

    /// The initial offset to start fetching items from.
    this.initialOffset = 0,

    /// A debounce time to prevent multiple fetches within a short time frame.
    /// This is particularly useful in a scenario where the user gave an
    /// [assumedItemHeight] to [LdList] and is scrolling to a certain page
    /// quickly. The debounce time will prevent fetching all the pages in
    /// between.
    this.debounceTime = const Duration(milliseconds: 200),

    /// The initial items to add to the paginator.
    List<T>? initialItems,
  }) {
    if (initialItems != null) {
      for (var i = 0; i < initialItems.length; i++) {
        _items[i] = LdPaginatorItem<T>(value: initialItems[i], state: LdPaginatorItemState.loaded);
      }
    }

    if (autoLoad) {
      for (var i = 0; i < initialOffset; i++) {
        _items[i] = LdPaginatorItem<T>(
          value: null,
          state: LdPaginatorItemState.fetching,
        );
      }

      _setBusy(true);
      fetchItemsAtOffset(initialOffset);
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator<T, IdType>(
      pageSize: list.length,
      debounceTime: const Duration(milliseconds: 0),
      fetchListFunction: ({
        required int offset,
        required int pageSize,
        String? pageToken,
      }) async {
        if (offset == 0) {
          return LdListPage<T>(
            newItems: list,
            hasMore: false,
            total: list.length,
          );
        }
        return LdListPage<T>(
          newItems: <T>[],
          hasMore: false,
          total: list.length,
        );
      },
    );
  }

  final Map<int, LdPaginatorItem<T>> _items = {};
  Map<int, LdPaginatorItem<T>> get itemsMap => Map.unmodifiable(_items);
  List<T?> get items => List<T?>.generate(_totalItems, (i) => _items[i]?.value);

  // Track which ranges have been requested to prevent duplicate fetches
  final Set<int> _requestedOffsets = {};

  Timer? _debounceTimer;

  void setItems(List<LdPaginatorItem<T>> items) {
    _items.clear();
    for (var i = 0; i < items.length; i++) {
      _items[i] = items[i];
    }
    _updated(null);
  }

  int get currentItemCount => _items.values
      .where(
        (item) => item.state != LdPaginatorItemState.fetching,
      )
      .length;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  bool _busy = false;
  bool get busy => _busy;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  Completer? _currentOperation;

  void _setError(Object? error) {
    _error = error;
    notifyListeners();
  }

  void _setBusy(bool isBusy) {
    if (isBusy == _busy) return;
    _busy = isBusy;
    notifyListeners();
  }

  // Get all non-null items in order
  List<T> getAllLoadedItems() {
    return _items.entries
        .where((e) => e.value.state == LdPaginatorItemState.loaded && e.value.value != null)
        .map((e) => e.value.value as T)
        .toList();
  }

  // Check if position has a loaded item
  bool isItemLoaded(int position) {
    return _items[position]?.state != LdPaginatorItemState.fetching;
  }

  // Get item at a specific position
  LdPaginatorItem<T>? getItemAt(int position) {
    return _items[position];
  }

  Future<List<T>> _fetchItemsAtOffset(
    int offset, {
    bool refresh = false,
  }) async {
    // Check if all items in the requested range are loaded
    bool allLoaded = true;
    for (int i = 0; i < pageSize; i++) {
      final item = _items[offset + i];
      if (item == null || item.state != LdPaginatorItemState.loaded) {
        allLoaded = false;
        break;
      }
    }
    if (allLoaded && !refresh) {
      return [];
    }

    _requestedOffsets.add(offset);
    _setBusy(true);

    final List<T> loadedItems = [];

    assert(fetchListFunction != null, 'fetchListFunction is not set. Can not fetch items');

    try {
      final page = await fetchListFunction!(
        offset: offset,
        pageSize: pageSize,
        pageToken: null,
      );

      if (refresh) {
        _reset();
      }

      if (page.error != null) {
        _setError(page.error);
      } else {
        _totalItems = page.total;

        // Insert items at their exact positions
        for (int i = 0; i < page.newItems.length; i++) {
          final idx = offset + i;
          final item = page.newItems[i];
          _items[idx] = LdPaginatorItem<T>(value: item, state: LdPaginatorItemState.loaded);
          loadedItems.add(item);
        }

        _setError(null);
      }
    } catch (e) {
      _setError(e);
      _requestedOffsets.remove(offset); // Allow retry if there was an error
    }

    _setBusy(false);
    return loadedItems;
  }

  // Fetch items starting at a specific offset
  Future<void> fetchItemsAtOffset(int offset) async {
    if (offset < 0) offset = 0;

    return _debounceAndSafeExecute(() async {
      final newItems = await _fetchItemsAtOffset(offset);
      if (newItems.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  /// Fetch items at a specific offset, normalized to the nearest page size
  /// It makes sense to use this strategy in order to avoid fetching items
  /// that are already loaded.
  Future<void> fetchPageAtOffset(int offset) async {
    // normalize position to the nearest page size
    final pagedOffset = (offset ~/ pageSize) * pageSize;
    return fetchItemsAtOffset(pagedOffset);
  }

  // Refresh List - clear and fetch initial data
  Future<void> refreshList() async {
    for (final item in _items.entries) {
      if (item.value.state == LdPaginatorItemState.loaded) {
        _items[item.key] = item.value.copyWith(state: LdPaginatorItemState.pendingRefresh);
      }
    }
    _updated(null);

    if (currentItemCount == 0) {
      _setBusy(true);
      await _fetchItemsAtOffset(initialOffset);
      _setBusy(false);
    }
  }

  // Clear and reset without fetching data
  Future<void> reset() {
    _debounceTimer?.cancel();
    return _safeExecute(() async {
      _reset();
      _updated(null);
    });
  }

  void _reset() {
    _items.clear();
    _requestedOffsets.clear();
    _totalItems = 0;
    _error = null;
    _updated(null);
  }

  void _debounce(void Function() task) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceTime, task);
  }

  Future<R?> _safeExecute<R>(Future<R> Function() operation) async {
    await _currentOperation?.future;
    final completer = Completer<R?>();
    _currentOperation = completer;

    try {
      final result = await operation();
      completer.complete(result);
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      if (_currentOperation == completer) {
        _currentOperation = null;
      }
    }

    return completer.future;
  }

  Future<R?> _debounceAndSafeExecute<R>(Future<R> Function() operation) async {
    final completer = Completer<R?>();

    _debounce(() async {
      final result = await _safeExecute(operation);
      completer.complete(result);
    });

    return completer.future;
  }

  /// Adds an item to the paginator at the specified index,
  /// or at the first available slot if no index is given.
  /// Returns the index of the item.
  int scheduleItemCreation(T? item, {int? index}) {
    int newIndex;
    if (index != null) {
      _items[index] = LdPaginatorItem<T>(
        value: item,
        state: LdPaginatorItemState.creating,
      );
      newIndex = index;
    } else {
      // Find the first missing index
      int firstGap = 0;
      while (_items.containsKey(firstGap)) {
        firstGap++;
      }
      _items[firstGap] = LdPaginatorItem<T>(
        value: item,
        state: LdPaginatorItemState.creating,
      );
      newIndex = firstGap;
    }
    if (newIndex >= _totalItems) {
      _totalItems = newIndex + 1;
    }
    _updated(_items[newIndex]);
    return newIndex;
  }

  /// Confirm the creation of an item by index,
  /// index to be provided by [scheduleItemCreation]
  void confirmItemCreation(int index, {T? newValue}) {
    assert(
      _items[index]?.state == LdPaginatorItemState.creating,
      'Can not confirm item creation: $index, as it is not being created',
    );
    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? _items[index]!.value,
      state: LdPaginatorItemState.loaded,
    );
    _updated(_items[index]);
  }

  LdPaginatorItem<T>? getItemById(IdType id) {
    return _items.entries.firstWhereOrNull((e) => e.value.value?.id == id)?.value;
  }

  int? getItemIndexById(IdType id) {
    return _items.entries.firstWhereOrNull((e) => e.value.value?.id == id)?.key;
  }

  void rollbackItemCreation(IdType id) {
    final index = getItemIndexById(id);
    final item = _items[index];
    assert(
      item?.state == LdPaginatorItemState.creating,
      'Can not rollback item creation: $id, as it is not being created',
    );
    _items[index!] = LdPaginatorItem<T>(
      value: item!.value,
      state: LdPaginatorItemState.rolledBackCreation,
    );
    _updated(_items[index]);
  }

  /// Schedules the update of an item.
  /// This will mark the item as being updated. Gives the app the opportunity
  /// to make an api call, or show an update animation
  void scheduleItemUpdate(
    IdType id,
    T? newValue,
  ) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    final item = _items[index];
    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? item?.value,
      state: LdPaginatorItemState.updating,
      previousValue: item?.previousValue ?? item?.value,
    );
    _updated(_items[index]);
  }

  /// Rolls back the update of an item.
  /// This will restore the item to its previous state.
  void rollbackItemUpdate(IdType id, {T? newValue}) {
    final index = _items.entries.firstWhereOrNull((e) => e.value.previousValue?.id == id)?.key;

    if (index == null) throw Exception('Item with id $id not found');
    final item = _items[index]!;

    assert(
        item.state == LdPaginatorItemState.updating, 'Can not rollback item update: $id, as it is not being updated');

    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? item.previousValue,
      state: LdPaginatorItemState.rolledBackUpdate,
    );
    _updated(_items[index]);
  }

  /// Confirms the update of an item.
  /// This will apply [newValue] to the item. Otherwise the optimistic
  /// value previously set will be applied.
  void confirmItemUpdate(IdType id, T? newValue) {
    final index = _items.entries.firstWhereOrNull((e) => e.value.previousValue?.id == id)?.key;

    if (index == null) throw Exception('Item with id $id not found');

    final item = _items[index]!;

    assert(item.state == LdPaginatorItemState.updating,
        'Can not acknowledge item update: $id, as it is not being updated');
    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? item.value,
      state: LdPaginatorItemState.loaded,
    );
    _updated(_items[index]);
  }

  /// Schedules the deletion of an item.
  /// This will mark the item as being deleted. Gives the app the opportunity
  /// to make an api call, or show an exit animation
  void scheduleItemDeletion(IdType id) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    final item = _items[index]!;
    _items[index] = LdPaginatorItem<T>(
      value: item.value,
      state: LdPaginatorItemState.deleting,
    );
    _updated(_items[index]);
  }

  /// Rolls back the deletion of an item.
  /// This will restore the item to its previous state.
  void rollbackItemDeletion(IdType id) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    final item = _items[index]!;

    assert(
        item.state == LdPaginatorItemState.deleting, 'Can not rollback item deletion: $id, as it is not being deleted');

    _items[index] = LdPaginatorItem<T>(
      value: item.value,
      state: LdPaginatorItemState.rolledBackDeletion,
    );
    _updated(_items[index]);
  }

  /// Confirms the deletion of an item.
  /// This will remove the item from the paginator.
  void confirmItemDeletion(IdType id, {bool refresh = false}) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    _updated(_items[index]!.copyWith(state: LdPaginatorItemState.deleted));

    _items.remove(index);

    final newOrder = <int, LdPaginatorItem<T>>{};

    for (final item in _items.entries) {
      if (item.key > index) {
        newOrder[item.key - 1] = item.value;
      } else {
        newOrder[item.key] = item.value;
      }
    }

    _items.clear();
    _items.addAll(newOrder);

    if (refresh) {
      refreshList();
    }
  }
}
