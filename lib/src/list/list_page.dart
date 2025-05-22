import 'dart:math';

class LdListPage<T> {
  final List<T> newItems;
  final bool hasMore;
  final int total;
  final String? nextPageToken;
  final Object? error;
  LdListPage({
    required this.newItems,
    required this.hasMore,
    required this.total,
    this.error,
    this.nextPageToken,
  });

  LdListPage<T> copyWith({
    List<T>? newItems,
    bool? hasMore,
    int? total,
    String? nextPageToken,
    Object? error,
  }) {
    return LdListPage<T>(
      newItems: newItems ?? this.newItems,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      error: error ?? this.error,
    );
  }

  factory LdListPage.fromList(
    List<T> items, {
    int offset = 0,
    int pageSize = 10,
  }) {
    final endIndex = min(offset + pageSize, items.length);
    final pageItems =
        offset >= items.length ? <T>[] : items.sublist(offset, endIndex);
    final hasMore = endIndex < items.length;
    return LdListPage<T>(
      newItems: pageItems,
      hasMore: hasMore,
      total: items.length,
    );
  }
}
