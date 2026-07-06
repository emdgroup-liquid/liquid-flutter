import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdListController<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? _getOffsetById;

  final Future<T> Function(BuildContext context, IdType id) _getById;

  bool _greedyLoadComplete = false;

  LdModel<T, IdType, Object?, Object?> _attachedModel;

  UnmodifiableListView<LdPaginatorItem<T>> get deletedItems => UnmodifiableListView(
        _detachedItemsById.values.where((item) => item.state == LdPaginatorItemState.deleted).toList(),
      );

  UnmodifiableMapView<IdType, LdPaginatorItem<T>> get detachedItemsById => UnmodifiableMapView(_detachedItemsById);

  IdType? _lastSelectionAnchorId;

  /// This map is used to store items that were fetched, but can not be sorted
  /// into the paginator since we dont know the actual offset.
  /// We can not simply append them to the list, since that might break the pagination.
  final Map<IdType, LdPaginatorItem<T>> _detachedItemsById = {};

  /// Per-list-controller cache — delegates to the model's owned cache.
  final LdListCache<T, IdType> cache;

  /// Synchronous guard for the [refreshList] override: set to `true`
  /// immediately (before any `await`) so that a second concurrent call that
  /// enters during the async anchor-offset resolution is dropped instead of
  /// racing to commit its own refresh results on top of the first.
  bool _refreshInProgress = false;

  LdListController(
    LdModel<T, IdType, Object?, Object?> model, {
    List<T>? initialItems,
  })  : _attachedModel = model,
        cache = model.cache,
        _getById = model.getById,
        _getOffsetById = model.getOffsetById,
        super(
          pageSize: model.pageSize,
          initialItems: initialItems ?? (model is LdCallbackModel<T, IdType> ? model.initialItems : null),
          listCache: model.cache,
          fetchListFunction: model.fetchListWithParametersCached,
        ) {
    model.attachListController(this);
  }

  /// Named constructor alias for [LdListController.new].
  LdListController.fromModel(
    LdModel<T, IdType, Object?, Object?> model, {
    List<T>? initialItems,
  })  : _attachedModel = model,
        cache = model.cache,
        _getById = model.getById,
        _getOffsetById = model.getOffsetById,
        super(
          pageSize: model.pageSize,
          initialItems: initialItems ?? (model is LdCallbackModel<T, IdType> ? model.initialItems : null),
          listCache: model.cache,
          fetchListFunction: model.fetchListWithParametersCached,
        ) {
    model.attachListController(this);
  }

  /// Whether this list controller's model is greedy.
  bool get isGreedy => _attachedModel.isGreedy;

  /// Whether a greedy list controller has finished loading the full dataset.
  bool get isDataComplete => _attachedModel.isGreedy && _greedyLoadComplete;

  /// The [LdModel] wired to this list controller via [fromModel].
  LdModel<T, IdType, Object?, Object?> get model => _attachedModel;

  void attachModel(LdModel<T, IdType, Object?, Object?> model) {
    _attachedModel = model;
  }

  @override
  bool confirmItemDeletion({
    required BuildContext context,
    bool refresh = false,
    required IdType id,
  }) {
    // Deleted items are kept in the detached items map, so we can safely show removed states in the UI.

    final item = getItemById(id);

    if (item == null) {
      // Item is not known to this controller (not paged, not detached).
      // The server-side delete already succeeded, so there is nothing to
      // clean up locally — just report as compacted and move on.
      return true;
    }

    // If the item is detached already we return true anyways, since there was no unsafe list order
    // created by this deletion
    bool compacted = true;

    if (!_isDetached(id)) {
      final compacted = super.confirmItemDeletion(
        context: context,
        refresh: false,
        id: id,
      );

      _maybeRefreshPostDeletion(context, id: id, refresh: refresh, compacted: compacted);
    }

    _detachedItemsById[id] = item.copyWith(state: LdPaginatorItemState.deleted);
    return compacted;
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

  Future<T> createFromModel<TCreate>(
    BuildContext context,
    LdModel<T, IdType, TCreate, Object?> model,
    TCreate payload, {
    int? index,
  }) async {
    final preview = model.createPreview(payload);
    final tempIndex = scheduleItemCreation(preview, index: index);
    try {
      final newItem = await model.persistCreate(context, payload);
      if (!context.mounted) {
        return newItem;
      }
      _attachedModel.invalidateCacheOnMutation(context, kind: LdListMutationKind.create, before: null, after: newItem);

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
    } catch (e, _) {
      rollbackItemCreation(tempIndex);
      rethrow;
    }
  }

  Future<void> deleteBatchFromModel(
    BuildContext context,
    LdModel<T, IdType, Object?, Object?> model,
    Set<IdType> ids,
  ) async {
    if (ids.isEmpty) {
      return;
    }

    for (final id in ids) {
      _scheduleDeletionForId(id);
    }
    try {
      await model.persistDeleteBatch(context, ids);
      if (context.mounted) {
        _attachedModel.invalidateCacheOnMutation(context, kind: LdListMutationKind.delete);
      }
      for (final id in ids) {
        if (!context.mounted) {
          break;
        }
        confirmItemDeletion(context: context, id: id, refresh: false);
      }
    } on LdPartialBatchDeleteException<IdType> catch (e) {
      // Some per-item deletes succeeded; confirm those and roll back the rest.
      final failedIds = ids.difference(e.succeededIds);

      if (e.succeededIds.isNotEmpty && context.mounted) {
        _attachedModel.invalidateCacheOnMutation(context, kind: LdListMutationKind.delete);
        for (final id in e.succeededIds) {
          if (!context.mounted) break;
          confirmItemDeletion(context: context, id: id, refresh: false);
        }
      }

      for (final id in failedIds) {
        _rollbackDeletionForId(id);
      }

      if (context.mounted) refreshList(context: context);
      // Re-throw the underlying cause so the caller sees the original error.
      throw e.cause;
    } catch (e) {
      for (final id in ids) {
        _rollbackDeletionForId(id);
      }
      if (context.mounted) refreshList(context: context);
      rethrow;
    }
  }

  Future<void> deleteFromModel(
    BuildContext context,
    LdModel<T, IdType, Object?, Object?> model,
    IdType id,
  ) async {
    if (!model.supportsSingleDelete) {
      return;
    }

    _scheduleDeletionForId(id);
    try {
      await model.persistDelete(context, id);
      if (!context.mounted) {
        return;
      }
      _attachedModel.invalidateCacheOnMutation(context, kind: LdListMutationKind.delete);
      confirmItemDeletion(context: context, id: id, refresh: false);
    } catch (e) {
      _rollbackDeletionForId(id);
      rethrow;
    }
  }

  /// Eagerly loads every page via [fetchListWithParameters] until [LdListPage.hasMore]
  /// is false. No-op for non-greedy list controllers or when already complete.
  Future<void> ensureGreedyLoaded(BuildContext context) async {
    if (!model.isGreedy || _greedyLoadComplete) {
      return;
    }

    await eagerFetchAllPages(context);

    if (context.mounted) {
      _greedyLoadComplete = true;
    }
  }

  /// Anchors the list view to the first selected item by resolving its server
  /// offset via [getOffsetById].
  ///
  /// No-op when [selectedIds] is empty or [getOffsetById] is not configured.
  Future<void> initWithSelection(BuildContext context, Set<IdType> selectedIds) async {
    if (selectedIds.isEmpty || _getOffsetById == null) {
      return;
    }

    final anchorId = selectedIds.first;
    final offset = await _getOffsetById(
      FetchOffsetParameters(
        context: context,
        id: anchorId,
        reason: LdFetchReason.invalidate,
        cache: cache,
      ),
    );

    if (offset != null && offset >= 0) {
      initialOffset = offset;
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
      }
    }
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
    await model.update(context, id, updated, skipLayout: true);
  }

  /// Updates a batch of items. [items] maps each item's id to the update payload.
  ///
  /// Optimistically applies each update before persisting. On persist failure,
  /// all updates are rolled back. Cache invalidation happens after a successful
  /// persist using confirmed server values.
  Future<void> updateBatchFromModel<TUpdate>(
    BuildContext context,
    LdModel<T, IdType, Object?, TUpdate> model,
    Map<IdType, TUpdate> items,
  ) async {
    final beforeMap = {for (final id in items.keys) id: getItemById(id)?.value};
    final layoutChecks = <IdType, ({T? before, T after})>{};

    for (final entry in items.entries) {
      final id = entry.key;
      final before = beforeMap[id];
      final optimistic = entry.value is T ? entry.value as T : before;
      if (optimistic != null) {
        layoutChecks[id] = (before: before, after: optimistic);
        scheduleItemUpdate(id, optimistic);
      }
    }
    try {
      await model.persistUpdateBatch(context, items);
    } catch (e) {
      for (final id in items.keys) {
        await rollbackItemUpdate(id);
      }
      rethrow;
    }

    // Persist succeeded: confirming and re-laying out the list are no longer
    // rollback-worthy. Keeping them outside the try above prevents a layout
    // step that fails or is interrupted by navigation from rolling back items
    // that were already optimistically confirmed.
    for (final entry in items.entries) {
      final id = entry.key;
      final resolved = entry.value is T ? entry.value as T : getItemById(id)?.value;
      if (resolved != null) {
        confirmItemUpdate(id, resolved);
        final existing = layoutChecks[id];
        if (existing != null) {
          layoutChecks[id] = (before: existing.before, after: resolved);
        }
      }
    }

    // Invalidate cache per item using confirmed server values.
    if (context.mounted) {
      for (final entry in items.entries) {
        final id = entry.key;
        final confirmed = layoutChecks[id]?.after;
        if (confirmed != null) {
          _attachedModel.invalidateCacheOnMutation(
            context,
            kind: LdListMutationKind.update,
            before: beforeMap[id],
            after: confirmed,
          );
        }
      }
    }

    if (context.mounted) {
      await _applyPostUpdateLayoutBatch(context, layoutChecks);
    }
  }

  Future<T?> updateFromModel<TUpdate>(
    BuildContext context,
    LdModel<T, IdType, Object?, TUpdate> model,
    IdType id,
    TUpdate payload, {
    bool skipLayout = false,
  }) async {
    final before = getItemById(id)?.value;
    final optimistic = payload is T ? payload as T : before;
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
      return null;
    }

    // Persist succeeded: confirm + layout run outside the rollback try so an
    // interrupted/failed layout step never rolls back a confirmed item.
    confirmItemUpdate(id, newItem);
    _attachedModel.invalidateCacheOnMutation(
      context,
      kind: LdListMutationKind.update,
      before: before,
      after: newItem,
    );
    if (!skipLayout) {
      await _applyPostUpdateLayout(
        context,
        id: id,
        before: before,
        after: newItem,
      );
    }
    return newItem;
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

  Future<void> _maybeRefreshPostDeletion(
    BuildContext context, {
    required IdType id,
    required bool refresh,
    bool compacted = false,
  }) async {
    if (compacted || refresh || !context.mounted) {
      return;
    }

    if (model.isGreedy && isDataComplete) {
      await eagerFetchAllPages(context);
      return;
    }

    // Skip if a controlled refresh is already in flight (e.g. from a
    // concurrent deletion confirmation) — the in-flight refresh will settle
    // the list to a consistent state already.
    if (isControlledRefresh || busy) {
      return;
    }

    await refreshList(
      context: context,
      reason: LdFetchReason.invalidate,
      anchorId: _resolveDeletionAnchorId(id),
    );
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

  bool _isDetached(IdType id) {
    return super.getItemById(id) == null && _detachedItemsById.containsKey(id);
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

  IdType? _resolveDeletionAnchorId(IdType deletedId) {
    if (_lastSelectionAnchorId != null && _lastSelectionAnchorId != deletedId) {
      return _lastSelectionAnchorId;
    }

    return itemsMap.entries
        .where((entry) => entry.value.value != null && entry.value.value!.id != deletedId)
        .map((entry) => entry.value.value!.id)
        .firstOrNull;
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

  static LdListController<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdListController<T, IdType>?>();
  }

  static LdListController<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdListController<T, IdType>>();
  }
}
