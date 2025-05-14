part of 'master_detail.dart';

typedef LdMasterDetailCrudItemCallback<T> = void Function(T item);

/// Defines a repository that can perform CRUD operations on a given type [T]
/// and fetch a list of items of type [T].
abstract class LdCrudOperations<T> {
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(T item);
  Future<void> batchDelete(Iterable<T> items) async {
    print("Deleting ${items.length} items");
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

typedef ErrorDetailPresentationMode = MasterDetailPresentationMode;

enum ErrorNotificationMode { none, notification, autoOpen }

enum LoadingIndicatorStyle {
  none,
  actionBarLoading,
  dialogLoading,
}

/// [LdCrudMasterDetail] extends the [LdMasterDetail] widget to provide CRUD
/// functionality for a list of items of type [T].
///
/// It handles various CRUD operations like create, update, delete, and fetch
/// and also performs the usual UI operations like selecting and deselecting
/// items or updating the UI based on the state and result of a CRUD operation.
class LdCrudMasterDetail<T extends CrudItemMixin<T>> extends LdMasterDetail<T> {
  final LdCrudOperations<T> crud;
  final ErrorNotificationMode errorNotificationMode;
  final ErrorDetailPresentationMode errorDetailPresentationMode;
  final Set<LoadingIndicatorStyle> loadingIndicatorStyles;

  const LdCrudMasterDetail({
    super.key,
    super.buildDetailTitle,
    super.buildMasterTitle,
    required super.buildDetail,
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
    this.errorNotificationMode = ErrorNotificationMode.none,
    this.errorDetailPresentationMode = MasterDetailPresentationMode.page,
    this.loadingIndicatorStyles = const {
      LoadingIndicatorStyle.actionBarLoading,
      LoadingIndicatorStyle.dialogLoading,
    },
  });

  @override
  State<LdMasterDetail<T>> createState() => LdCrudMasterDetailState<T>();
}

class LdCrudMasterDetailState<T extends CrudItemMixin<T>> extends _LdMasterDetailState<T> {
  @override
  LdCrudMasterDetail<T> get widget => super.widget as LdCrudMasterDetail<T>;

  late final crud = widget.crud;
  late final listState = LdCrudListState<T>(
    fetchListFunction: crud.fetchAll,
  );
  LdMasterDetailController<T> get controller => _controller;

  bool get _showActionBarLoading => widget.loadingIndicatorStyles.contains(LoadingIndicatorStyle.actionBarLoading);

  @override
  bool get _isMasterAppBarLoading => _showActionBarLoading && listState.busy;

  @override
  bool get _isDetailsAppBarLoading => _showActionBarLoading && _openItem != null && listState.isItemLoading(_openItem!);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdMasterDetailController<T>>.value(
      value: _controller,
      child: ListenableProvider<LdCrudListState<T>>.value(
        value: listState,
        child: ListenableBuilder(
          listenable: listState,
          builder: (context, child) {
            return super.build(context);
          },
        ),
      ),
    );
  }

  @override
  Widget _buildDetailPage(T item) {
    return ListenableProvider<LdCrudListState<T>>.value(
      value: listState,
      child: ListenableBuilder(
        listenable: listState,
        builder: (context, child) {
          return super._buildDetailPage(item);
        },
      ),
    );
  }
}
