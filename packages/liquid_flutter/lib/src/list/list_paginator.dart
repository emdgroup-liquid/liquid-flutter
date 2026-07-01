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
  FetchListFunction<T, IdType> fetchListFunction;
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

  bool _fetchInProgress = false;

  /// True while [refreshList] is marking items [LdPaginatorItemState.pendingRefresh],
  /// fetching replacement pages in the background, and waiting to commit state.
  bool _isControlledRefresh = false;

  /// Cache exposed to [FetchPageParameters] during fetches.
  final LdListCache<T, IdType> listCache;

  LdFetchReason _pendingFetchReason = LdFetchReason.pagination;

  /// When set, [LdList] scrolls this item into view after the next rebuild.
  IdType? pendingScrollToItemId;

  /// Requests that mounted [LdList] widgets scroll [id] into view.
  void requestScrollToItem(IdType id) {
    pendingScrollToItemId = id;
    notifyListeners();
  }

  void clearPendingScrollToItem() {
    pendingScrollToItemId = null;
  }

  LdPaginator({
    required this.fetchListFunction,

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
    LdListCache<T, IdType>? listCache,
  }) : listCache = listCache ?? LdListCache<T, IdType>() {
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
      listCache: LdListCache<T, IdType>(),
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

  /// Whether a controlled [refreshList] is in progress (see [_isControlledRefresh]).
  bool get isControlledRefresh => _isControlledRefresh;

  /// The number of items that are loaded
  int get currentItemCount => _items.values
      .where(
        (item) => item.state != LdPaginatorItemState.fetching && item.state != LdPaginatorItemState.deleting,
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
  /// (for example detached selection entries in [LdListController]).
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
  ///
  /// Returns `true` when indices above [id] were compacted locally. Returns
  /// `false` when the sparse map could not be safely compacted and the caller
  /// should refresh list data.
  bool confirmItemDeletion({
    required BuildContext context,
    bool refresh = false,
    required IdType id,
  }) {
    final index = getItemIndexById(id);
    if (index == null) throw Exception('Item with id $id not found');
    _updated(_items[index]!.copyWith(state: LdPaginatorItemState.deleted));

    _items.remove(index);
    totalItems--;

    final compacted = canCompactIndicesAfterDeletion(index);
    if (compacted) {
      compactIndicesAfterDeletion(index);
    }

    if (refresh) {
      refreshList(context: context);
    }

    return compacted;
  }

  /// Whether loaded indices above [deletedIndex] are contiguous and safe to
  /// shift down after a deletion.
  bool canCompactIndicesAfterDeletion(int deletedIndex) {
    final keysAbove = _items.keys.where((key) => key > deletedIndex).toList()..sort();
    if (keysAbove.isEmpty) {
      return true;
    }

    for (var i = 0; i < keysAbove.length; i++) {
      if (keysAbove[i] != deletedIndex + 1 + i) {
        return false;
      }
    }

    return true;
  }

  /// Shifts loaded items above [deletedIndex] down by one position.
  void compactIndicesAfterDeletion(int deletedIndex) {
    final newOrder = <int, LdPaginatorItem<T>>{};

    for (final item in _items.entries) {
      if (item.key > deletedIndex) {
        newOrder[item.key - 1] = item.value;
      } else {
        newOrder[item.key] = item.value;
      }
    }

    _items.clear();
    _items.addAll(newOrder);
    _updated(null);
  }

  /// Whether every index between [a] and [b] (inclusive) is currently loaded,
  /// i.e. they belong to the same uninterrupted run of loaded items.
  ///
  /// Used to decide whether a sparse index can be shifted locally (e.g. when
  /// repositioning an updated item) without exposing a boundary gap that can
  /// not be refetched because the surrounding page is already marked loaded.
  bool areIndicesInSameLoadedRun(int a, int b) {
    final lo = min(a, b);
    final hi = max(a, b);
    for (var i = lo; i <= hi; i++) {
      if (!_items.containsKey(i)) {
        return false;
      }
    }
    return true;
  }

  /// Shifts sparse indices after moving the item at [fromIndex] to [toIndex].
  void reorderIndices(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) {
      return;
    }

    final movedItem = _items.remove(fromIndex);
    final newOrder = <int, LdPaginatorItem<T>>{};

    for (final entry in _items.entries) {
      final key = entry.key;
      final shiftedKey = switch (fromIndex.compareTo(toIndex)) {
        < 0 when key > fromIndex && key <= toIndex => key - 1,
        > 0 when key >= toIndex && key < fromIndex => key + 1,
        _ => key,
      };
      newOrder[shiftedKey] = entry.value;
    }

    if (movedItem != null) {
      newOrder[toIndex] = movedItem;
    }

    _items
      ..clear()
      ..addAll(newOrder);
    _updated(null);
  }

  /// Moves [id] to [newIndex], removing duplicate entries for the same id.
  void repositionItemById(
    IdType id, {
    required int newIndex,
    T? value,
    LdPaginatorItemState state = LdPaginatorItemState.loaded,
  }) {
    final currentIndex = getItemIndexById(id);
    final resolvedValue = value ?? (currentIndex != null ? _items[currentIndex]?.value : null);

    if (currentIndex != null) {
      _items.remove(currentIndex);
    }

    for (final entry in _items.entries.toList()) {
      if (entry.value.value?.id == id) {
        _items.remove(entry.key);
      }
    }

    if (newIndex >= totalItems) {
      totalItems = newIndex + 1;
    }

    _items[newIndex] = LdPaginatorItem<T>(
      value: resolvedValue,
      state: state,
    );
    _updated(_items[newIndex]);
  }

  void removeItemAtIndex(int index) {
    _items.remove(index);
    _updated(null);
  }

  /// Clears the record of which page offsets have already been requested.
  ///
  /// Call this after a local index mutation (e.g. shifting items to reposition
  /// an updated entry) that can expose a gap at the edge of an already-loaded
  /// page. Without it the gap would never refill, because its page offset is
  /// still marked as requested. Gap-free pages keep being skipped by
  /// [_fetchItems] (it verifies every slot in the range is loaded), so this
  /// only triggers refetches where data is actually missing.
  void invalidateRequestedOffsets() {
    _requestedOffsets.clear();
  }

  /// Confirms the update of an item.
  /// This will apply [newValue] to the item. Otherwise the optimistic
  /// value previously set will be applied.
  void confirmItemUpdate(IdType id, T? newValue) {
    final index = _items.entries.firstWhereOrNull((e) {
      final item = e.value;
      if (item.state != LdPaginatorItemState.updating) {
        return false;
      }
      return item.value?.id == id || item.previousValue?.id == id;
    })?.key;

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
    if (_fetchInProgress || _isControlledRefresh) {
      return;
    }

    _fetchInProgress = true;
    try {
      while (_offsetQueue.isNotEmpty && context.mounted && !_isControlledRefresh) {
        final changed = await _fetchItems(context: context);
        if (changed) {
          notifyListeners();
        }
      }
    } finally {
      _fetchInProgress = false;
    }
  }

  // Fetch items starting at a specific offset.
  //
  // When [immediate] is false (the default for scroll-driven pagination calls)
  // and [debounceTime] is non-zero, the actual fetch is deferred until the
  // debounce timer fires. Rapid calls during a fast scroll therefore collapse
  // into a single fetch of the offsets that are still queued when the timer
  // fires. This is the intended use of the [debounceTime] parameter.
  //
  // Pass [immediate] = true for non-pagination triggers (refresh, initial
  // load, scroll-to-item) so they are never delayed.
  Future<void> _addToOffsetQueue(
    BuildContext context,
    int offset, {
    bool immediate = false,
  }) async {
    if (offset < 0) offset = 0;

    final normalizedOffset = offset;
    final pageOffset = (normalizedOffset ~/ pageSize) * pageSize;

    if (_requestedOffsets.contains(pageOffset)) {
      return;
    }

    if (!_offsetQueue.contains(normalizedOffset)) {
      if (_offsetQueue.length < fetchQueueSize) {
        _offsetQueue.add(normalizedOffset);
      } else {
        _offsetQueue.removeAt(0);
        _offsetQueue.add(normalizedOffset);
      }
    }

    if (!immediate && debounceTime > Duration.zero) {
      // Debounced path: reset the timer. The fetch fires once the user stops
      // scrolling (or once the current burst of gap-fill requests settles).
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceTime, () {
        if (context.mounted) {
          _triggerFetch(context);
        }
      });
    } else {
      // Immediate path: cancel any pending debounce so a subsequent debounced
      // scroll burst cannot interfere with this fetch, then fire right away.
      _debounceTimer?.cancel();
      _debounceTimer = null;
      await _triggerFetch(context);
    }
  }

  /// Fetch items at a specific offset, normalized to the nearest page size.
  ///
  /// Scroll-driven pagination calls are debounced by [debounceTime] so that a
  /// fast fling does not trigger a network request for every intermediate page.
  /// Non-pagination reasons (initial, refresh, invalidate, filter, sort) bypass
  /// the debounce and fire immediately.
  Future<void> fetchPageAtOffset(
    BuildContext context,
    int offset, {
    LdFetchReason reason = LdFetchReason.pagination,
  }) async {
    if (_isControlledRefresh) {
      return;
    }
    _pendingFetchReason = reason;
    // normalize position to the nearest page size
    final pagedOffset = (offset ~/ pageSize) * pageSize;
    // Only pagination calls from the list widget (gap-fills during scroll) are
    // debounced. Every other reason represents an explicit action that should
    // start immediately.
    final immediate = reason != LdFetchReason.pagination || debounceTime == Duration.zero;
    return _addToOffsetQueue(context, pagedOffset, immediate: immediate);
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

  /// Called by [_commitRefreshState] just before [_items] is replaced with the
  /// fresh server data. [transientItems] contains every entry that was in
  /// [_items] with a transient state (deleting / updating / creating) and their
  /// current index keys.
  ///
  /// Subclasses that track in-flight operations outside [_items] (e.g. via a
  /// side-channel map) should override this to take ownership of those items so
  /// that pending confirms / rollbacks can still resolve after the refresh.
  ///
  /// The default implementation is a no-op.
  @protected
  void onTransientItemsEvictedByRefresh(Map<int, LdPaginatorItem<T>> transientItems) {}

  // Refresh List - mark items pending, fetch in the background, then commit.
  Future<void> refreshList({
    required BuildContext context,
    LdFetchReason reason = LdFetchReason.refresh,
  }) async {
    if (reason == LdFetchReason.pagination) {
      return;
    }

    _offsetQueue.clear();
    _pendingFetchReason = reason;

    final hasVisibleItems = _items.values.any(
      (item) => item.value != null && item.state != LdPaginatorItemState.fetching,
    );
    if (!hasVisibleItems) {
      await _refreshFromEmpty(context, reason);
      return;
    }

    await _refreshWithPendingState(context, reason);
  }

  Future<void> _refreshFromEmpty(
    BuildContext context,
    LdFetchReason effectiveReason,
  ) async {
    _setBusy(true);
    _reset();

    final fetchOffset = _refreshBaseOffset(effectiveReason);

    if (context.mounted) {
      await _addToOffsetQueue(context, fetchOffset, immediate: true);
    }
    _setBusy(false);
  }

  Future<void> _refreshWithPendingState(
    BuildContext context,
    LdFetchReason effectiveReason,
  ) async {

    _isControlledRefresh = true;
    _setBusy(true);
    _markItemsPendingRefresh();
    _requestedOffsets.clear();

    if (!context.mounted) {
      _revertControlledRefresh();
      return;
    }

    final fetchOffsets = _refreshFetchOffsets(effectiveReason);

    try {
      final pages = await _fetchRefreshPages(
        context: context,
        reason: effectiveReason,
        offsets: fetchOffsets,
      );

      if (!context.mounted) {
        _revertControlledRefresh();
        return;
      }

      _commitRefreshState(pages);
    } catch (e, s) {
      _setError(
        LdException(
          exception: e,
          stackTrace: s,
        ),
      );
      _revertControlledRefresh();
    }
  }

  int _refreshBaseOffset(LdFetchReason reason) {
    return switch (reason) {
      LdFetchReason.initial => initialOffset,
      LdFetchReason.filter || LdFetchReason.sort || LdFetchReason.invalidate => 0,
      LdFetchReason.refresh || LdFetchReason.pagination => initialOffset,
    };
  }

  int _normalizePageOffset(int offset) {
    if (offset < 0) {
      return 0;
    }
    return (offset ~/ pageSize) * pageSize;
  }

  List<int> _refreshFetchOffsets(LdFetchReason reason) {
    final pageOffset = _normalizePageOffset(_refreshBaseOffset(reason));

    if (reason == LdFetchReason.filter || reason == LdFetchReason.sort || reason == LdFetchReason.invalidate) {
      return [pageOffset];
    }

    if (pageOffset == 0) {
      return [0];
    }

    final offsets = <int>{
      pageOffset,
      pageOffset - pageSize,
      pageOffset + pageSize,
    };
    return offsets.toList()..sort();
  }

  void _markItemsPendingRefresh() {
    for (final entry in _items.entries.toList()) {
      final item = entry.value;
      if (item.value == null) {
        continue;
      }
      if (item.state == LdPaginatorItemState.loaded) {
        _items[entry.key] = item.copyWith(state: LdPaginatorItemState.pendingRefresh);
      }
    }
    _updated(null);
  }

  void _revertControlledRefresh() {
    for (final entry in _items.entries.toList()) {
      if (entry.value.state == LdPaginatorItemState.pendingRefresh) {
        _items[entry.key] = entry.value.copyWith(state: LdPaginatorItemState.loaded);
      }
    }
    _isControlledRefresh = false;
    _setBusy(false);
    _updated(null);
  }

  Future<List<({int offset, LdListPage<T> page})>> _fetchRefreshPages({
    required BuildContext context,
    required LdFetchReason reason,
    required List<int> offsets,
  }) async {
    final results = <({int offset, LdListPage<T> page})>[];

    for (final offset in offsets) {
      if (!context.mounted) {
        break;
      }

      final page = await fetchListFunction(
        FetchPageParameters(
          context: context,
          offset: offset,
          pageSize: pageSize,
          pageToken: null,
          reason: reason,
          cache: listCache,
        ),
      );
      results.add((offset: offset, page: page));
    }

    return results;
  }

  void _commitRefreshState(List<({int offset, LdListPage<T> page})> pages) {
    final newItems = <int, LdPaginatorItem<T>>{};
    var newTotal = totalItems;

    for (final entry in pages) {
      newTotal = entry.page.total;
      for (var i = 0; i < entry.page.newItems.length; i++) {
        final item = entry.page.newItems[i];
        final index = entry.offset + i;
        newItems[index] = LdPaginatorItem<T>(
          value: item,
          state: LdPaginatorItemState.loaded,
        );
      }
    }

    // Give subclasses a chance to evacuate in-flight (transient) items before
    // _items is replaced. Items returned here will no longer be tracked inside
    // _items, so subclasses must take ownership of them (e.g. move them to a
    // side-channel map) so that in-flight confirms/rollbacks can still resolve.
    final transientItems = <int, LdPaginatorItem<T>>{};
    for (final entry in _items.entries) {
      if (entry.value.value != null && _isTransientItemState(entry.value.state)) {
        transientItems[entry.key] = entry.value;
      }
    }
    onTransientItemsEvictedByRefresh(transientItems);

    _items
      ..clear()
      ..addAll(newItems);
    totalItems = newTotal;
    _requestedOffsets
      ..clear()
      ..addAll(
        pages.where((entry) => entry.page.newItems.isNotEmpty).map((entry) => entry.offset),
      );
    _error = null;
    _pendingFetchReason = LdFetchReason.pagination;
    _isControlledRefresh = false;
    _setBusy(false);
    _updated(null);
  }

  /// Loads every page by calling [fetchListFunction] until [LdListPage.hasMore]
  /// is false. Used by greedy repositories to capture the full dataset up front.
  @protected
  Future<void> eagerFetchAllPages(BuildContext context) async {
    if (!context.mounted) {
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
        final page = await fetchListFunction(
          FetchPageParameters(
            context: context,
            offset: offset,
            pageSize: pageSize,
            pageToken: null,
            reason: _pendingFetchReason,
            cache: listCache,
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
    final index = _items.entries.firstWhereOrNull((e) {
      final item = e.value;
      if (item.state != LdPaginatorItemState.updating) {
        return false;
      }
      return item.value?.id == id || item.previousValue?.id == id;
    })?.key;

    if (index == null) {
      // Nothing to roll back: a concurrent confirm, rollback, or refresh
      // already resolved or removed this item (e.g. it left a filtered view,
      // or a sibling update for the same id finished first). Treat as a no-op
      // so we never undo a confirmed value and never mask the original error
      // that triggered this rollback.
      return;
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

  Future<bool> _fetchItems({
    bool refresh = false,
    required BuildContext context,
  }) async {
    await _mutex.acquire();

    if (_offsetQueue.isEmpty) {
      _mutex.release();
      return false;
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
      return false;
    }

    _requestedOffsets.add(offset);
    _setBusy(true);


    if (!context.mounted) {
      _mutex.release();
      _setBusy(false);
      return false;
    }

    bool changed = false;
    final fetchReason = _pendingFetchReason;

    try {
      final page = await fetchListFunction(
        FetchPageParameters(
          context: context,
          offset: offset,
          pageSize: pageSize,
          pageToken: null,
          reason: fetchReason,
          cache: listCache,
        ),
      );

      if (refresh) {
        _reset();
      }

      totalItems = page.total;
      final hadCrossPageEviction = _insertPageItems(page, offset);
      _requestedOffsets.remove(offset);
      _setError(null);
      changed = page.newItems.isNotEmpty;
      if (hadCrossPageEviction) {
        // The same item appeared at two different indices across two fetches
        // that hit different server snapshots. Any cached pages are now stale
        // (they record item positions from the older snapshot). Clear the whole
        // cache so the next gap-fill re-fetches from the server rather than
        // replaying the stale position data and creating an infinite ping-pong.
        listCache.clear();
      }
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
    return changed;
  }

  bool _isTransientItemState(LdPaginatorItemState state) {
    return switch (state) {
      LdPaginatorItemState.deleting || LdPaginatorItemState.updating || LdPaginatorItemState.creating => true,
      _ => false,
    };
  }

  /// Insert items from [page] at [offset] into [_items].
  ///
  /// Returns `true` if any item from [page] displaced an item that was stored
  /// under a slot belonging to a *different* page (i.e. a cross-page eviction).
  /// This is a signal that two concurrent fetches hit different server snapshots
  /// and the list index is momentarily inconsistent; the caller may want to
  /// schedule a refresh once the current batch of mutations has settled.
  bool _insertPageItems(LdListPage<T> page, int offset) {
    bool hadCrossPageEviction = false;

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
        final evictedPageOffset = (index ~/ pageSize) * pageSize;
        if (evictedPageOffset != (offset ~/ pageSize) * pageSize) {
          // Item moved from a different page's slot — two concurrent fetches
          // hit different server snapshots. Do NOT re-open the stale page for
          // a gap-fill (that would create a ping-pong loop). Instead, signal
          // the caller to schedule a debounced full refreshList so everything
          // settles to a coherent state.
          hadCrossPageEviction = true;
        }
      }

      final hasTransientItem = _items.values.any(
        (existingItem) => existingItem.value?.id == item.id && _isTransientItemState(existingItem.state),
      );
      if (hasTransientItem) {
        continue;
      }

      _items[offset + i] = LdPaginatorItem<T>(value: item, state: LdPaginatorItemState.loaded);
      _updated(_items[offset + i]);
    }

    return hadCrossPageEviction;
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
