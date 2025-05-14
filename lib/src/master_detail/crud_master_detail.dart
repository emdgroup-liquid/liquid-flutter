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

typedef ErrorDetailPresentationMode = MasterDetailPresentationMode;

enum ErrorNotificationMode { none, notification, autoOpen }

enum LoadingIndicatorStyle {
  none,
  actionBarLoading,
  dialogLoading,
}

typedef LdCrudDetailBuilder<T extends CrudItemMixin<T>, W> = W Function(
  BuildContext context,
  T item,
  T optimisticItem,
  bool isSeparatePage,
  LdMasterDetailController<T> controller,
  LdCrudListState<T> listState,
);

typedef LdCrudMasterBuilder<T extends CrudItemMixin<T>, W> = W Function(
  BuildContext context,
  T? openItem,
  T? optimisticOpenItem,
  bool isSeparatePage,
  LdMasterDetailController<T> controller,
  LdCrudListState<T> listState,
);

/// [LdCrudMasterDetail] is a wrapper around [LdMasterDetail] that provides CRUD
/// functionality for a list of items of type [T].
///
/// It handles various CRUD operations like create, update, delete, and fetch
/// and also performs the usual UI operations like selecting and deselecting
/// items or updating the UI based on the state and result of a CRUD operation.
class LdCrudMasterDetail<T extends CrudItemMixin<T>> extends StatefulWidget {
  final LdCrudOperations<T> crud;
  final ErrorNotificationMode errorNotificationMode;
  final ErrorDetailPresentationMode errorDetailPresentationMode;
  final Set<LoadingIndicatorStyle> loadingIndicatorStyles;

  // LdCrudMasterDetails-pecific builders
  final LdCrudDetailBuilder<T, Widget>? buildDetailTitle;
  final LdCrudMasterBuilder<T, Widget>? buildMasterTitle;
  final LdCrudDetailBuilder<T, Widget> buildDetail;
  final LdCrudMasterBuilder<T, Widget> buildMaster;
  final LdCrudMasterBuilder<T, List<Widget>>? buildMasterActions;
  final LdCrudDetailBuilder<T, List<Widget>>? buildDetailActions;

  final LdMasterDetail<T> Function(
    BuildContext context,
    LdDetailBuilder<T, Widget>? buildDetailTitle,
    LdMasterBuilder<T, Widget>? buildMasterTitle,
    LdDetailBuilder<T, Widget> buildDetail,
    LdMasterBuilder<T, Widget> buildMaster,
    LdMasterBuilder<T, List<Widget>>? buildMasterActions,
    LdDetailBuilder<T, List<Widget>>? buildDetailActions,
  ) masterDetailBuilder;

  const LdCrudMasterDetail({
    super.key,
    required this.crud,
    required this.masterDetailBuilder,
    required this.buildDetail,
    required this.buildMaster,
    this.buildDetailTitle,
    this.buildMasterTitle,
    this.buildMasterActions,
    this.buildDetailActions,
    this.errorNotificationMode = ErrorNotificationMode.none,
    this.errorDetailPresentationMode = MasterDetailPresentationMode.page,
    this.loadingIndicatorStyles = const {
      LoadingIndicatorStyle.actionBarLoading,
      LoadingIndicatorStyle.dialogLoading,
    },
  });

  @override
  State<LdCrudMasterDetail<T>> createState() => LdCrudMasterDetailState<T>();
}

class LdCrudMasterDetailState<T extends CrudItemMixin<T>> extends State<LdCrudMasterDetail<T>> {
  late final crud = widget.crud;
  late final listState = LdCrudListState<T>(
    fetchListFunction: crud.fetchAll,
  );
  late LdMasterDetailController<T> controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _wrapWithStateProviders(
      widget.masterDetailBuilder(
        context,
        _wrapCrudDetailBuilder(widget.buildDetailTitle),
        _wrapCrudMasterBuilder(widget.buildMasterTitle),
        _wrapCrudDetailBuilder(widget.buildDetail)!,
        _wrapCrudMasterBuilder(widget.buildMaster)!,
        _wrapBuildMasterActions(widget.buildMasterActions),
        _wrapBuildDetailActions(widget.buildDetailActions),
      ),
    );
  }

  Widget _wrapWithStateProviders(Widget widget) {
    return Provider<LdCrudMasterDetailState<T>>.value(
      value: this,
      child: ListenableProvider<LdCrudListState<T>>.value(
        value: listState,
        child: ListenableBuilder(
          listenable: listState,
          builder: (context, child) {
            return widget;
          },
        ),
      ),
    );
  }

  LdMasterBuilder<T, Widget>? _wrapCrudMasterBuilder(LdCrudMasterBuilder<T, Widget>? original) {
    return original == null
        ? null
        : (context, openItem, isSeparatePage, controller) {
            return _wrapWithStateProviders(
              original.call(
                context,
                openItem,
                openItem == null ? null : listState.getItemOptimistically(openItem),
                isSeparatePage,
                controller,
                listState,
              ),
            );
          };
  }

  LdDetailBuilder<T, Widget>? _wrapCrudDetailBuilder(LdCrudDetailBuilder<T, Widget>? original) {
    return original == null
        ? null
        : (context, item, isSeparatePage, ctrl) {
            return _wrapWithStateProviders(
              original.call(
                context,
                item,
                listState.getItemOptimistically(item),
                isSeparatePage,
                ctrl,
                listState,
              ),
            );
          };
  }

  LdMasterBuilder<T, List<Widget>>? _wrapBuildMasterActions(LdCrudMasterBuilder<T, List<Widget>>? original) {
    return (context, openItem, isSeparatePage, ctrl) {
      controller = ctrl;
      return (original?.call(
                context,
                openItem,
                openItem == null ? null : listState.getItemOptimistically(openItem),
                isSeparatePage,
                ctrl,
                listState,
              ) ??
              [])
          .map((widget) => _wrapWithStateProviders(widget))
          .toList();
    };
  }

  LdDetailBuilder<T, List<Widget>>? _wrapBuildDetailActions(LdCrudDetailBuilder<T, List<Widget>>? original) {
    return (context, item, isSeparatePage, ctrl) {
      controller = ctrl;
      return (original?.call(
                context,
                item,
                listState.getItemOptimistically(item),
                isSeparatePage,
                ctrl,
                listState,
              ) ??
              [])
          .map((widget) => _wrapWithStateProviders(widget))
          .toList();
    };
  }
}
