import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/list/list_page.dart';
import 'package:liquid_flutter/src/monkey/data/fetch_page_parameters.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/ld_fetch_reason.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache_key.dart';
import 'package:liquid_flutter/src/monkey/data/list_controller.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';
import 'package:meta/meta.dart';

/// App-level data model for a monkey route.
///
/// Subclasses implement [fetchListWithParameters], [getById], and [persist*]
/// methods. Public [create], [update], and [delete] delegate to the mounted
/// [LdListController] internals.
abstract class LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate> {
  LdListController<T, IdType>? _listController;

  /// Optional list-controller configuration used by [LdMonkeyDataProvider].
  int get pageSize => 10;

  bool get isGreedy => false;

  bool get autoCache => true;

  bool get autoInvalidateCache => true;

  bool get autoInvalidateCacheOnMutation => true;

  /// Owned cache instance. Subclasses that wish to supply their own
  /// [LdListCache] should override [cache] and return it there; the default
  /// implementation returns a lazily-created private instance.
  late final LdListCache<T, IdType> _ownedCache = LdListCache<T, IdType>();

  LdListCache<T, IdType> get cache => _ownedCache;

  Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? get getOffsetById => null;

  Future<LdListPage<T>> fetchListWithParameters(
    FetchPageParameters<T, IdType> parameters,
  );

  /// Fetches a page from [fetchListWithParameters], applying the model's
  /// [autoCache] and [autoInvalidateCache] policies.
  ///
  /// This is a non-overridable wrapper used by [LdListController] so that
  /// cache read/write logic lives in the model rather than the controller.
  @nonVirtual
  Future<LdListPage<T>> fetchListWithParametersCached(
    FetchPageParameters<T, IdType> parameters,
  ) async {
    if (autoInvalidateCache &&
        (parameters.reason == LdFetchReason.refresh ||
            parameters.reason == LdFetchReason.invalidate ||
            parameters.reason == LdFetchReason.filter ||
            parameters.reason == LdFetchReason.sort)) {
      cache.clear();
    }
    if (autoCache && parameters.reason == LdFetchReason.pagination) {
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
    if (autoCache) {
      cache.writePage(
        parameters.cacheKey,
        offset: parameters.offset,
        items: page.newItems,
        total: page.total,
      );
    }
    return page;
  }

  /// Invalidates the cache after a mutation, if [autoInvalidateCacheOnMutation]
  /// is enabled.
  ///
  /// Should be called after a successful persist operation so that only
  /// confirmed server values drive cache invalidation.
  void invalidateCacheOnMutation(
    BuildContext context, {
    required LdListMutationKind kind,
    T? before,
    T? after,
  }) {
    if (!autoInvalidateCacheOnMutation) return;
    cache.invalidateOnMutation(
      context: context,
      kind: kind,
      before: before,
      after: after,
    );
  }

  Future<T> getById(BuildContext context, IdType id);

  Future<T> persistCreate(BuildContext context, TCreate payload);

  Future<T?> persistUpdate(BuildContext context, IdType id, TUpdate payload);

  Future<void> persistDelete(BuildContext context, IdType id);

  Future<void> persistDeleteBatch(BuildContext context, Set<IdType> ids);

  /// Persists a batch update. [items] is a map from item id to update payload.
  Future<void> persistUpdateBatch(BuildContext context, Map<IdType, TUpdate> items);

  /// Whether this model supports drag-to-reorder.
  ///
  /// The monkey framework uses this together with [LdSortOption.supportsReorder]
  /// to decide whether drag handles are shown. Override and return `true` in
  /// subclasses that implement [persistReorder].
  bool get supportsReorder => false;

  /// Persists a drag-to-reorder operation and returns the updated item.
  ///
  /// [activeSortOption] is the sort option that is currently active and has
  /// [LdSortOption.supportsReorder] set to `true`. When a list defines several
  /// reorderable sort options the caller needs this to know which ordering
  /// column to update on the backend.
  ///
  /// Override this method in model subclasses that support reordering. The
  /// default implementation throws [UnimplementedError]; it is only reached
  /// when [supportsReorder] is `true` but the subclass has not provided an
  /// implementation.
  Future<T> persistReorder(
    BuildContext context,
    T item,
    int fromIndex,
    int toIndex,
    LdSortOption<T, IdType> activeSortOption,
  ) {
    throw UnimplementedError(
      '$runtimeType.persistReorder is not implemented. '
      'Override persistReorder and set supportsReorder to true.',
    );
  }

  /// Maps a create payload to an optimistic list-row preview when [TCreate] != [T].
  T? createPreview(TCreate payload) => null;

  /// Whether [persistDelete] performs a real delete for this model.
  bool get supportsSingleDelete => true;

  void attachListController(LdListController<T, IdType> listController) {
    _listController = listController;
    listController.attachModel(this);
  }

  Future<T> create(
    BuildContext context,
    TCreate payload, {
    int? index,
  }) =>
      _listController!.createFromModel(
        context,
        this,
        payload,
        index: index,
      );

  Future<T?> update(
    BuildContext context,
    IdType id,
    TUpdate payload, {
    bool skipLayout = false,
  }) =>
      _listController!.updateFromModel(
        context,
        this,
        id,
        payload,
        skipLayout: skipLayout,
      );

  Future<void> delete({
    required BuildContext context,
    required IdType id,
  }) =>
      _listController!.deleteFromModel(
        context,
        this,
        id,
      );

  Future<void> deleteBatch({
    required BuildContext context,
    required Set<IdType> ids,
  }) =>
      _listController!.deleteBatchFromModel(
        context,
        this,
        ids,
      );

  /// Updates a batch of items. [items] is a map from item id to update payload.
  Future<void> updateBatch(
    BuildContext context,
    Map<IdType, TUpdate> items,
  ) =>
      _listController!.updateBatchFromModel(
        context,
        this,
        items,
      );
}
