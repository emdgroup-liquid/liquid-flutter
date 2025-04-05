part of 'master_detail.dart';

typedef LdMasterDetailCrudItemCallback<T> = void Function(T item);

/// Defines a repository that can perform CRUD operations on a given type [T]
/// and fetch a list of items of type [T].
abstract class CrudOperations<T> {
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(T item);
  Future<void> batchDelete(Iterable<T> items) async {
    for (final item in items) {
      await this.delete(item);
    }
  }

  FetchListFunction<T> get fetchAll;
}

/// A mixin to add CRUD item properties to a class.
/// A crud item must have an [id] property to uniquely identify the item.
mixin CrudItemMixin<T> {
  dynamic get id;

  /// By default, an item is considered new if it does not have an [id].
  bool get isNew => id == null;
}

/// [LdCrudMasterDetailController] automatically manages the state of a list of
/// items of type [T] and their CRUD operations. It performs UI operations like
/// selecting and deselecting items, updating the UI based on the state and
/// result of a CRUD operation, and handling the loading state of the app bar.
///
/// It also handles callbacks for CRUD operations like [create], [update], and
/// [delete] when they succeed or fail, and provides a [save] method to create
/// or update an item based on its state.
class LdCrudMasterDetailController<T extends CrudItemMixin<T>>
    extends LdMasterDetailController<T> {
  /// The [CrudOperations] instance to perform CRUD operations.
  final CrudOperations<T> crud;

  /// A function to get the currently selected item from the state of the
  /// [LdMasterDetail] widget.
  final T? Function() getSelectedItem;

  /// [LdCrudPaginator] is used to hold the list of items and their states.
  late final data = LdCrudPaginator<T>(
    fetchListFunction: crud.fetchAll,
  );

  LdCrudMasterDetailController({
    required this.crud,
    required super.onSelect,
    required super.onDeselect,
    required this.getSelectedItem,
  });

  @override
  bool get isMasterAppBarLoading => data.busy;

  @override
  bool isDetailsAppBarLoading(T item) {
    return data.getItemState(item.id)?.type == CrudLoadingStateType.loading;
  }

  Future<T> create(
    T item, {
    LdMasterDetailCrudItemCallback<T>? onItemCreated,
  }) async {
    final result =
        await _executeCrudOperation<T>(item, () => crud.create(item));
    onItemCreated?.call(result);
    return result;
  }

  Future<void> delete(
    T item, {
    LdMasterDetailCrudItemCallback<T>? onItemDeleted,
  }) async {
    await _executeCrudOperation<void>(item, () => crud.delete(item));
    onItemDeleted?.call(item);
    if (getSelectedItem()?.id == item.id) {
      onDeselect();
    }
  }

  Future<void> batchDelete(
    Iterable<T> items, {
    LdMasterDetailCrudItemCallback<T>? onItemDeleted,
    VoidCallback? onItemsDeleted,
  }) async {
    // set list busy in general
    data.updateItemState(null, CrudItemState.loading());
    try {
      await crud.batchDelete(items);
      for (final item in items) {
        // remove all items from list
        data.updateItemState(item.id, CrudItemState.deleted());
        onItemDeleted?.call(item);
      }
      onItemsDeleted?.call();
      data.toggleMultiSelectMode(forceValue: false);
    } catch (e) {
      // set list error
      data.updateItemState(null, CrudItemState.error(e as LdException));
    }
  }

  Future<T> update(
    T item, {
    LdMasterDetailCrudItemCallback<T>? onItemUpdated,
  }) async {
    final result =
        await _executeCrudOperation<T>(item, () => crud.update(item));
    onItemUpdated?.call(item);
    return result;
  }

  FetchListFunction<T> get fetchAll => data.fetchListFunction;

  Future<void> save(
    T item, {
    LdMasterDetailCrudItemCallback<T>? onItemSaved,
  }) async {
    final T itemResult = item.isNew
        ? await create(item, onItemCreated: onItemSaved)
        : await update(item, onItemUpdated: onItemSaved);
    if (item.isNew || itemResult.id == getSelectedItem()?.id) {
      onSelect(itemResult);
    }
  }

  Future<R> _executeCrudOperation<R>(
    T item,
    Future<R> Function() operation,
  ) async {
    data.updateItemState(item.id, CrudItemState.loading());
    try {
      final result = await operation();
      // if R is not void and result is null, throw an exception
      if (result == null && R == T) {
        throw LdException(message: "Operation failed");
      }
      data.updateItemState(
        item.id,
        CrudItemState.success(result as T?),
      );
      return result;
    } catch (e) {
      data.updateItemState(
        item.id,
        CrudItemState.error(e as LdException),
      );
      return Future.error(e);
    }
  }

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }
}

/// [LdCrudMasterDetail] extends the [LdMasterDetail] widget to provide CRUD
/// functionality for a list of items of type [T].
///
/// It handles various CRUD operations like create, update, delete, and fetch
/// and also performs the usual UI operations like selecting and deselecting
/// items or updating the UI based on the state and result of a CRUD operation.
class LdCrudMasterDetail<T extends CrudItemMixin<T>> extends LdMasterDetail<T> {
  final CrudOperations<T> crud;

  const LdCrudMasterDetail({
    super.key,
    required LdCrudMasterDetailBuilder<T> builder,
    required this.crud,
    MasterDetailPresentationMode detailPresentationMode =
        MasterDetailPresentationMode.page,
    MasterDetailLayoutMode layoutMode = MasterDetailLayoutMode.auto,
    T? selectedItem,
    NavigatorState? navigator,
    LdMasterDetailOnSelectCallback<T>? onSelectionChange,
    bool Function(SizingInformation size)? customSplitPredicate,
  }) : super(
          builder: builder,
          detailPresentationMode: detailPresentationMode,
          layoutMode: layoutMode,
          selectedItem: selectedItem,
          navigator: navigator,
          onSelectionChange: onSelectionChange,
          customSplitPredicate: customSplitPredicate,
        );

  @override
  State<LdMasterDetail<T>> createState() => _LdCrudMasterDetailState<T>();
}

class _LdCrudMasterDetailState<T extends CrudItemMixin<T>>
    extends _LdMasterDetailState<T> {
  @override
  void _initController() {
    _controller = LdCrudMasterDetailController(
      crud: (widget as LdCrudMasterDetail<T>).crud,
      onSelect: _onSelect,
      onDeselect: _onDeselect,
      getSelectedItem: () => _selectedItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: (_controller as LdCrudMasterDetailController<T>).data,
      builder: (context, child) {
        return super.build(context);
      },
    );
  }
}
