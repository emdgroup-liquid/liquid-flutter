import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function(
  int page,
  int loadedItems,
  String? pageToken,
);

const _defaultPageSize = 10;

class LdPaginator<T> extends ChangeNotifier {
  FetchListFunction<T> fetchListFunction;
  final int startPage;
  final Duration debounceTime;

  LdPaginator({
    required this.fetchListFunction,
    bool autoLoad = true,

    /// The page to start loading from. If you set this to a positive number,
    /// it may enable the "bidirectional scrolling" feature of [LdList].
    this.startPage = 0,

    /// A debounce time to prevent multiple fetches within a short time frame.
    /// This is particularly useful in a scenario where the user gave an
    /// [assumedItemHeight] to [LdList] and is scrolling to a certain page
    /// quickly. The debounce time will prevent fetching all the pages in
    /// between.
    this.debounceTime = const Duration(milliseconds: 500),
  }) {
    if (autoLoad) {
      _setBusy(true); // already set busy state to true (before debounced fetch)
      jumpToPage(startPage);
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator(
      // for LdPaginators with a fixed list, we set the debounce time to 0
      debounceTime: const Duration(milliseconds: 0),
      fetchListFunction: (
        int page,
        int loadedItems,
        String? pageToken,
      ) async {
        if (loadedItems == 0) {
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

  final SplayTreeMap<int, LdListPage<T>> _loadedPages = SplayTreeMap();
  Map<int, LdListPage<T>> get pages => _loadedPages;
  Timer? _debounceTimer;

  int get currentItemCount =>
      _loadedPages.values.fold(0, (sum, page) => sum + page.newItems.length);

  int _pageSize = _defaultPageSize;

  /// Returns the most common page size among the loaded pages.
  /// We use the most common page size rather than the "average" page size,
  /// as it is more realistic to have a consistent page size.
  int get pageSize => _pageSize;

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
    if (isBusy == _busy) return; // only notify if there is a change
    _busy = isBusy;
    notifyListeners();
  }

  Future<Iterable<T>?> _fetchPage(
    int pageToFetch, {
    bool refresh = false,
  }) async {
    _setBusy(true);
    Iterable<T>? list;

    try {
      final page = await fetchListFunction(
        pageToFetch,
        currentItemCount,
        null,
      );

      if (refresh) {
        // if this is a refresh operation, we clear the loaded pages, etc.
        _reset();
      }

      if (page.error != null) {
        _setError(page.error);
      } else {
        _totalItems = page.total;
        _loadedPages[pageToFetch] = page;
        _recalculateMostCommonPageSize();
        list = page.newItems;

        _setError(null);
      }
    } catch (e) {
      _setError(e);
    }
    _setBusy(false);

    return list;
  }

  /// Calculates the most common page size among the loaded pages.
  void _recalculateMostCommonPageSize() {
    _pageSize = _loadedPages.values.isEmpty
        ? _defaultPageSize
        : _loadedPages.values
            .fold<Map<int, int>>(
              {},
              (map, page) => map
                ..update(page.newItems.length, (count) => count + 1,
                    ifAbsent: () => 1),
            )
            .entries
            .reduce((max, entry) => entry.value > max.value ? entry : max)
            .key;
  }

  /// Jump to a specific page while keeping track of gaps
  Future<void> jumpToPage(int page) async {
    if (_loadedPages.containsKey(page)) return;
    return _debounceAndSafeExecute(() async {
      if (_loadedPages.containsKey(page)) {
        // Page has been loaded in the meantime, no need to fetch again
        notifyListeners();
      } else {
        final newElements = await _fetchPage(page);
        if (newElements != null && newElements.isNotEmpty) {
          notifyListeners();
        }
      }
    });
  }

  /// Refresh List means to clear the list and fetch the first page again.
  Future<void> refreshList() async {
    return _safeExecute(() async {
      final newElements = await _fetchPage(0, refresh: true);
      if (newElements != null && newElements.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  /// Clear and reset the pagination without fetching any data.
  Future<void> reset() {
    _debounceTimer?.cancel();
    return _safeExecute(() async {
      _reset();
      notifyListeners();
    });
  }

  /// Reset internal state of the paginator.
  void _reset() {
    _loadedPages.clear();
    _totalItems = 0;
    _pageSize = _defaultPageSize;
    _error = null;
  }

  /// Debounce a task to prevent multiple executions within a short time frame.
  void _debounce(void Function() task) {
    _debounceTimer?.cancel(); // Cancel the previous timer
    _debounceTimer = Timer(debounceTime, task); // Schedule the new task
  }

  /// Safely executes an operation, handles errors, and ensures cleanup.
  Future<R?> _safeExecute<R>(Future<R> Function() operation) async {
    await _currentOperation?.future; // Wait for pending operation to complete
    final completer = Completer<R?>();
    _currentOperation = completer;

    try {
      final result = await operation();
      completer.complete(result); // Complete with the result
    } catch (e) {
      completer.completeError(e); // Propagate the error
      rethrow;
    } finally {
      if (_currentOperation == completer) {
        _currentOperation = null; // Clean up
      }
    }

    return completer.future;
  }

  /// Combine [debounce] and [safeExecute] to prevent multiple executions
  Future<R?> _debounceAndSafeExecute<R>(Future<R> Function() operation) async {
    final completer = Completer<R?>();

    _debounce(() async {
      final result =
          await _safeExecute(operation); // Safely execute the operation
      completer.complete(result); // Complete the outer completer
    });

    return completer.future;
  }
}
