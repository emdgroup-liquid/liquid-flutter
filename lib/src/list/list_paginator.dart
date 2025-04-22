import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part '../master_detail/crud_list_state.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function({
  required int offset,
  required int pageSize,
  String? pageToken,
});

class LdPaginator<T> extends ChangeNotifier {
  final FetchListFunction<T> fetchListFunction;
  final int pageSize;
  final int initialOffset;
  final Duration debounceTime;

  LdPaginator({
    required this.fetchListFunction,

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
    this.debounceTime = const Duration(milliseconds: 500),
  }) {
    if (autoLoad) {
      _setBusy(true);
      fetchItemsAtOffset(initialOffset);
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator(
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

  // List to store items at their exact position, with null for not-yet-loaded items
  final List<T?> _items = [];
  List<T?> get items => List.unmodifiable(_items);

  // Track which ranges have been requested to prevent duplicate fetches
  final Set<int> _requestedOffsets = {};

  Timer? _debounceTimer;

  int get currentItemCount => _items.where((item) => item != null).length;

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
    return _items.whereType<T>().toList();
  }

  // Check if position has a loaded item
  bool isItemLoaded(int position) {
    return position < _items.length && _items[position] != null;
  }

  // Get item at a specific position
  T? getItemAt(int position) {
    if (position < 0 || position >= _items.length) return null;
    return _items[position];
  }

  Future<List<T>> _fetchItemsAtOffset(
    int offset, {
    bool refresh = false,
  }) async {
    if (_requestedOffsets.contains(offset) && !refresh) {
      return [];
    }

    _requestedOffsets.add(offset);
    _setBusy(true);

    final List<T> loadedItems = [];

    try {
      final page = await fetchListFunction(
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

        // Ensure _items list is large enough
        if (offset + page.newItems.length > _items.length) {
          _items.length = max(offset + page.newItems.length, _totalItems);
        }

        // Insert items at their exact positions
        for (int i = 0; i < page.newItems.length; i++) {
          final item = page.newItems.elementAt(i);
          _items[offset + i] = item;
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
    return _safeExecute(() async {
      final newItems = await _fetchItemsAtOffset(initialOffset, refresh: true);
      if (newItems.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  // Clear and reset without fetching data
  Future<void> reset() {
    _debounceTimer?.cancel();
    return _safeExecute(() async {
      _reset();
      notifyListeners();
    });
  }

  void _reset() {
    _items.clear();
    _requestedOffsets.clear();
    _totalItems = 0;
    _error = null;
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
}
