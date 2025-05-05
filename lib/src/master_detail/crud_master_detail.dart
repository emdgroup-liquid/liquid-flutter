part of 'master_detail.dart';

typedef LdMasterDetailCrudItemCallback<T> = void Function(T item);

/// Defines a repository that can perform CRUD operations on a given type [T]
/// and fetch a list of items of type [T].
abstract class LdCrudOperations<T> {
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

/// [LdCrudMasterDetail] extends the [LdMasterDetail] widget to provide CRUD
/// functionality for a list of items of type [T].
///
/// It handles various CRUD operations like create, update, delete, and fetch
/// and also performs the usual UI operations like selecting and deselecting
/// items or updating the UI based on the state and result of a CRUD operation.
class LdCrudMasterDetail<T extends CrudItemMixin<T>> extends LdMasterDetail<T> {
  final LdCrudOperations<T> crud;
  final List<LdMasterDetailItemAction<T>> itemActions;
  final List<LdMasterDetailListAction<T>> listActions;
  final Widget Function(
    BuildContext context,
    dynamic error,
    LdMasterDetailController<T> controller,
  )? buildDetailError;

  LdCrudMasterDetail({
    super.key,
    super.buildDetailTitle,
    super.buildMasterTitle,
    required Widget Function(
      BuildContext context,
      T item,
      bool isSeparatePage,
      LdMasterDetailController<T> controller,
    ) buildDetail,
    required super.buildMaster,
    super.buildMasterActions,
    super.buildDetailActions,
    super.detailPresentationMode = MasterDetailPresentationMode.page,
    super.layoutMode = MasterDetailLayoutMode.auto,
    super.openItem,
    super.navigator,
    super.onOpenItemChange,
    super.customSplitPredicate,
    super.masterDetailFlex,
    required this.crud,
    this.itemActions = const [],
    this.listActions = const [],
    this.buildDetailError,
  }) : super(
          buildDetail: (context, item, isSeparatePage, controller) =>
              _buildDetailWithErrorHandling(
            context,
            item,
            isSeparatePage,
            controller,
            buildDetail,
            buildDetailError,
          ),
        );

  static Widget _buildDetailWithErrorHandling<T extends CrudItemMixin<T>>(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
    Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)
        buildDetail,
    Widget Function(BuildContext, dynamic, LdMasterDetailController<T>)?
        buildDetailError,
  ) {
    final data = context.read<LdCrudListState<T>>();
    final error = data.getItemError(item);
    if (error != null) {
      return buildDetailError?.call(context, error, controller) ??
          Center(child: LdExceptionView.fromDynamic(error, context));
    }
    return buildDetail(context, item, isSeparatePage, controller);
  }

  @override
  State<LdMasterDetail<T>> createState() => _LdCrudMasterDetailState<T>();
}

class _LdCrudMasterDetailState<T extends CrudItemMixin<T>>
    extends _LdMasterDetailState<T> {
  late final _crud = (widget as LdCrudMasterDetail<T>).crud;
  late final _data = LdCrudListState<T>(
    fetchListFunction: _crud.fetchAll,
  );

  @override
  bool get _isMasterAppBarLoading => _data.busy;

  @override
  bool get _isDetailsAppBarLoading => _data.isItemLoading(_openItem);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdCrudListState<T>>.value(
      value: _data,
      child: ListenableBuilder(
        listenable: _data,
        builder: (context, child) {
          return super.build(context);
        },
      ),
    );
  }

  @override
  List<Widget> buildMasterActions(
      BuildContext context, T? openItem, bool isSeparatePage) {
    final actions = (widget as LdCrudMasterDetail<T>).listActions;
    final builder = _data.isMultiSelectMode
        ? (action) => action.masterActionMultiSelectBarIconBuilder
        : (action) => action.masterActionBarIconBuilder;

    return [
      ...super.buildMasterActions(context, openItem, isSeparatePage),
      ...actions.where((action) => builder(action) != null).map(
            (action) => builder(action)!(
              () async => await action.onAction(
                _data.isMultiSelectMode
                    ? _data.selectedItems.toList()
                    : _data.items,
                context: context,
                controller: _controller,
                listState: _data,
                crud: _crud,
              ),
            ),
          )
    ];
  }

  @override
  List<Widget> buildDetailActions(
      BuildContext context, T item, bool isSeparatePage) {
    final actions = (widget as LdCrudMasterDetail<T>).itemActions;
    return [
      ...super.buildDetailActions(context, item, isSeparatePage),
      ...actions
          .where((action) => action.detailActionBarIconBuilder != null)
          .map(
            (action) => action.detailActionBarIconBuilder!(
              () async => await action.onAction(
                item,
                context: context,
                controller: _controller,
                listState: _data,
                crud: _crud,
              ),
            ),
          )
    ];
  }

  List<LdMasterDetailAction<T, dynamic>> get actions => [
        ...(widget as LdCrudMasterDetail<T>).itemActions,
        ...(widget as LdCrudMasterDetail<T>).listActions,
      ];

  @override
  Widget _buildDetailPage(T item) {
    return ListenableProvider<LdCrudListState<T>>.value(
      value: _data,
      child: ListenableBuilder(
        listenable: _data,
        builder: (context, child) {
          return super._buildDetailPage(item);
        },
      ),
    );
  }
}
