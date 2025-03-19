import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef FetchListFunction<T> = Future<LdListPage<T>> Function(
  int page,
  int loadedItems,
  String? nextPageToken,
);

class LdPaginator<T> extends ChangeNotifier {
  final FetchListFunction<T> fetchListFunction;

  LdPaginator({
    required this.fetchListFunction,
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      nextPage();
    }
  }

  factory LdPaginator.fromList(List<T> list) {
    return LdPaginator(fetchListFunction: (
      int page,
      int loadedItems,
      String? nextPageToken,
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
  int _currentPage = 0;
  bool _hasMoreData = true;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  int get remainingItems => max(0, _totalItems - _currentList.length);

  List<T> get currentList => _currentList;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;

  bool _busy = false;
  bool get busy => _busy;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  void _setError(Object? error) {
    _error = error;
    notifyListeners();
  }

  void _setBusy(bool isBusy) {
    _busy = isBusy;
    notifyListeners();
  }

  Future<Iterable<T>?> _fetchNextPage({bool isRefresh = false}) async {
    if (_busy) {
      return null;
    }

    _setBusy(true);
    Iterable<T>? list;

    try {
      final page = await fetchListFunction(
        isRefresh ? 0 : _currentPage,
        isRefresh ? 0 : _currentList.length,
        null,
      );

      if (page.error != null) {
        _setError(page.error);
      } else {
        _hasMoreData = page.hasMore;
        _totalItems = page.total;
        list = page.newItems;

        if (_hasMoreData && list.isNotEmpty) {
          _currentPage++;
        }

        _setError(null);
      }
    } catch (e) {
      _setError(e);
    }
    _setBusy(false);

    return list;
  }

  /// Load more data
  Future<void> nextPage() async {
    final newElements = await _fetchNextPage();

    if (newElements != null && newElements.isNotEmpty) {
      _currentList.addAll(newElements);
      notifyListeners();
    }
  }

  /// Refresh the list, keeps the current content until the initial page is loaded.
  Future<void> refreshList() async {
    // Reset the pagination
    _currentPage = 0;

    final initialPage = await _fetchNextPage(isRefresh: true);

    if (initialPage != null) {
      _currentList.clear();
      _currentList.addAll(initialPage);

      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// Clear and reset the pagination without fetching any data.
  void reset() {
    _currentPage = 0;
    _hasMoreData = true;
    _currentList.clear();
    _busy = false;
    _error = null;
    notifyListeners();
  }
}
