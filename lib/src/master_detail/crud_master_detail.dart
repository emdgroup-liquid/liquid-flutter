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
    final displayMode = _data.isMultiSelectMode
        ? ActionDisplayModes.masterActionBarMultiSelect
        : ActionDisplayModes.masterActionBar;
    return [
      ...super.buildMasterActions(context, openItem, isSeparatePage),
      ...(widget as LdCrudMasterDetail<T>)
          .listActions
          .where((action) => action.displayModes.contains(displayMode))
          .map(
            (action) => action.childBuilder(
              () async => await action.onAction(
                _data.isMultiSelectMode
                    ? _data.selectedItems.toList()
                    : _data.items,
                _controller,
                _data,
                _crud,
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
                _controller,
                _data,
                _crud,
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
