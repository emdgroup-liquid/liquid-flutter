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
typedef FetchListFunction<T extends Identifiable<IdType>, IdType> = Future<LdListPage<T>> Function(
    FetchPageParameters<T, IdType> parameters);

class LdPaginator<T extends Identifiable<IdType>, IdType> extends ChangeNotifier {
  FetchListFunction<T, IdType>? fetchListFunction;
  final int pageSize;
  int initialOffset;
  final Duration debounceTime;

  // Stream of all items, emits when the items have been updated.
  final _itemsStreamController = StreamController<List<LdPaginatorItem<T>>>.broadcast();
  // Stream of a single item, emits when the item has been updated.
  final _itemStreamController = StreamController<LdPaginatorItem<T>>.broadcast();

  // The number of pages that are queued for fetching.
  int fetchQueueSize;

  // Internal map of index to LdPaginatorItem<T> is a map because
  // there might be gaps in the loaded items
  final Map<int, LdPaginatorItem<T>> _items = {};

  // Track which ranges have been requested to prevent duplicate fetches
  final Set<int> _requestedOffsets = {};

  // Timer to debounce the fetching of items.
  Timer? _debounceTimer;

  // Mutex to synchronize the fetching of items.
  final Mutex _mutex = Mutex();
  Mutex get mutex => _mutex;

// The current total number of items assumed in the paginator, this number is not the loaded items count.
// As there might be gaps in the loaded data sets. It is set from a server response (page total) and might be updated
// by optimistic state changes such as item deletion.
  int totalItems = 0;

  // Tracks whether the paginator is currently fetching an item
  bool _busy = false;

  LdException? _error;

  Completer? _currentOperation;

  // Offsets that are queued for fetching.
  final List<int> _offsetQueue = List.empty(growable: true);

  /// Cache exposed to [FetchPageParameters] during fetches.
  final LdRepositoryCache<T, IdType> repositoryCache;

  LdFetchReason _pendingFetchReason = LdFetchReason.pagination;

  LdPaginator({
    this.fetchListFunction,

    /// The number of items that are fetched at once.
    /// The [pageSize] will be passed to the [FetchListFunction] and used to
    /// "normalize" the offset to the nearest page size in the
    /// [fetchPageAtOffset] method.
    this.pageSize = 10,

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

    /// The number of pages that are queued for fetching. This should roughly
    /// be equivalent to 1.5x the number of items that are visible at once.
    /// If this number is too small the pages might be loaded in the wrong
    /// order bottom to top, if the number is too large the app might
    /// load more pages than needed.
    this.fetchQueueSize = 3,
    LdRepositoryCache<T, IdType>? repositoryCache,
  }) : repositoryCache = repositoryCache ?? LdRepositoryCache<T, IdType>() {
    if (initialItems != null) {
      for (var i = 0; i < initialItems.length; i++) {
        _items[i] = LdPaginatorItem<T>(value: initialItems[i], state: LdPaginatorItemState.loaded);
      }
      totalItems = initialItems.length;
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator<T, IdType>(
      pageSize: max(list.length, 1),
      debounceTime: const Duration(milliseconds: 0),
      initialItems: list,
      repositoryCache: LdRepositoryCache<T, IdType>(),
      fetchListFunction: (parameters) async {
        if (parameters.offset == 0) {
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

  /// The number of items that are loaded
  int get currentItemCount => _items.values
      .where(
        (item) => item.state != LdPaginatorItemState.fetching,
      )
      .length;

  LdException? get error => _error;
  bool get hasError => _error != null;

  // Returns a list of all items that are in the paginator, might contain nulls if there are gaps in the loaded items.
  List<T?> get items => List<T?>.generate(totalItems, (i) => _items[i]?.value);

  Map<int, LdPaginatorItem<T>> get itemsMap => Map.unmodifiable(_items);
  Stream<List<LdPaginatorItem<T>>> get itemsStream => _itemsStreamController.stream;

  /// Stream of items that have been updated.
  Stream<LdPaginatorItem<T>> get updatedItems => _itemStreamController.stream;

  /// Emits a single-item update for items tracked outside [_items]
  /// (for example detached selection entries in [LdRepository]).
  void notifyItemUpdated(LdPaginatorItem<T> item) {
    _updated(item);
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

  /// Confirms the deletion of an item.
  /// This will remove the item from the paginator.
  void confirmItemDeletion({
    required BuildContext context,
    bool refresh = false,
    required IdType id,
  }) {
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
      refreshList(context: context);
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

  Future<void> _triggerFetch(BuildContext context) async {
    final newItems = await _fetchItems(context: context);
    if (newItems.isNotEmpty) {
      notifyListeners();
    }
    if (_offsetQueue.isNotEmpty && context.mounted) {
      await _triggerFetch(context);
    }
  }

  // Fetch items starting at a specific offset
  Future<void> _addToOffsetQueue(BuildContext context, int offset) async {
    if (offset < 0) offset = 0;

    if (!_offsetQueue.contains(offset)) {
      if (_offsetQueue.length < fetchQueueSize) {
        _offsetQueue.add(offset);
      } else {
        _offsetQueue.removeAt(0);
        _offsetQueue.add(offset);
      }
    }

    return _triggerFetch(context);
  }

  /// Fetch items at a specific offset, normalized to the nearest page size
  /// It makes sense to use this strategy in order to avoid fetching items
  /// that are already loaded.
  Future<void> fetchPageAtOffset(
    BuildContext context,
    int offset, {
    LdFetchReason reason = LdFetchReason.pagination,
  }) async {
    _pendingFetchReason = reason;
    // normalize position to the nearest page size
    final pagedOffset = (offset ~/ pageSize) * pageSize;
    return _addToOffsetQueue(context, pagedOffset);
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
  Future<void> refreshList({
    required BuildContext context,
    LdFetchReason reason = LdFetchReason.refresh,
    @Deprecated('Use reason: LdFetchReason.refresh') bool hard = false,
  }) async {
    final effectiveReason = hard ? LdFetchReason.refresh : reason;

    if (effectiveReason == LdFetchReason.pagination) {
      return;
    }

    _setBusy(true);
    _offsetQueue.clear();
    _pendingFetchReason = effectiveReason;
    _reset();

    final fetchOffset = switch (effectiveReason) {
      LdFetchReason.initial => initialOffset,
      LdFetchReason.filter || LdFetchReason.sort || LdFetchReason.invalidate => 0,
      LdFetchReason.refresh || LdFetchReason.pagination => initialOffset,
    };

    if (context.mounted) {
      await _addToOffsetQueue(context, fetchOffset);
    }
    _setBusy(false);
  }

  /// Loads every page by calling [fetchListFunction] until [LdListPage.hasMore]
  /// is false. Used by greedy repositories to capture the full dataset up front.
  @protected
  Future<void> eagerFetchAllPages(BuildContext context) async {
    if (!context.mounted || fetchListFunction == null) {
      return;
    }

    _setBusy(true);
    _offsetQueue.clear();
    _reset();

    var offset = 0;
    var hasMore = true;

    while (hasMore && context.mounted) {
      _pendingFetchReason = offset == 0 ? LdFetchReason.initial : LdFetchReason.pagination;

      try {
        final page = await fetchListFunction!(
          FetchPageParameters(
            context: context,
            offset: offset,
            pageSize: pageSize,
            pageToken: null,
            reason: _pendingFetchReason,
            cache: repositoryCache,
          ),
        );

        totalItems = page.total;
        _insertPageItems(page, offset);
        hasMore = page.hasMore;
        offset += page.newItems.length;
        _setError(null);
      } catch (e, s) {
        _setError(
          LdException(
            exception: e,
            stackTrace: s,
          ),
        );
        hasMore = false;
      }
    }

    _pendingFetchReason = LdFetchReason.pagination;
    _setBusy(false);
    notifyListeners();
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
    required BuildContext context,
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

    if (!context.mounted) {
      _mutex.release();
      _setBusy(false);
      return [];
    }

    final fetchReason = _pendingFetchReason;

    try {
      final page = await fetchListFunction!(
        FetchPageParameters(
          context: context,
          offset: offset,
          pageSize: pageSize,
          pageToken: null,
          reason: fetchReason,
          cache: repositoryCache,
        ),
      );

      if (refresh) {
        _reset();
      }

      totalItems = page.total;
      loadedItems.addAll(_insertPageItems(page, offset));
      _setError(null);
    } catch (e, s) {
      _setError(LdException(
        exception: e,
        stackTrace: s,
      ));
      _requestedOffsets.remove(offset); // Allow retry if there was an error
    }

    _pendingFetchReason = LdFetchReason.pagination;
    _setBusy(false);
    _mutex.release();
    return loadedItems;
  }

  bool _isTransientItemState(LdPaginatorItemState state) {
    return switch (state) {
      LdPaginatorItemState.deleting || LdPaginatorItemState.updating || LdPaginatorItemState.creating => true,
      _ => false,
    };
  }

  List<T> _insertPageItems(LdListPage<T> page, int offset) {
    final loadedItems = <T>[];

    for (int i = 0; i < page.newItems.length; i++) {
      final item = page.newItems[i];

      final toRemove = <int>[];

      for (final existingItem in _items.entries) {
        if (existingItem.value.value?.id == item.id && !_isTransientItemState(existingItem.value.state)) {
          toRemove.add(existingItem.key);
        }
      }

      for (final index in toRemove) {
        _items.remove(index);
      }

      final idx = offset + i;
      final hasTransientItem = _items.values.any(
        (existingItem) => existingItem.value?.id == item.id && _isTransientItemState(existingItem.state),
      );
      if (hasTransientItem) {
        continue;
      }

      _items[idx] = LdPaginatorItem<T>(value: item, state: LdPaginatorItemState.loaded);
      _updated(_items[idx]);
      loadedItems.add(item);
    }

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

  void _setError(LdException? error) {
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
