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
}
