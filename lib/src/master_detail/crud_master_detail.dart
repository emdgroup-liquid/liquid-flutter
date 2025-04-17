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
  final T? Function() getOpenItem;

  /// [LdCrudListState] is used to hold the list of items and their states.
  late final data = LdCrudListState<T>(
    fetchListFunction: crud.fetchAll,
  );

  LdCrudMasterDetailController({
    required this.crud,
    required super.onOpenItem,
    required super.onCloseItem,
    required this.getOpenItem,
  });

  @override
  bool get isMasterAppBarLoading => data.busy;

  @override
  bool isDetailsAppBarLoading(T item) {
    return data.isItemLoading(item.id);
  }

  Future<R> executeCrudOperation<R>(
    T item,
    Future<R> Function() operation,
  ) async {
    data.handleItemStateEvent(item.id, CrudItemStateEvent.loading(null));
    try {
      final result = await operation();
      // if R is not void and result is null, throw an exception
      if (result == null && R == T) {
        throw LdException(message: "Operation failed");
      }
      data.handleItemStateEvent(
        item.id,
        CrudItemStateEvent.success(result as T),
      );
      return result;
    } catch (e) {
      data.handleItemStateEvent(
        item.id,
        CrudItemStateEvent.error(e as LdException),
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
  final List<LdMasterDetailItemAction<T>> itemActions;
  final List<LdMasterDetailListAction<T>> listActions;

  const LdCrudMasterDetail({
    super.key,
    required LdCrudMasterDetailBuilder<T> builder,
    required this.crud,
    this.itemActions = const [],
    this.listActions = const [],
    MasterDetailPresentationMode detailPresentationMode =
        MasterDetailPresentationMode.page,
    MasterDetailLayoutMode layoutMode = MasterDetailLayoutMode.auto,
    T? selectedItem,
    NavigatorState? navigator,
    LdMasterDetailOnOpenItemChange<T>? onSelectionChange,
    bool Function(SizingInformation size)? customSplitPredicate,
  }) : super(
          builder: builder,
          detailPresentationMode: detailPresentationMode,
          layoutMode: layoutMode,
          openItem: selectedItem,
          navigator: navigator,
          onOpenItemChange: onSelectionChange,
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
      onOpenItem: _onOpenItem,
      onCloseItem: _onCloseItem,
      getOpenItem: () => _openItem,
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

  @override
  List<Widget> buildMasterActions(
      BuildContext context, T? openItem, bool isSeparatePage) {
    final controller = (_controller as LdCrudMasterDetailController<T>);
    return [
      ...super.buildMasterActions(context, openItem, isSeparatePage),
      ...(widget as LdCrudMasterDetail<T>)
          .listActions
          .where((action) =>
              action.displayModes.contains(ActionDisplayModes.masterActionBar))
          .map(
            (action) => action.childBuilder(
              () async => await action.onAction(
                controller.data.isMultiSelectMode
                    ? controller.data.selectedItems.toList()
                    : controller.data.items,
                (_controller as LdCrudMasterDetailController<T>),
              ),
            ),
          )
    ];
  }

  @override
  List<Widget> buildDetailActions(
      BuildContext context, T item, bool isSeparatePage) {
    return [
      ...super.buildDetailActions(context, item, isSeparatePage),
      ...(widget as LdCrudMasterDetail<T>)
          .itemActions
          .where((action) =>
              action.displayModes.contains(ActionDisplayModes.detailActionBar))
          .map(
            (action) => action.childBuilder(
              () async => await action.onAction(
                item,
                (_controller as LdCrudMasterDetailController<T>),
              ),
            ),
          )
    ];
  }

  List<LdMasterDetailAction<T, dynamic>> get actions => [
        ...(widget as LdCrudMasterDetail<T>).itemActions,
        ...(widget as LdCrudMasterDetail<T>).listActions,
      ];
}
