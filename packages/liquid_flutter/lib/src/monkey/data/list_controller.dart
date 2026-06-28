import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache_key.dart';
import 'package:provider/provider.dart';

class LdListController<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? _getOffsetById;

  final Future<T> Function(BuildContext context, IdType id) _getById;

  final bool _isGreedy;
  final bool _autoCache;
  final bool _autoInvalidateCache;
  final bool _autoInvalidateCacheOnMutation;
  bool _greedyLoadComplete = false;

  LdModel<T, IdType, Object?, Object?>? _attachedModel;

  /// The [LdModel] wired to this list controller via [fromModel].
  LdModel<T, IdType, Object?, Object?>? get model => _attachedModel;

  IdType? _lastSelectionAnchorId;

  /// This map is used to store items that were fetched, but can not be sorted
  /// into the paginator since we dont know the actual offset.
  /// We can not simply append them to the list, since that might break the pagination.
  final Map<IdType, LdPaginatorItem<T>> _detachedItemsById = {};

  /// Per-list-controller cache available in [FetchPageParameters.cache].
  final LdListCache<T, IdType> cache;

  /// Synchronous guard for the [refreshList] override: set to `true`
  /// immediately (before any `await`) so that a second concurrent call that
  /// enters during the async anchor-offset resolution is dropped instead of
  /// racing to commit its own refresh results on top of the first.
  bool _refreshInProgress = false;

  factory LdListController.fromModel(
    LdModel<T, IdType, Object?, Object?> model, {
    List<T>? initialItems,
  }) {
    final resolvedCache = model.cache ?? LdListCache<T, IdType>();
    final controller = LdListController._(
      fetchListWithParameters: model.fetchListWithParameters,
      pageSize: model.pageSize,
      initialItems: initialItems ?? (model is LdCallbackModel<T, IdType> ? model.initialItems : null),
      getById: model.getById,
      getOffsetById: model.getOffsetById,
      isGreedy: model.isGreedy,
      autoCache: model.autoCache,
      autoInvalidateCache: model.autoInvalidateCache,
      autoInvalidateCacheOnMutation: model.autoInvalidateCacheOnMutation,
      cache: resolvedCache,
    );
    model.attachListController(controller);
    return controller;
  }

  LdListController._({
    required Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    required super.pageSize,
    super.initialItems,
    required Future<T> Function(BuildContext context, IdType id) getById,
    Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? getOffsetById,
    required bool isGreedy,
    required bool autoCache,
    required bool autoInvalidateCache,
    required bool autoInvalidateCacheOnMutation,
    required this.cache,
  })  : _getById = getById,
        _getOffsetById = getOffsetById,
        _isGreedy = isGreedy,
        _autoCache = autoCache,
        _autoInvalidateCache = autoInvalidateCache,
        _autoInvalidateCacheOnMutation = autoInvalidateCacheOnMutation,
        super(
          listCache: cache,
        ) {
    fetchListFunction = (parameters) => _fetchWithAutoCache(
          fetchListWithParameters,
          parameters,
        );
  }

  void attachModel(LdModel<T, IdType, Object?, Object?> model) {
    _attachedModel = model;
  }

  Future<LdListPage<T>> _fetchWithAutoCache(
    Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    FetchPageParameters<T, IdType> parameters,
  ) async {
    if (_autoInvalidateCache &&
        (parameters.reason == LdFetchReason.refresh || parameters.reason == LdFetchReason.invalidate)) {
      if (ldPrintDebugMessages) {
        debugPrint(
          '[LdCache] clear (reason=${parameters.reason} offset=${parameters.offset}) '
          'keys=[${cache.keys.join(", ")}]',
        );
      }
      cache.clear();
    }

    if (_autoCache && parameters.reason == LdFetchReason.pagination) {
      final cachedPage = cache.readPage(parameters.cacheKey, parameters.offset);
      if (cachedPage != null) {
        final entry = cache.readEntry(parameters.cacheKey)!;
        if (ldPrintDebugMessages) {
          final ids = cachedPage.map((e) => (e as dynamic).id).toList();
          debugPrint(
            '[LdCache] HIT offset=${parameters.offset} key="${parameters.cacheKey}" '
            'total=${entry.total} ids=$ids',
          );
        }
        return LdListPage<T>(
          newItems: cachedPage,
          hasMore: parameters.offset + cachedPage.length < entry.total,
          total: entry.total,
        );
      } else {
        if (ldPrintDebugMessages) {
          final cachedOffsets = cache.readEntry(parameters.cacheKey)?.pagesByOffset.keys.toList() ?? [];
          debugPrint(
            '[LdCache] MISS offset=${parameters.offset} key="${parameters.cacheKey}" '
            'cachedOffsets=$cachedOffsets → going to API',
          );
        }
      }
    }

    if (ldPrintDebugMessages) {
      debugPrint(
        '[LdCache] API request offset=${parameters.offset} pageSize=${parameters.pageSize} '
        'reason=${parameters.reason} key="${parameters.cacheKey}"',
      );
    }
    final page = await fetchListWithParameters(parameters);
    if (ldPrintDebugMessages) {
      final ids = page.newItems.map((e) => (e as dynamic).id).toList();
      debugPrint(
        '[LdCache] API response offset=${parameters.offset} total=${page.total} ids=$ids',
      );
    }

    if (_autoCache) {
      if (ldPrintDebugMessages) {
        debugPrint(
          '[LdCache] write offset=${parameters.offset} key="${parameters.cacheKey}" '
          'total=${page.total} count=${page.newItems.length}',
        );
      }
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

  /// Whether a greedy list controller has finished loading the full dataset.
  bool get isDataComplete => _isGreedy && _greedyLoadComplete;

  /// Eagerly loads every page via [fetchListWithParameters] until [LdListPage.hasMore]
  /// is false. No-op for non-greedy list controllers or when already complete.
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
    required LdListMutationKind kind,
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

  Future<T> createFromModel<TCreate>(
    BuildContext context,
    LdModel<T, IdType, TCreate, Object?> model,
    TCreate payload, {
    int? index,
  }) async {
    final preview = model.createPreview(payload);
    _maybeInvalidateOnMutation(
      context,
      kind: LdListMutationKind.create,
      before: null,
      after: preview,
    );
    final tempIndex = scheduleItemCreation(preview, index: index);
    try {
      final newItem = await model.persistCreate(context, payload);
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

  Future<void> deleteFromModel(
    BuildContext context,
    LdModel<T, IdType, Object?, Object?> model,
    IdType id,
  ) async {
    if (!model.supportsSingleDelete) {
      return;
    }

    _maybeInvalidateOnMutation(
      context,
      kind: LdListMutationKind.delete,
    );
    _scheduleDeletionForId(id);
    try {
      await model.persistDelete(context, id);
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
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: confirmed deletion via detached path');
      }
      notifyItemUpdated(
        detachedItem.copyWith(state: LdPaginatorItemState.deleted),
      );
      return;
    }

    if (getItemIndexById(id) != null) {
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: confirmed deletion via paged path');
      }
      unawaited(_confirmPagedDeletion(context, id: id, refresh: refresh));
    } else {
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: confirm deletion called but item not found (already removed?)');
      }
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

    // Skip if a controlled refresh is already in flight (e.g. from a
    // concurrent deletion confirmation) — the in-flight refresh will settle
    // the list to a consistent state already.
    if (isControlledRefresh || busy) {
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: skipping redundant refreshList (refresh already in progress)');
      }
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
        if (ldPrintDebugMessages) {
          debugPrint('[LdListController] id=$id: rollback deletion via detached path → loaded');
        }
      }
      return;
    }

    if (getItemIndexById(id) == null) {
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: rollback deletion called but item not found (no-op)');
      }
      return;
    }

    try {
      rollbackItemDeletion(id);
      if (ldPrintDebugMessages) {
        debugPrint('[LdListController] id=$id: rollback deletion via paged path → rolledBackDeletion');
      }
    } catch (_) {
      // Item may have been removed while the delete request was in flight.
    }
  }

  /// When a controlled refresh commits its new items, any in-flight transient
  /// entries (deleting / updating / creating) are evicted from [_items] before
  /// the map is replaced. We move them into [_detachedItemsById] so that the
  /// pending confirm / rollback callbacks can still resolve via the detached
  /// path in [_confirmDeletionForId] / [_rollbackDeletionForId].
  @override
  void onTransientItemsEvictedByRefresh(Map<int, LdPaginatorItem<T>> transientItems) {
    for (final item in transientItems.values) {
      if (item.value != null) {
        // Only register in the detached map if not already tracked there.
        _detachedItemsById.putIfAbsent(item.value!.id, () => item);
        if (ldPrintDebugMessages) {
          debugPrint('[LdListController] evicted id=${item.value!.id} state=${item.state} → detached');
        }
      }
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

  Future<void> deleteBatchFromModel(
    BuildContext context,
    LdModel<T, IdType, Object?, Object?> model,
    Set<IdType> ids,
  ) async {
    if (ids.isEmpty) {
      return;
    }

    final exceptions = <dynamic>[];
    _maybeInvalidateOnMutation(
      context,
      kind: LdListMutationKind.delete,
    );
    for (final id in ids) {
      _scheduleDeletionForId(id);
    }
    try {
      await model.persistDeleteBatch(context, ids);

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

  Future<T> getById(BuildContext context, IdType id, {bool skipCache = false}) async {
    if (!skipCache) {
      final item = getItemById(id);
      if (item != null) {
        return item.value!;
      }
    }
    return await _getById(context, id);
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

  /// Positions the list around [selection] via [getOffsetById] when configured.
  ///
  /// Does not fetch individual items by id; use [loadViewingItem] from the detail
  /// page (or other UI that needs the row) so load failures can be surfaced.
  Future<void> ensureSelectionAnchored(
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
  }

  /// Loads a single viewing item by id and stores it as a detached entry when it
  /// is not already present in the paginator.
  ///
  /// Errors propagate to the caller so UI (e.g. detail [LdSubmit]) can show them.
  Future<T> loadViewingItem(BuildContext context, IdType id) async {
    final existing = getItemById(id);
    if (existing?.value != null) {
      return existing!.value!;
    }

    final item = await _getById(context, id);
    if (!context.mounted) {
      return item;
    }

    final paginatorItem = LdPaginatorItem<T>(
      value: item,
      state: LdPaginatorItemState.loaded,
    );
    _detachedItemsById[id] = paginatorItem;
    notifyItemUpdated(paginatorItem);
    return item;
  }

  /// Anchors the list for [selection]. Prefer [ensureSelectionAnchored] for new code.
  Future<void> ensureSelectionLoaded(
    BuildContext context,
    Set<IdType> selection,
  ) async {
    await ensureSelectionAnchored(context, selection);
  }

  Future<void> initWithSelection(BuildContext context, Set<IdType> selection) async {
    await ensureSelectionAnchored(
      context,
      selection,
    );
  }

  @override
  Future<void> refreshList({
    required BuildContext context,
    LdFetchReason reason = LdFetchReason.refresh,
    IdType? anchorId,
  }) async {
    // Prevent a second concurrent refresh from racing through the async anchor
    // resolution below while a first refresh has already started (or is about
    // to call super.refreshList which sets _isControlledRefresh).
    // _refreshInProgress is set synchronously (before any await) so it is
    // visible to any second call that enters on the same microtask turn.
    if (_refreshInProgress || isControlledRefresh || busy) {
      return;
    }
    _refreshInProgress = true;

    if (reason == LdFetchReason.refresh) {
      _detachedItemsById.clear();
    }

    if (reason == LdFetchReason.filter || reason == LdFetchReason.sort) {
      initialOffset = 0;
    } else if (reason == LdFetchReason.invalidate) {
      final effectiveAnchorId = anchorId ?? _resolveDefaultRefreshAnchorId();

      if (effectiveAnchorId != null && _getOffsetById != null) {
        final anchorOffset = await _getOffsetById(
          FetchOffsetParameters(
            context: context,
            id: effectiveAnchorId,
            reason: reason,
            cache: cache,
          ),
        );
        initialOffset = anchorOffset != null && anchorOffset >= 0 ? anchorOffset : 0;
      } else {
        initialOffset = 0;
      }
    } else if (reason == LdFetchReason.refresh) {
      final effectiveAnchorId = anchorId ?? _resolveDefaultRefreshAnchorId();

      if (effectiveAnchorId != null && _getOffsetById != null) {
        final anchorOffset = await _getOffsetById(
          FetchOffsetParameters(
            context: context,
            id: effectiveAnchorId,
            reason: reason,
            cache: cache,
          ),
        );
        if (anchorOffset != null) {
          initialOffset = anchorOffset;
        }
      }
    }

    if (!context.mounted) {
      _refreshInProgress = false;
      return;
    }

    try {
      await super.refreshList(
        context: context,
        reason: reason,
      );
    } finally {
      _refreshInProgress = false;
    }
  }

  @override
  void confirmItemUpdate(IdType id, T? newValue) {
    final detachedItem = _detachedItemsById[id];
    if (detachedItem != null) {
      // The item was evicted to the detached map during a concurrent refresh.
      // The base-class _items no longer has an `updating` entry for it so
      // calling super would throw.
      //
      // Two sub-cases:
      // A) The item is *still* only in the detached map — store the confirmed
      //    value there so a subsequent getItemById call sees it.
      // B) The item has *re-appeared* in _items (because the concurrent refresh
      //    fetched a fresh copy from the server) — apply the confirmed value
      //    directly to the paged entry via super so the UI stays up-to-date.
      final pagedItem = super.getItemById(id);
      if (pagedItem != null) {
        // Sub-case B: item is back in the paged list (a concurrent refresh
        // fetched a fresh copy).  Transition it through updating → loaded so
        // that the confirmed value reaches the UI.
        _detachedItemsById.remove(id);
        scheduleItemUpdate(id, newValue);
        super.confirmItemUpdate(id, newValue);
      } else {
        // Sub-case A: item is only in the detached map.
        _detachedItemsById[id] = LdPaginatorItem<T>(
          value: newValue ?? detachedItem.value,
          state: LdPaginatorItemState.loaded,
        );
      }
      return;
    }
    super.confirmItemUpdate(id, newValue);
  }

  Future<void> updateFromModel<TUpdate>(
    BuildContext context,
    LdModel<T, IdType, Object?, TUpdate> model,
    IdType id,
    TUpdate payload, {
    bool skipLayout = false,
  }) async {
    final before = getItemById(id)?.value;
    final optimistic = payload is T ? payload as T : before;
    _maybeInvalidateOnMutation(
      context,
      kind: LdListMutationKind.update,
      before: before,
      after: optimistic,
    );
    if (optimistic != null) {
      scheduleItemUpdate(id, optimistic);
    }
    final T? newItem;
    try {
      final newItemFromServer = await model.persistUpdate(context, id, payload);
      newItem = newItemFromServer ?? optimistic;
    } catch (e) {
      await rollbackItemUpdate(id);
      rethrow;
    }

    if (!context.mounted || newItem == null) {
      return;
    }

    // Persist succeeded: confirm + layout run outside the rollback try so an
    // interrupted/failed layout step never rolls back a confirmed item.
    confirmItemUpdate(id, newItem);
    if (!skipLayout) {
      await _applyPostUpdateLayout(
        context,
        id: id,
        before: before,
        after: newItem,
      );
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

    final item = getItemById(id)?.value ?? await getById(context, id);
    if (!context.mounted) {
      return;
    }
    final updated = await reorderHandler(context, item, fromIndex, toIndex);
    if (!context.mounted) {
      return;
    }
    final model = _attachedModel;
    if (model == null) {
      return;
    }
    await model.update(context, id, updated, skipLayout: true);
  }

  Future<void> updateBatchFromModel<TUpdate>(
    BuildContext context,
    LdModel<T, IdType, Object?, TUpdate> model,
    Set<TUpdate> items,
  ) async {
    final layoutChecks = <IdType, ({T? before, T after})>{};
    for (final item in items) {
      final id = _idFromUpdatePayload(item);
      final before = getItemById(id)?.value;
      final optimistic = item is T ? item : before;
      if (optimistic != null) {
        layoutChecks[id] = (before: before, after: optimistic);
        _maybeInvalidateOnMutation(
          context,
          kind: LdListMutationKind.update,
          before: before,
          after: optimistic,
        );
        scheduleItemUpdate(id, optimistic);
      }
    }
    try {
      await model.persistUpdateBatch(context, items);
    } catch (e) {
      for (final item in items) {
        await rollbackItemUpdate(_idFromUpdatePayload(item));
      }
      rethrow;
    }

    // Persist succeeded: confirming and re-laying out the list are no longer
    // rollback-worthy. Keeping them outside the try above prevents a layout
    // step that fails or is interrupted by navigation from rolling back items
    // that were already optimistically confirmed.
    for (final item in items) {
      final id = _idFromUpdatePayload(item);
      final resolved = item is T ? item : getItemById(id)?.value;
      if (resolved != null) {
        confirmItemUpdate(id, resolved);
        final existing = layoutChecks[id];
        if (existing != null) {
          layoutChecks[id] = (before: existing.before, after: resolved);
        }
      }
    }
    if (context.mounted) {
      await _applyPostUpdateLayoutBatch(context, layoutChecks);
    }
  }

  IdType _idFromUpdatePayload<TUpdate>(TUpdate item) {
    return (item as dynamic).id as IdType;
  }

  Future<void> _applyPostUpdateLayoutBatch(
    BuildContext context,
    Map<IdType, ({T? before, T after})> layoutChecks,
  ) async {
    var needsRefresh = false;
    IdType? refreshAnchorId;

    for (final entry in layoutChecks.entries) {
      if (!context.mounted) {
        return;
      }
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
        if (!context.mounted) {
          return;
        }
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
        _repositionUpdatedItem(
          id: id,
          offset: offset,
          after: after,
        );
      } else {
        await _removeUpdatedItemFromLayout(context, id);
      }
      return;
    }

    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: id,
    );
  }

  /// Moves an updated item to its resolved [offset] while keeping the sparse
  /// index map gap-free.
  ///
  /// The item's current local index mirrors its old position in the server
  /// order, and [offset] is its new position, so shifting every loaded index in
  /// between (via [reorderIndices]) keeps all loaded items consistent with the
  /// server order even when only part of the data is loaded — it is the local
  /// mirror of a single-item move.
  ///
  /// When the move stays within one contiguous run of loaded items the shift is
  /// a pure permutation and leaves no gap. When it crosses into unloaded
  /// territory the shift legitimately exposes the next (never-loaded) item at a
  /// page edge; that slot can only refill once we drop the stale requested
  /// offset bookkeeping, otherwise it would render as a stuck loader.
  void _repositionUpdatedItem({
    required IdType id,
    required int offset,
    required T after,
  }) {
    final fromIndex = getItemIndexById(id);

    if (fromIndex == null) {
      // Not part of the paged list (e.g. a detached selection entry); just
      // place it at the resolved offset.
      repositionItemById(id, newIndex: offset, value: after);
      requestScrollToItem(id);
      return;
    }

    final staysInLoadedRun = fromIndex == offset || areIndicesInSameLoadedRun(fromIndex, offset);

    reorderIndices(fromIndex, offset);

    if (!staysInLoadedRun) {
      invalidateRequestedOffsets();
    }

    requestScrollToItem(id);
  }

  /// Removes an item that no longer belongs in the list after an update (e.g.
  /// it was filtered out by the new value).
  ///
  /// Indices above the removed slot are compacted when it is safe to do so;
  /// otherwise the list is refreshed so no gap (and therefore no stuck loader)
  /// is left behind.
  Future<void> _removeUpdatedItemFromLayout(
    BuildContext context,
    IdType id,
  ) async {
    if (getItemIndexById(id) == null) {
      _detachedItemsById.remove(id);
      return;
    }

    final compacted = confirmItemDeletion(context: context, id: id);
    if (compacted || !context.mounted) {
      return;
    }

    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: _resolveDeletionAnchorId(id),
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

  static LdListController<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdListController<T, IdType>?>();
  }

  static LdListController<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdListController<T, IdType>>();
  }
}
