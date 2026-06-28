import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/list/list_page.dart';
import 'package:liquid_flutter/src/monkey/data/fetch_page_parameters.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/list_controller.dart';
import 'package:liquid_flutter/src/monkey/data/ld_list_cache.dart';

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

  LdListCache<T, IdType>? get cache => null;

  Future<int?> Function(FetchOffsetParameters<T, IdType> parameters)? get getOffsetById => null;

  Future<LdListPage<T>> fetchListWithParameters(
    FetchPageParameters<T, IdType> parameters,
  );

  Future<T> getById(BuildContext context, IdType id);

  Future<T> persistCreate(BuildContext context, TCreate payload);

  Future<T?> persistUpdate(BuildContext context, IdType id, TUpdate payload);

  Future<void> persistDelete(BuildContext context, IdType id);

  Future<void> persistDeleteBatch(BuildContext context, Set<IdType> ids);

  Future<void> persistUpdateBatch(BuildContext context, Set<TUpdate> items);

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

  Future<void> update(
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

  Future<void> updateBatch(
    BuildContext context,
    Set<TUpdate> items,
  ) =>
      _listController!.updateBatchFromModel(
        context,
        this,
        items,
      );
}
