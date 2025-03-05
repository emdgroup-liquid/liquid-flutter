import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/list/list_page.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function(
  int page,
  int loadedItems,
  String? pageToken,
);

enum PaginatorOperation { nextPage, prevPage, refreshList }

class LdPaginator<T> extends ChangeNotifier {
  FetchListFunction<T> fetchListFunction;
  final int startPage;

  LdPaginator({
    required this.fetchListFunction,
    bool autoLoad = true,
    this.startPage = 0,
  }) {
    _currentTopPage = startPage;
    _currentBottomPage = startPage;
    if (autoLoad) {
      loadPage(startPage);
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

  void updateWhere(bool Function(T) predicate, T Function(T) update) {
    final index = _currentList.indexWhere(predicate);
    if (index != -1) {
      _currentList[index] = update(_currentList[index]);
      notifyListeners();
    }
  }

  final List<T> _currentList = [];
  int _currentTopPage = 0;
  int _currentBottomPage = 0;
  bool _hasMoreDataBottom = true;
  bool _hasMoreDataTop = true;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  int get remainingItemsAbove => !hasMoreDataPrev
      ? 0
      : _currentTopPage *
          (_currentList.length ~/ (_currentBottomPage - _currentTopPage + 1));
  int get remainingItemsBelow => !hasMoreDataNext
      ? 0
      : (_totalItems - _currentList.length) - remainingItemsAbove;

  List<T> get currentList => _currentList;
  int get currentTopPage => _currentTopPage;
  int get currentBottomPage => _currentBottomPage;

  // For backward compatibility
  int get currentPage => _currentBottomPage;

  bool get hasMoreDataNext => _hasMoreDataBottom;
  bool get hasMoreDataPrev => _hasMoreDataTop && _currentTopPage > 0;

  // For backward compatibility
  bool get hasMoreData => hasMoreDataNext;
  bool get hasMorePrevData => hasMoreDataPrev;

  final Map<PaginatorOperation, bool> _busyStates = {
    PaginatorOperation.nextPage: false,
    PaginatorOperation.prevPage: false,
    PaginatorOperation.refreshList: false,
  };
  bool get busy => _busyStates.values.any((e) => e);
  bool busyWith(PaginatorOperation operation) => _busyStates[operation] == true;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  // Completer to manage ongoing pagination operations
  Completer<void>? _currentOperation;

  void _setError(Object? error) {
    _error = error;
    notifyListeners();
  }

  void _setBusy(bool isBusy,
      {PaginatorOperation operation = PaginatorOperation.refreshList}) {
    _busyStates[operation] = isBusy;
    notifyListeners();
  }

  Future<Iterable<T>?> _fetchPage(int pageToFetch,
      {PaginatorOperation operation = PaginatorOperation.refreshList}) async {
    if (_busyStates[operation] == true) {
      return null;
    }

    _setBusy(true, operation: operation);
    Iterable<T>? list;

    try {
      final page = await fetchListFunction(
        pageToFetch,
        operation == PaginatorOperation.refreshList ? 0 : _currentList.length,
        null,
      );

      if (page.error != null) {
        _setError(page.error);
      } else {
        _totalItems = page.total;
        list = page.newItems;

        // Update appropriate pagination flags based on where we're fetching from
        if (pageToFetch <= _currentTopPage) {
          _hasMoreDataTop = pageToFetch > 0;
        }
        if (pageToFetch >= _currentBottomPage) {
          _hasMoreDataBottom = page.hasMore;
        }

        _setError(null);
      }
    } catch (e) {
      _setError(e);
    }
    _setBusy(false, operation: operation);

    return list;
  }

  /// Load more data (next page) and append to bottom
  Future<void> nextPage() async {
    if (!hasMoreDataNext || busyWith(PaginatorOperation.nextPage)) return;
    return _safeExecute(() async {
      if (!hasMoreDataNext || busyWith(PaginatorOperation.nextPage)) return;
      final nextPageNumber = _currentBottomPage + 1;
      final newElements = await _fetchPage(nextPageNumber,
          operation: PaginatorOperation.nextPage);

      if (newElements != null && newElements.isNotEmpty) {
        _currentList.addAll(newElements);
        _currentBottomPage = nextPageNumber;
        notifyListeners();
      }
    });
  }

  /// Load previous page data and prepend to the current list
  Future<void> previousPage() async {
    if (!hasMoreDataPrev || busyWith(PaginatorOperation.prevPage)) return;
    return _safeExecute(() async {
      if (!hasMoreDataPrev || busyWith(PaginatorOperation.prevPage)) return;
      final prevPageNumber = _currentTopPage - 1;
      final newElements = await _fetchPage(prevPageNumber,
          operation: PaginatorOperation.prevPage);

      if (newElements != null && newElements.isNotEmpty) {
        _currentList.insertAll(0, newElements);
        _currentTopPage = prevPageNumber;
        notifyListeners();
      }
    });
  }

  /// Load a specific page, replacing current content
  Future<void> loadPage(int page) async {
    return _safeExecute(() async {
      final newElements = await _fetchPage(page);

      if (newElements != null && newElements.isNotEmpty) {
        _currentList.clear();
        _currentList.addAll(newElements);
        _currentTopPage = page;
        _currentBottomPage = page;
        notifyListeners();
      }
    });
  }

  /// Refresh the list, keeps the current content until the initial page is loaded
  Future<void> refreshList() async {
    return _safeExecute(() async {
      if (busyWith(PaginatorOperation.refreshList)) return;

      // Reset to the initial page (either startPage or current page based on preference)
      final pageToRefresh = startPage;
      final refreshedPage = await _fetchPage(pageToRefresh,
          operation: PaginatorOperation.refreshList);

      if (refreshedPage != null) {
        _currentList.clear();
        _currentList.addAll(refreshedPage);
        _currentTopPage = pageToRefresh;
        _currentBottomPage = pageToRefresh;
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  /// Clear and reset the pagination without fetching any data.
  void reset() {
    _safeExecute(() async {
      _currentTopPage = startPage;
      _currentBottomPage = startPage;
      _hasMoreDataBottom = true;
      _hasMoreDataTop = startPage > 0;
      _currentList.clear();
      _busyStates.updateAll((key, value) => false);
      _error = null;
      notifyListeners();
    });
  }

  /// Ensures only one pagination operation runs at a time
  Future<void> _safeExecute(Future<void> Function() operation) async {
    // If there's an ongoing operation, wait for it to complete
    await _currentOperation?.future;

    // Create a new completer for this operation
    final completer = Completer<void>();
    _currentOperation = completer;

    try {
      await operation();
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      // Clear the current operation if it's the same one
      if (_currentOperation == completer) {
        _currentOperation = null;
      }
    }
  }
}
