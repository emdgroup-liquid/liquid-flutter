/// Describes why [LdListController.fetchListWithParameters] is being invoked.
enum LdFetchReason {
  /// First load when the paginator has no data yet.
  initial,

  /// User scrolled and a new page offset is being requested.
  pagination,

  /// Active filters changed; paginator view is reset before fetch.
  filter,

  /// Sort options changed; paginator view is reset before fetch.
  sort,

  /// User-initiated refresh (pull-to-refresh, refresh action).
  refresh,

  /// External invalidation (e.g. after CRUD); paginator view is reset.
  invalidate,
}
