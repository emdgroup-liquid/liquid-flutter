import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/list/list_page.dart';
import 'package:liquid_flutter/src/monkey/data/fetch_page_parameters.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache_key.dart';
import 'package:liquid_flutter/src/monkey/data/ld_model.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';

/// Callback-based [LdModel] for apps that wire data operations via closures.
class LdCallbackModel<T extends Identifiable<IdType>, IdType> extends LdModel<T, IdType, T?, T> {
  LdCallbackModel({
    required Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters) fetchListWithParameters,
    required Future<T> Function(BuildContext context, IdType id) getById,
    this.getOffsetByIdFn,
    this.deleteItem,
    this.updateItem,
    this.createItem,
    this.deleteBatchFn,
    this.updateBatchFn,
    this.pageSize = 10,
    this.isGreedy = false,
    this.autoCache = true,
    this.autoInvalidateCache = true,
    this.autoInvalidateCacheOnMutation = true,
    LdListCache<T, IdType>? cache,
    List<T>? initialItems,
  })  : fetchListFn = fetchListWithParameters,
        _getById = getById,
        _initialItems = initialItems,
        _providedCache = cache;

  @override
  final int pageSize;

  @override
  final bool isGreedy;

  @override
  final bool autoCache;

  @override
  final bool autoInvalidateCache;

  @override
  final bool autoInvalidateCacheOnMutation;

  /// An optional caller-supplied cache. When non-null, overrides the
  /// lazily-created [LdModel._ownedCache].
  final LdListCache<T, IdType>? _providedCache;

  @override
  LdListCache<T, IdType> get cache => _providedCache ?? super.cache;

  final Future<LdListPage<T>> Function(FetchPageParameters<T, IdType> parameters)
  fetchListFn;

  final Future<T> Function(BuildContext context, IdType id) _getById;

  final Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? getOffsetByIdFn;

  @override
  Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? get getOffsetById => getOffsetByIdFn;

  final Future<void> Function(BuildContext context, IdType id)? deleteItem;

  final Future<T?> Function(BuildContext context, IdType id, T newItem)? updateItem;

  final Future<T> Function(BuildContext context, T? newItem)? createItem;

  final Future<void> Function(BuildContext context, Set<IdType> ids)? deleteBatchFn;

  /// Batch-update callback. Receives a map from item id to updated item.
  final Future<void> Function(BuildContext context, Map<IdType, T> items)? updateBatchFn;

  final List<T>? _initialItems;

  List<T>? get initialItems => _initialItems;

  @override
  bool get supportsSingleDelete => deleteItem != null;

  @override
  T? createPreview(T? payload) => payload;

  @override
  Future<LdListPage<T>> fetchListWithParameters(
    FetchPageParameters<T, IdType> parameters,
  ) =>
      fetchListFn(parameters);

  @override
  Future<T> getById(BuildContext context, IdType id) => _getById(context, id);

  @override
  Future<T> persistCreate(BuildContext context, T? payload) {
    assert(
      createItem != null,
      'Cannot create item. createItem was not configured for this model',
    );
    return createItem!(context, payload);
  }

  @override
  Future<T?> persistUpdate(BuildContext context, IdType id, T payload) {
    if (updateItem == null) {
      return Future.value(null);
    }
    return updateItem!(context, id, payload);
  }

  @override
  Future<void> persistDelete(BuildContext context, IdType id) async {
    if (deleteItem == null) {
      return;
    }
    await deleteItem!(context, id);
  }

  @override
  Future<void> persistDeleteBatch(BuildContext context, Set<IdType> ids) async {
    if (deleteBatchFn != null) {
      await deleteBatchFn!(context, ids);
      return;
    }

    assert(
      deleteItem != null,
      'Cannot delete items. deleteItem was not configured for this model',
    );

    // Per-item fallback: track partial success so the controller can confirm
    // the succeeded deletions and only roll back the ones that actually failed.
    final succeeded = <IdType>{};
    Object? firstError;
    for (final id in ids) {
      try {
        await deleteItem!(context, id);
        succeeded.add(id);
      } catch (e) {
        firstError = e;
        // Continue attempting remaining items so we maximise partial success.
      }
    }

    if (firstError != null) {
      throw LdPartialBatchDeleteException<IdType>(
        succeededIds: succeeded,
        cause: firstError,
      );
    }
  }

  /// Persists a batch update. [items] is a map from item id to updated item.
  ///
  /// Delegates to [updateBatchFn] when provided; otherwise falls back to
  /// calling [updateItem] once per entry.
  @override
  Future<void> persistUpdateBatch(BuildContext context, Map<IdType, T> items) async {
    if (updateBatchFn != null) {
      await updateBatchFn!(context, items);
      return;
    }

    assert(
      updateItem != null,
      'Cannot update items. updateItem was not configured for this model',
    );
    for (final entry in items.entries) {
      await updateItem!(context, entry.key, entry.value);
    }
  }

  /// Creates a greedy callback model that eagerly loads the full dataset by
  /// calling [fetchListWithParameters] for every page until [LdListPage.hasMore]
  /// is false.
  static LdCallbackModel<L, IdType> greedy<L extends Identifiable<IdType>, IdType>({
    required Future<LdListPage<L>> Function(FetchPageParameters<L, IdType> parameters) fetchListWithParameters,
    required Future<L> Function(BuildContext context, IdType id) getById,
    int pageSize = 50,
    bool autoCache = true,
    bool autoInvalidateCache = true,
    bool autoInvalidateCacheOnMutation = true,
    Future<int?> Function(FetchOffsetParameters<L, IdType> parameters)? getOffsetById,
    Future<void> Function(BuildContext context, IdType id)? deleteItem,
    Future<L?> Function(BuildContext context, IdType id, L newItem)? updateItem,
    Future<L> Function(BuildContext context, L? newItem)? createItem,
    Future<void> Function(BuildContext context, Set<IdType> ids)? deleteBatch,
    Future<void> Function(BuildContext context, Map<IdType, L> items)? updateBatch,
    LdListCache<L, IdType>? cache,
    List<L>? initialItems,
  }) {
    return LdCallbackModel<L, IdType>(
      fetchListWithParameters: fetchListWithParameters,
      getById: getById,
      pageSize: pageSize,
      autoCache: autoCache,
      autoInvalidateCache: autoInvalidateCache,
      autoInvalidateCacheOnMutation: autoInvalidateCacheOnMutation,
      getOffsetByIdFn: getOffsetById,
      deleteItem: deleteItem,
      updateItem: updateItem,
      createItem: createItem,
      deleteBatchFn: deleteBatch,
      updateBatchFn: updateBatch,
      cache: cache,
      initialItems: initialItems,
      isGreedy: true,
    );
  }

  /// Creates a greedy callback model backed by an in-memory [list].
  static LdCallbackModel<L, IdType> fromList<L extends Identifiable<IdType>, IdType>({
    required List<L> list,
    bool Function(L item, Set<LdFilterOption<L, IdType>>? activeFilters)? filterFunction,
    int Function(L a, L b, List<LdSortOption<L, IdType>>? activeSortOptions)? sortFunction,
    int pageSize = 50,
  }) {
    return greedy<L, IdType>(
      pageSize: pageSize,
      getById: (context, id) async => list.firstWhere((item) => item.id == id),
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
}
