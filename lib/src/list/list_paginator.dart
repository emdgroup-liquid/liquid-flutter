import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/list/list_page.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function(
  int page,
  int loadedItems,
  String? pageToken,
);

enum PaginatorOperation { nextPage, prevPage, refreshList, jumpToPage }

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
      jumpToPage(startPage);
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator(fetchListFunction: (
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
    });
  }

  final SplayTreeMap<int, LdListPage<T>> _loadedPages = SplayTreeMap();
  Map<int, LdListPage<T>> get pages => _loadedPages;
  Timer? _debounceTimer;

  int get currentItemCount =>
      _loadedPages.values.fold(0, (sum, page) => sum + page.newItems.length);

  int get remainingItemsAbove => !hasMoreDataPrev
      ? 0
      : _currentTopPage *
          (currentItemCount ~/ (_currentBottomPage - _currentTopPage + 1));

  int get remainingItemsBelow => !hasMoreDataNext
      ? 0
      : (_totalItems - currentItemCount) - remainingItemsAbove;

  /// Returns the average page size among all loaded pages
  int get pageSize =>
      _loadedPages.isEmpty ? 10 : currentItemCount ~/ _loadedPages.length;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  int _currentTopPage = 0;
  int _currentBottomPage = 0;

  bool _hasMoreDataBottom = true;
  bool _hasMoreDataTop = true;

  int get currentTopPage => _currentTopPage;
  int get currentBottomPage => _currentBottomPage;

  bool get hasMoreDataNext => _hasMoreDataBottom;
  bool get hasMoreDataPrev => _hasMoreDataTop && _currentTopPage > 0;

  final Map<PaginatorOperation, bool> _busyStates = {
    PaginatorOperation.nextPage: false,
    PaginatorOperation.prevPage: false,
    PaginatorOperation.refreshList: false,
    PaginatorOperation.jumpToPage: false,
  };

  bool get busy => _busyStates.values.any((e) => e);
  bool busyWith(PaginatorOperation operation) => _busyStates[operation] == true;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  Completer? _currentOperation;

  void _setError(Object? error) {
    _error = error;
    notifyListeners();
  }

  void _setBusy(bool isBusy, {required PaginatorOperation operation}) {
    if (_busyStates[operation] == isBusy) return; // no change, skip
    _busyStates[operation] = isBusy;
    notifyListeners(); // only notify if there is a change
  }

  Future<Iterable<T>?> _fetchPage(int pageToFetch,
      {PaginatorOperation operation = PaginatorOperation.refreshList}) async {
    if (busyWith(operation)) return null;

    _setBusy(true, operation: operation);
    Iterable<T>? list;

    try {
      final page = await fetchListFunction(
        pageToFetch,
        switch (operation) {
          PaginatorOperation.refreshList => 0,
          _ => currentItemCount,
        },
        null,
      );

      if (page.error != null) {
        _setError(page.error);
      } else {
        _totalItems = page.total;
        _loadedPages[pageToFetch] = page;
        list = page.newItems;
        _hasMoreDataTop = _loadedPages.containsKey(0) ? false : true;
        _hasMoreDataBottom = page.hasMore;
        // if all pages are loaded, set total items to current item count
        if (!_hasMoreDataTop && !_hasMoreDataBottom) {
          _totalItems = currentItemCount;
        }

        _setError(null);
      }
    } catch (e) {
      _setError(e);
    }
    _setBusy(false, operation: operation);

    return list;
  }

  /// Jump to a specific page while keeping track of gaps
  Future<void> jumpToPage(int page) async {
    return _debounceAndSafeExecute(() async {
      if (_loadedPages.containsKey(page)) {
        // Page already loaded, update top/bottom indicators
        _updatePageRange();
        notifyListeners();
      } else {
        final newElements =
            await _fetchPage(page, operation: PaginatorOperation.jumpToPage);
        if (newElements != null && newElements.isNotEmpty) {
          _updatePageRange();
          notifyListeners();
        }
      }
    });
  }

  /// Load next page
  Future<void> nextPage() async {
    if (!hasMoreDataNext || busyWith(PaginatorOperation.nextPage)) return;
    return _debounceAndSafeExecute(() async {
      final nextPageNumber = _currentBottomPage + 1;
      final newElements = await _fetchPage(nextPageNumber,
          operation: PaginatorOperation.nextPage);
      if (newElements != null && newElements.isNotEmpty) {
        _updatePageRange();
        notifyListeners();
      }
    });
  }

  /// Load previous page
  Future<void> previousPage() async {
    if (!hasMoreDataPrev || busyWith(PaginatorOperation.prevPage)) return;
    return await _debounceAndSafeExecute(() async {
      final prevPageNumber = _currentTopPage - 1;
      final newElements = await _fetchPage(prevPageNumber,
          operation: PaginatorOperation.prevPage);
      if (newElements != null && newElements.isNotEmpty) {
        _updatePageRange();
        notifyListeners();
      }
    });
  }

  /// Refresh List
  Future<void> refreshList() async {
    _debounceTimer?.cancel();
    return _safeExecute(() async {
      final refreshedPage = await _fetchPage(startPage,
          operation: PaginatorOperation.refreshList);
      if (refreshedPage != null) {
        _updatePageRange();
        notifyListeners();
      }
    });
  }

  /// Update page tracking
  void _updatePageRange() {
    final loadedPages = _loadedPages.keys.toList();
    if (loadedPages.isNotEmpty) {
      _currentTopPage = loadedPages.reduce((a, b) => a < b ? a : b);
      _currentBottomPage = loadedPages.reduce((a, b) => a > b ? a : b);
    }
  }

  /// Clear and reset the pagination without fetching any data.
  void reset() {
    _debounceTimer?.cancel();
    _safeExecute(() async {
      _currentTopPage = startPage;
      _currentBottomPage = startPage;
      _hasMoreDataBottom = true;
      _hasMoreDataTop = startPage > 0;
      _loadedPages.clear();
      _busyStates.updateAll((key, value) => false);
      _error = null;
      notifyListeners();
    });
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
      await _currentOperation?.future; // Wait for pending operation to complete
      final result =
          await _safeExecute(operation); // Safely execute the operation
      completer.complete(result); // Complete the outer completer
    });

    return completer.future;
  }
}
