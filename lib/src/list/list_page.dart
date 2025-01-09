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
}
