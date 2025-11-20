import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mutex/mutex.dart';

/// This function is used to fetch a range of items from a data source.
/// The [offset] is the index of the first item to fetch.
/// The [pageSize] is the number of items to fetch.
/// The [pageToken] is a token that can be used to fetch the next page of items.
typedef FetchListFunction<T> = Future<LdListPage<T>> Function({
  required int offset,
  required int pageSize,
  String? pageToken,
});

class LdPaginator<T extends Identifiable<IdType>, IdType> extends ChangeNotifier {
  FetchListFunction<T>? fetchListFunction;
  final int pageSize;
  int initialOffset;
  final Duration debounceTime;

  // Stream of all items, emits when the items have been updated.
  final _itemsStreamController = StreamController<List<LdPaginatorItem<T>>>.broadcast();
  // Stream of a single item, emits when the item has been updated.
  final _itemStreamController = StreamController<LdPaginatorItem<T>>.broadcast();

  // The number of pages that are queued for fetching.
  int fetchQueueSize;

  final Map<int, LdPaginatorItem<T>> _items = {};

  // Track which ranges have been requested to prevent duplicate fetches
  final Set<int> _requestedOffsets = {};

  // Timer to debounce the fetching of items.
  Timer? _debounceTimer;

  // Mutex to synchronize the fetching of items.
  final Mutex _mutex = Mutex();

  Mutex get mutex => _mutex;

  int totalItems = 0;

  bool _busy = false;

  Object? _error;

  Completer? _currentOperation;
  final List<int> _offsetQueue = List.empty(growable: true);
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

    /// The number of pages that are queued for fetching. This should roughly be equivalent to 1.5x the number of items that are visible at once.
    /// If this number is too small the pages might be loaded in the wrong order bottom to top, if the number is too large the app might load more pages than needed.
    this.fetchQueueSize = 3,
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
      pageSize: max(list.length, 1),
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

  bool get busy => _busy;

  int get currentItemCount => _items.values
      .where(
        (item) => item.state != LdPaginatorItemState.fetching && item.state != LdPaginatorItemState.filteredOut,
      )
      .length;

  Object? get error => _error;

  bool get hasError => _error != null;

  List<T?> get items => List<T?>.generate(totalItems, (i) => _items[i]?.value);

  Map<int, LdPaginatorItem<T>> get itemsMap => Map.unmodifiable(_items);
  Stream<List<LdPaginatorItem<T>>> get itemsStream => _itemsStreamController.stream;

  /// Stream of items that have been updated.
  Stream<LdPaginatorItem<T>> get updatedItems => _itemStreamController.stream;

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

  /// Confirms the deletion of an item.
  /// This will remove the item from the paginator.
  void confirmItemDeletion(IdType id, {bool refresh = false}) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    _updated(_items[index]!.copyWith(state: LdPaginatorItemState.deleted));

    _items.remove(index);
    totalItems--;
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

  void _triggerFetch() async {
    final newItems = await _fetchItems();
    if (newItems.isNotEmpty) {
      notifyListeners();
    }
    if (_offsetQueue.isNotEmpty) {
      _triggerFetch();
    }
  }

  // Fetch items starting at a specific offset
  Future<void> fetchItemsAtOffset(int offset) async {
    if (offset < 0) offset = 0;

    if (!_offsetQueue.contains(offset)) {
      if (_offsetQueue.length < fetchQueueSize) {
        _offsetQueue.add(offset);
      } else {
        _offsetQueue.removeAt(0);
        _offsetQueue.add(offset);
      }
    }

    return _triggerFetch();
  }

  /// Fetch items at a specific offset, normalized to the nearest page size
  /// It makes sense to use this strategy in order to avoid fetching items
  /// that are already loaded.
  Future<void> fetchPageAtOffset(int offset) async {
    // normalize position to the nearest page size
    final pagedOffset = (offset ~/ pageSize) * pageSize;
    return fetchItemsAtOffset(pagedOffset);
  }

  // Get all non-null items in order
  List<T> getAllLoadedItems() {
    return _items.entries
        .where((e) => e.value.state == LdPaginatorItemState.loaded && e.value.value != null)
        .map((e) => e.value.value as T)
        .toList();
  }

  // Get item at a specific position
  LdPaginatorItem<T>? getItemAt(int position) {
    return _items[position];
  }

  LdPaginatorItem<T>? getItemById(IdType id) {
    return _items.entries.firstWhereOrNull((e) => e.value.value?.id == id)?.value;
  }

  int? getItemIndexById(IdType id) {
    return _items.entries.firstWhereOrNull((e) => e.value.value?.id == id)?.key;
  }

  // Check if position has a loaded item
  bool isItemLoaded(int position) {
    return _items[position]?.state != LdPaginatorItemState.fetching;
  }

  // Refresh List - clear and fetch initial data
  Future<void> refreshList() async {
    print("refreshList ");
    for (final item in _items.entries) {
      if (item.value.value != null) {
        _items[item.key] = item.value.copyWith(state: LdPaginatorItemState.pendingRefresh);
      }
    }
    _updated(null);

    // The list has not been fetched yet or we filtered out all the items
    // optimistically.
    if (totalItems == 0 || _items.isEmpty) {
      _setBusy(true);
      _offsetQueue.clear();
      await fetchItemsAtOffset(initialOffset);
      _setBusy(false);
    }
  }

  void replaceItems(Map<int, LdPaginatorItem<T>> items) {
    _items.clear();
    _items.addAll(items);
    _updated(null);
  }

  // Clear and reset without fetching data
  Future<void> reset() {
    _debounceTimer?.cancel();
    return _safeExecute(() async {
      _reset();
      _updated(null);
    });
  }

  void rollbackItemCreation(int index) {
    final item = _items[index];
    assert(
      item?.state == LdPaginatorItemState.creating,
      'Can not rollback item creation: $index, as it is not being created',
    );
    _items[index] = LdPaginatorItem<T>(
      value: item!.value,
      state: LdPaginatorItemState.rolledBackCreation,
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

  /// Rolls back the update of an item.x
  /// This will restore the item to its previous state.
  Future<void> rollbackItemUpdate(IdType id, {T? newValue}) async {
    final index = _items.entries.firstWhereOrNull((e) => e.value.previousValue?.id == id)?.key;

    if (index == null) {
      throw Exception('Unable to roll back. Item with id $id not found');
    }
    final item = _items[index]!;

    assert(
        item.state == LdPaginatorItemState.updating, 'Can not rollback item update: $id, as it is not being updated');

    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? item.previousValue,
      state: LdPaginatorItemState.rolledBackUpdate,
    );
    await _updated(_items[index]);
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
    if (newIndex >= totalItems) {
      totalItems = newIndex + 1;
    }
    _updated(_items[newIndex]);
    return newIndex;
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

  /// Schedules the update of an item.
  /// This will mark the item as being updated. Gives the app the opportunity
  /// to make an api call, or show an update animation
  void scheduleItemUpdate(
    IdType id,
    T? newValue,
  ) {
    final index = getItemIndexById(id);

    if (index == null) {
      throw Exception('Item with id $id not found during scheduleItemUpdate');
    }
    final item = _items[index];

    _items[index] = LdPaginatorItem<T>(
      value: newValue ?? item?.value,
      state: LdPaginatorItemState.updating,
      previousValue: item?.previousValue ?? item?.value,
    );
    _updated(_items[index]);
  }

  void setItems(List<LdPaginatorItem<T>> items) {
    _items.clear();
    for (var i = 0; i < items.length; i++) {
      _items[i] = items[i];
    }
    _updated(null);
  }

  Stream<LdPaginatorItem<T>> watchItem(IdType id) {
    return updatedItems.where((item) => item.value?.id == id);
  }

  Stream<LdPaginatorItem<T>> watchItems(Set<IdType> ids) async* {
    await for (final update in updatedItems) {
      if (ids.contains(update.value?.id)) {
        yield update;
      }
    }
  }

  Stream<List<LdPaginatorItem<T>>> watchListOfItems(Set<IdType> ids) async* {
    yield ids.map((id) => getItemById(id)).nonNulls.toList();
    await for (final update in updatedItems) {
      yield ids.map((id) => getItemById(id)).nonNulls.toList();
      if (ids.contains(update.value?.id)) {
        yield ids.map((id) => getItemById(id)).nonNulls.toList();
      }
    }
  }

  Future<List<T>> _fetchItems({
    bool refresh = false,
  }) async {
    await _mutex.acquire();

    if (_offsetQueue.isEmpty) {
      _mutex.release();
      return [];
    }

    final offset = _offsetQueue.removeAt(0);

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
      _mutex.release();
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
        totalItems = page.total;

        // Insert items at their exact positions
        for (int i = 0; i < page.newItems.length; i++) {
          // Check if the item is already in the list
          final item = page.newItems[i];

          // In case the item is already in the list but at a wrong position,
          // we remove it

          var toRemove = <int>[];

          for (final existingItem in _items.entries) {
            if (existingItem.value.value?.id == item.id) {
              toRemove.add(existingItem.key);
            }
          }

          for (var item in toRemove) {
            _items.remove(item);
          }

          final idx = offset + i;

          _items[idx] = LdPaginatorItem<T>(value: item, state: LdPaginatorItemState.loaded);
          _updated(_items[idx]);
          loadedItems.add(item);
        }

        _setError(null);
      }
    } catch (e) {
      _setError(e);
      _requestedOffsets.remove(offset); // Allow retry if there was an error
    }

    _setBusy(false);
    _mutex.release();
    return loadedItems;
  }

  void _reset() {
    _items.clear();
    _requestedOffsets.clear();
    totalItems = 0;
    _error = null;
    _updated(null);
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

  void _setBusy(bool isBusy) {
    if (isBusy == _busy) return;
    _busy = isBusy;
    notifyListeners();
  }

  void _setError(Object? error) {
    _error = error;
    notifyListeners();
  }

  // Internal method to notify listeners that the items have been updated.
  Future<void> _updated(LdPaginatorItem<T>? item) async {
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _itemsStreamController.close();
    _itemStreamController.close();
    super.dispose();
  }

  @override
  String toString() {
    return 'LdPaginator('
        'totalItems: $totalItems, '
        'busy: $_busy, '
        'error: $_error, '
        'pageSize: $pageSize, '
        'initialOffset: $initialOffset, '
        'debounceTime: $debounceTime, '
        'items: ${_items.length}, '
        'fetchQueueSize: $fetchQueueSize, '
        'requestedOffsets: $_requestedOffsets'
        ')';
  }
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
  filteredOut,
}

class LdPaginatorLoadedItem<T extends Identifiable> extends LdPaginatorItem<T> {
  LdPaginatorLoadedItem({
    required super.value,
    required super.state,
    super.previousValue,
  });

  @override
  T get value => super.value!;
}
