import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdRepository<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? _getOffsetById;

  final Future<T?> Function(BuildContext context, IdType id, T newItem)? _updateItem;
  final Future<T> Function(BuildContext context, T? newItem)? _createItem;
  final Future<T> Function(IdType id) _getById;
  final Future<void> Function(BuildContext context, IdType id)? _deleteItem;
  final Future<void> Function(BuildContext context, Set<IdType> ids)? _deleteBatch;
  final Future<void> Function(BuildContext context, Set<T> items)? _updateBatch;

  final bool _isGreedy;
  final bool _autoCache;
  final bool _autoInvalidateCache;
  final bool _autoInvalidateCacheOnMutation;
  bool _greedyLoadComplete = false;

  IdType? _lastSelectionAnchorId;

  /// This map is used to store items that were fetched, but can not be sorted
  /// into the paginator since we dont know the actual offset.
  /// We can not simply append them to the list, since that might break the pagination.
  final Map<IdType, LdPaginatorItem<T>> _detachedItemsById = {};

  /// Per-repository cache available in [FetchPageParameters.cache].
  final LdRepositoryCache<T, IdType> cache;

  factory LdRepository({
    required Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    int pageSize = 10,
    List<T>? initialItems,
    required Future<T> Function(IdType id) getById,
    Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? getOffsetById,
    Future<void> Function(BuildContext context, IdType id)? deleteItem,
    Future<T?> Function(BuildContext context, IdType id, T newItem)? updateItem,
    Future<T> Function(BuildContext context, T? newItem)? createItem,
    Future<void> Function(BuildContext context, Set<IdType> ids)? deleteBatch,
    Future<void> Function(BuildContext context, Set<T> items)? updateBatch,
    bool isGreedy = false,
    bool autoCache = true,
    bool autoInvalidateCache = true,
    bool autoInvalidateCacheOnMutation = true,
    LdRepositoryCache<T, IdType>? cache,
  }) {
    final resolvedCache = cache ?? LdRepositoryCache<T, IdType>();
    return LdRepository._(
      fetchListWithParameters: fetchListWithParameters,
      pageSize: pageSize,
      initialItems: initialItems,
      getById: getById,
      getOffsetById: getOffsetById,
      deleteItem: deleteItem,
      updateItem: updateItem,
      createItem: createItem,
      deleteBatch: deleteBatch,
      updateBatch: updateBatch,
      isGreedy: isGreedy,
      autoCache: autoCache,
      autoInvalidateCache: autoInvalidateCache,
      autoInvalidateCacheOnMutation: autoInvalidateCacheOnMutation,
      cache: resolvedCache,
    );
  }

  LdRepository._({
    required Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    required int pageSize,
    List<T>? initialItems,
    required Future<T> Function(IdType id) getById,
    Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? getOffsetById,
    Future<void> Function(BuildContext context, IdType id)? deleteItem,
    Future<T?> Function(BuildContext context, IdType id, T newItem)? updateItem,
    Future<T> Function(BuildContext context, T? newItem)? createItem,
    Future<void> Function(BuildContext context, Set<IdType> ids)? deleteBatch,
    Future<void> Function(BuildContext context, Set<T> items)? updateBatch,
    required bool isGreedy,
    required bool autoCache,
    required bool autoInvalidateCache,
    required bool autoInvalidateCacheOnMutation,
    required this.cache,
  })  : _getById = getById,
        _getOffsetById = getOffsetById,
        _deleteItem = deleteItem,
        _updateItem = updateItem,
        _createItem = createItem,
        _deleteBatch = deleteBatch,
        _updateBatch = updateBatch,
        _isGreedy = isGreedy,
        _autoCache = autoCache,
        _autoInvalidateCache = autoInvalidateCache,
        _autoInvalidateCacheOnMutation = autoInvalidateCacheOnMutation,
        super(
          pageSize: pageSize,
          initialItems: initialItems,
          repositoryCache: cache,
        ) {
    fetchListFunction = (parameters) => _fetchWithAutoCache(
          fetchListWithParameters,
          parameters,
        );
  }

  Future<LdListPage<T>> _fetchWithAutoCache(
    Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    FetchPageParameters<T, IdType> parameters,
  ) async {
    if (_autoInvalidateCache &&
        (parameters.reason == LdFetchReason.refresh || parameters.reason == LdFetchReason.invalidate)) {
      cache.clear();
    }

    if (_autoCache && parameters.reason == LdFetchReason.pagination) {
      final cachedPage = cache.readPage(parameters.cacheKey, parameters.offset);
      if (cachedPage != null) {
        final entry = cache.readEntry(parameters.cacheKey)!;
        return LdListPage<T>(
          newItems: cachedPage,
          hasMore: parameters.offset + cachedPage.length < entry.total,
          total: entry.total,
        );
      }
    }

    final page = await fetchListWithParameters(parameters);

    if (_autoCache) {
      cache.writePage(
        parameters.cacheKey,
        offset: parameters.offset,
        items: page.newItems,
        total: page.total,
      );
    }

    return page;
  }

  bool get isGreedy => _isGreedy;

  /// Whether a greedy repository has finished loading the full dataset.
  bool get isDataComplete => _isGreedy && _greedyLoadComplete;

  /// Eagerly loads every page via [fetchListWithParameters] until [LdListPage.hasMore]
  /// is false. No-op for non-greedy repositories or when already complete.
  Future<void> ensureGreedyLoaded(BuildContext context) async {
    if (!_isGreedy || _greedyLoadComplete) {
      return;
    }

    await eagerFetchAllPages(context);

    if (context.mounted) {
      _greedyLoadComplete = true;
    }
  }

  void _maybeInvalidateOnMutation(
    BuildContext context, {
    required LdRepositoryMutationKind kind,
    T? before,
    T? after,
  }) {
    if (!_autoInvalidateCacheOnMutation) {
      return;
    }

    cache.invalidateOnMutation(
      context: context,
      kind: kind,
      before: before,
      after: after,
    );
  }

  Future<T> create(BuildContext context, T? newValue, {int? index}) async {
    assert(
      _createItem != null,
      'Cannot create item. createItem was not configured for this repository',
    );
    _maybeInvalidateOnMutation(
      context,
      kind: LdRepositoryMutationKind.create,
      before: null,
      after: newValue,
    );
    final tempIndex = scheduleItemCreation(newValue, index: index);
    try {
      final newItem = await _createItem!(context, newValue);
      if (!context.mounted) {
        return newItem;
      }

      if (_getOffsetById != null) {
        await _finalizeCreateWithOffset(context, newItem: newItem, tempIndex: tempIndex);
      } else {
        rollbackItemCreation(tempIndex);
        removeItemAtIndex(tempIndex);
        await refreshList(
          context: context,
          reason: LdFetchReason.invalidate,
          anchorId: newItem.id,
        );
      }
      return newItem;
    } catch (e, stackTrace) {
      if (ldPrintDebugMessages) {
        debugPrint("Error creating item: $e");
        debugPrint(stackTrace.toString());
      }

      rollbackItemCreation(tempIndex);
      rethrow;
    }
  }

  Future<void> _finalizeCreateWithOffset(
    BuildContext context, {
    required T newItem,
    required int tempIndex,
  }) async {
    final offset = await _getOffsetById!(
      FetchOffsetParameters(
        context: context,
        id: newItem.id,
        reason: LdFetchReason.invalidate,
        cache: cache,
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (offset != null && offset >= 0) {
      removeItemAtIndex(tempIndex);
      repositionItemById(
        newItem.id,
        newIndex: offset,
        value: newItem,
      );
      requestScrollToItem(newItem.id);
      return;
    }

    rollbackItemCreation(tempIndex);
    removeItemAtIndex(tempIndex);
    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: newItem.id,
    );
  }

  Future<void> delete({required BuildContext context, required IdType id}) async {
    if (_deleteItem == null) {
      return;
    }

    _maybeInvalidateOnMutation(
      context,
      kind: LdRepositoryMutationKind.delete,
    );
    _scheduleDeletionForId(id);
    try {
      await _deleteItem(context, id);
      if (!context.mounted) {
        return;
      }
      _confirmDeletionForId(context, id);
    } catch (e) {
      _rollbackDeletionForId(id);
      rethrow;
    }
  }

  bool _isDetached(IdType id) {
    return super.getItemById(id) == null && _detachedItemsById.containsKey(id);
  }

  void _scheduleDeletionForId(IdType id) {
    if (_isDetached(id)) {
      final item = _detachedItemsById[id]!;
      _detachedItemsById[id] = item.copyWith(state: LdPaginatorItemState.deleting);
      notifyItemUpdated(_detachedItemsById[id]!);
      return;
    }

    if (getItemIndexById(id) != null) {
      scheduleItemDeletion(id);
    }
  }

  void _confirmDeletionForId(
    BuildContext context,
    IdType id, {
    bool refresh = false,
  }) {
    final detachedItem = _detachedItemsById.remove(id);
    if (detachedItem != null) {
      notifyItemUpdated(
        detachedItem.copyWith(state: LdPaginatorItemState.deleted),
      );
      return;
    }

    if (getItemIndexById(id) != null) {
      unawaited(_confirmPagedDeletion(context, id: id, refresh: refresh));
    }
  }

  Future<void> _confirmPagedDeletion(
    BuildContext context, {
    required IdType id,
    required bool refresh,
  }) async {
    final compacted = confirmItemDeletion(
      context: context,
      refresh: refresh,
      id: id,
    );

    if (compacted || refresh || !context.mounted) {
      return;
    }

    if (_isGreedy && isDataComplete) {
      await eagerFetchAllPages(context);
      return;
    }

    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: _resolveDeletionAnchorId(id),
    );
  }

  void _rollbackDeletionForId(IdType id) {
    final detachedItem = _detachedItemsById[id];
    if (detachedItem != null) {
      if (detachedItem.state == LdPaginatorItemState.deleting) {
        _detachedItemsById[id] = detachedItem.copyWith(state: LdPaginatorItemState.loaded);
        notifyItemUpdated(_detachedItemsById[id]!);
      }
      return;
    }

    if (getItemIndexById(id) == null) {
      return;
    }

    try {
      rollbackItemDeletion(id);
    } catch (_) {
      // Item may have been removed while the delete request was in flight.
    }
  }

  @override
  bool confirmItemDeletion({
    required BuildContext context,
    bool refresh = false,
    required IdType id,
  }) {
    _detachedItemsById.remove(id);
    return super.confirmItemDeletion(
      context: context,
      refresh: refresh,
      id: id,
    );
  }

  Future<void> deleteBatch({required BuildContext context, required Set<IdType> ids}) async {
    if (ids.isEmpty) {
      return;
    }

    if (_deleteBatch == null) {
      _maybeInvalidateOnMutation(
        context,
        kind: LdRepositoryMutationKind.delete,
      );
      for (final id in ids) {
        _scheduleDeletionForId(id);
      }

      try {
        for (final id in ids) {
          await _deleteItem!(context, id);
          if (!context.mounted) {
            return;
          }
        }
      } catch (e) {
        for (final id in ids) {
          _rollbackDeletionForId(id);
        }
        rethrow;
      }

      for (final id in ids) {
        if (!context.mounted) {
          break;
        }
        _confirmDeletionForId(context, id);
      }
      return;
    }

    final exceptions = <dynamic>[];
    _maybeInvalidateOnMutation(
      context,
      kind: LdRepositoryMutationKind.delete,
    );
    for (final id in ids) {
      _scheduleDeletionForId(id);
    }
    try {
      await _deleteBatch(context, ids);

      for (final id in ids) {
        if (!context.mounted) {
          break;
        }
        _confirmDeletionForId(context, id, refresh: false);
      }
    } catch (e) {
      for (final id in ids) {
        _rollbackDeletionForId(id);
      }
      exceptions.add(e);
    }

    if (exceptions.isNotEmpty && context.mounted) {
      refreshList(context: context);
      throw Exception(exceptions);
    }
  }

  Future<T> getById(IdType id, {bool skipCache = false}) async {
    if (!skipCache) {
      final item = getItemById(id);
      if (item != null) {
        return item.value!;
      }
    }
    return await _getById(id);
  }

  @override
  LdPaginatorItem<T>? getItemById(IdType id) {
    final pagedItem = super.getItemById(id);
    if (pagedItem != null) {
      _detachedItemsById.remove(id);
      return pagedItem;
    }
    return _detachedItemsById[id];
  }

  Future<void> ensureSelectionLoaded(
    BuildContext context,
    Set<IdType> selection,
  ) async {
    if (selection.isEmpty) {
      return;
    }
    _lastSelectionAnchorId = selection.first;

    if (_getOffsetById != null) {
      final firstOffset = await _getOffsetById(
        FetchOffsetParameters(
          context: context,
          id: selection.first,
          reason: LdFetchReason.initial,
          cache: cache,
        ),
      );
      initialOffset = firstOffset ?? initialOffset;
      if (firstOffset != null && context.mounted) {
        await fetchPageAtOffset(
          context,
          firstOffset,
        );
      }
    }

    if (!context.mounted) {
      return;
    }

    for (final id in selection) {
      if (super.getItemById(id) != null) {
        _detachedItemsById.remove(id);
      }
    }

    final missingIds = selection.where((id) => getItemById(id) == null).toList();
    for (final id in missingIds) {
      try {
        final item = await _getById(id);
        if (!context.mounted) {
          return;
        }
        _detachedItemsById[id] = LdPaginatorItem<T>(
          value: item,
          state: LdPaginatorItemState.loaded,
        );
        notifyListeners();
      } catch (e, s) {
        if (ldPrintDebugMessages) {
          debugPrint('Error loading selected item by id: $e');
          debugPrint(s.toString());
        }
      }
    }
  }

  Future<void> initWithSelection(BuildContext context, Set<IdType> selection) async {
    await ensureSelectionLoaded(
      context,
      selection,
    );
  }

  @override
  Future<void> refreshList({
    required BuildContext context,
    LdFetchReason reason = LdFetchReason.refresh,
    @Deprecated('Use reason: LdFetchReason.refresh') bool hard = false,
    IdType? anchorId,
  }) async {
    final effectiveReason = hard ? LdFetchReason.refresh : reason;

    if (effectiveReason == LdFetchReason.refresh) {
      _detachedItemsById.clear();
    }

    if (effectiveReason == LdFetchReason.filter || effectiveReason == LdFetchReason.sort) {
      initialOffset = 0;
    } else if (effectiveReason == LdFetchReason.invalidate) {
      final effectiveAnchorId = anchorId ?? _resolveDefaultRefreshAnchorId();

      if (effectiveAnchorId != null && _getOffsetById != null) {
        final anchorOffset = await _getOffsetById(
          FetchOffsetParameters(
            context: context,
            id: effectiveAnchorId,
            reason: effectiveReason,
            cache: cache,
          ),
        );
        initialOffset = anchorOffset != null && anchorOffset >= 0 ? anchorOffset : 0;
      } else {
        initialOffset = 0;
      }
    } else if (effectiveReason == LdFetchReason.refresh) {
      final effectiveAnchorId = anchorId ?? _resolveDefaultRefreshAnchorId();

      if (effectiveAnchorId != null && _getOffsetById != null) {
        final anchorOffset = await _getOffsetById(
          FetchOffsetParameters(
            context: context,
            id: effectiveAnchorId,
            reason: effectiveReason,
            cache: cache,
          ),
        );
        if (anchorOffset != null) {
          initialOffset = anchorOffset;
        }
      }
    }

    if (!context.mounted) {
      return;
    }

    await super.refreshList(
      context: context,
      reason: effectiveReason,
      hard: false,
    );
  }

  @override
  void confirmItemUpdate(IdType id, T? newValue) {
    final detachedItem = _detachedItemsById[id];
    if (detachedItem != null) {
      _detachedItemsById[id] = LdPaginatorItem<T>(
        value: newValue ?? detachedItem.value,
        state: LdPaginatorItemState.loaded,
      );
    }
    super.confirmItemUpdate(id, newValue);
  }

  Future<void> update(BuildContext context, IdType id, T newValue, {bool skipLayout = false}) async {
    if (_updateItem != null) {
      final before = getItemById(id)?.value;
      _maybeInvalidateOnMutation(
        context,
        kind: LdRepositoryMutationKind.update,
        before: before,
        after: newValue,
      );
      scheduleItemUpdate(id, newValue);
      try {
        final newItemFromServer = await _updateItem(context, id, newValue);
        final newItem = newItemFromServer ?? newValue;
        if (!context.mounted) {
          return;
        }
        confirmItemUpdate(id, newItem);
        if (!skipLayout) {
          await _applyPostUpdateLayout(
            context,
            id: id,
            before: before,
            after: newItem,
          );
        }
      } catch (e) {
        await rollbackItemUpdate(id);
        rethrow;
      }
    }
  }

  /// Optimistically shuffles indices, then persists the moved item via [reorderHandler].
  ///
  /// Layout is already applied by [reorderIndices]; post-update reposition is skipped.
  Future<void> reorder(
    BuildContext context, {
    required IdType id,
    required int fromIndex,
    required int toIndex,
    required LdMonkeyReorderHandler<T, IdType> reorderHandler,
  }) async {
    if (fromIndex == toIndex) {
      return;
    }

    reorderIndices(fromIndex, toIndex);

    final item = getItemById(id)?.value ?? await getById(id);
    final updated = await reorderHandler(context, item, fromIndex, toIndex);
    if (!context.mounted) {
      return;
    }
    await update(context, id, updated, skipLayout: true);
  }

  Future<void> updateBatch(BuildContext context, Set<T> items) async {
    final layoutChecks = <IdType, ({T? before, T after})>{};
    for (final item in items) {
      final before = getItemById(item.id)?.value;
      layoutChecks[item.id] = (before: before, after: item);
      _maybeInvalidateOnMutation(
        context,
        kind: LdRepositoryMutationKind.update,
        before: before,
        after: item,
      );
      scheduleItemUpdate(item.id, item);
    }
    if (_updateBatch != null) {
      try {
        await _updateBatch(context, items);
        for (final item in items) {
          confirmItemUpdate(item.id, item);
        }
        if (context.mounted) {
          await _applyPostUpdateLayoutBatch(context, layoutChecks);
        }
      } catch (e) {
        for (final item in items) {
          await rollbackItemUpdate(item.id);
        }
        rethrow;
      }
    } else {
      final exceptions = <dynamic>[];
      for (final item in items) {
        try {
          final newItem = await _updateItem!(context, item.id, item);
          final resolved = newItem ?? item;
          confirmItemUpdate(item.id, resolved);
          layoutChecks[item.id] = (
            before: layoutChecks[item.id]!.before,
            after: resolved,
          );
        } catch (e) {
          await rollbackItemUpdate(item.id);
          exceptions.add(e);
        }
      }

      if (exceptions.isNotEmpty) {
        throw Exception(exceptions);
      }

      if (context.mounted) {
        await _applyPostUpdateLayoutBatch(context, layoutChecks);
      }
    }
  }

  Future<void> _applyPostUpdateLayoutBatch(
    BuildContext context,
    Map<IdType, ({T? before, T after})> layoutChecks,
  ) async {
    var needsRefresh = false;
    IdType? refreshAnchorId;

    for (final entry in layoutChecks.entries) {
      if (!isLayoutAffectedByUpdate<T, IdType>(
        context: context,
        before: entry.value.before,
        after: entry.value.after,
      )) {
        continue;
      }

      if (_getOffsetById != null) {
        await _applyPostUpdateLayout(
          context,
          id: entry.key,
          before: entry.value.before,
          after: entry.value.after,
        );
      } else {
        needsRefresh = true;
        refreshAnchorId ??= entry.key;
      }
    }

    if (needsRefresh && context.mounted) {
      await refreshList(
        context: context,
        reason: LdFetchReason.invalidate,
        anchorId: refreshAnchorId,
      );
    }
  }

  Future<void> _applyPostUpdateLayout(
    BuildContext context, {
    required IdType id,
    required T? before,
    required T after,
  }) async {
    final layoutAffected = isLayoutAffectedByUpdate<T, IdType>(
      context: context,
      before: before,
      after: after,
    );
    if (!layoutAffected) {
      return;
    }

    final getOffsetById = _getOffsetById;
    if (getOffsetById != null) {
      final offset = await getOffsetById(
        FetchOffsetParameters(
          context: context,
          id: id,
          reason: LdFetchReason.invalidate,
          cache: cache,
        ),
      );

      if (!context.mounted) {
        return;
      }

      if (offset != null && offset >= 0) {
        repositionItemById(
          id,
          newIndex: offset,
          value: after,
        );
        requestScrollToItem(id);
      } else {
        final index = getItemIndexById(id);
        if (index != null) {
          removeItemAtIndex(index);
        }
      }
      return;
    }

    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: id,
    );
  }

  IdType? _resolveDeletionAnchorId(IdType deletedId) {
    if (_lastSelectionAnchorId != null && _lastSelectionAnchorId != deletedId) {
      return _lastSelectionAnchorId;
    }

    return itemsMap.entries
        .where((entry) => entry.value.value != null && entry.value.value!.id != deletedId)
        .map((entry) => entry.value.value!.id)
        .firstOrNull;
  }

  IdType? _resolveDefaultRefreshAnchorId() {
    final currentItem = getItemAt(initialOffset);
    if (currentItem?.value != null) {
      return currentItem!.value!.id;
    }

    if (_lastSelectionAnchorId != null) {
      return _lastSelectionAnchorId;
    }

    return itemsMap.entries
        .where((entry) => entry.value.value != null)
        .map((entry) => entry.value.value!.id)
        .firstOrNull;
  }

  /// Creates a repository that eagerly loads the full dataset on init by
  /// calling [fetchListWithParameters] for every page until [LdListPage.hasMore]
  /// is false (or a single page with `hasMore: false`).
  ///
  /// Pages are cached automatically under [FetchPageParameters.cacheKey] unless
  /// [autoCache] is disabled.
  static LdRepository<L, IdType> greedy<L extends Identifiable<IdType>, IdType>({
    required Future<LdListPage<L>> Function(FetchPageParameters<L, IdType> parameters) fetchListWithParameters,
    required Future<L> Function(IdType id) getById,
    int pageSize = 50,
    bool autoCache = true,
    bool autoInvalidateCache = true,
    bool autoInvalidateCacheOnMutation = true,
    Future<int?> Function(FetchOffsetParameters<L, IdType> parameters)? getOffsetById,
    Future<void> Function(BuildContext context, IdType id)? deleteItem,
    Future<L?> Function(BuildContext context, IdType id, L newItem)? updateItem,
    Future<L> Function(BuildContext context, L? newItem)? createItem,
    Future<void> Function(BuildContext context, Set<IdType> ids)? deleteBatch,
    Future<void> Function(BuildContext context, Set<L> items)? updateBatch,
  }) {
    return LdRepository<L, IdType>(
      fetchListWithParameters: fetchListWithParameters,
      getById: getById,
      pageSize: pageSize,
      autoCache: autoCache,
      autoInvalidateCache: autoInvalidateCache,
      autoInvalidateCacheOnMutation: autoInvalidateCacheOnMutation,
      getOffsetById: getOffsetById,
      deleteItem: deleteItem,
      updateItem: updateItem,
      createItem: createItem,
      deleteBatch: deleteBatch,
      updateBatch: updateBatch,
      isGreedy: true,
    );
  }

  static LdRepository<L, IdType> fromList<L extends Identifiable<IdType>, IdType>({
    required List<L> list,
    bool Function(L item, Set<LdFilterOption<L, IdType>>? activeFilters)? filterFunction,
    int Function(L a, L b, List<LdSortOption<L, IdType>>? activeSortOptions)? sortFunction,
    int pageSize = 50,
  }) {
    return LdRepository.greedy<L, IdType>(
      pageSize: pageSize,
      getById: (id) async => list.firstWhere((item) => item.id == id),
      fetchListWithParameters: (parameters) async {
        var filtered = list.toList();
        final filters = parameters.filters;
        final sortOptions = parameters.sortOptions;

        if (filterFunction != null && filters.isNotEmpty) {
          filtered = filtered.where((item) => filterFunction(item, filters)).toList();
        }

        if (sortFunction != null && sortOptions.isNotEmpty) {
          filtered.sort((a, b) => sortFunction(a, b, sortOptions));
        }

        return LdListPage<L>(
          newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
          hasMore: parameters.offset + parameters.pageSize < filtered.length,
          total: filtered.length,
        );
      },
    );
  }

  static LdRepository<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>?>();
  }

  static LdRepository<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdRepository<T, IdType>>();
  }
}
