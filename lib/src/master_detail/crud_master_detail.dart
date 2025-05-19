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

class LdCrudMasterDetailBuilders<T extends CrudItemMixin<T>> {
  final LdCrudDetailBuilder<T, Widget>? buildDetailTitle;
  final LdCrudMasterBuilder<T, Widget>? buildMasterTitle;
  final LdCrudDetailBuilder<T, Widget> buildDetail;
  final LdCrudMasterBuilder<T, Widget> buildMaster;
  final LdCrudMasterBuilder<T, List<Widget>>? buildMasterActions;
  final LdCrudDetailBuilder<T, List<Widget>>? buildDetailActions;

  const LdCrudMasterDetailBuilders({
    this.buildDetailTitle,
    this.buildMasterTitle,
    required this.buildDetail,
    required this.buildMaster,
    this.buildMasterActions,
    this.buildDetailActions,
  });
}

/// [LdCrudMasterDetail] is a wrapper around [LdMasterDetail] that provides CRUD
/// functionality for a list of items of type [T].
///
/// It handles various CRUD operations like create, update, delete, and fetch
/// and also performs the usual UI operations like selecting and deselecting
/// items or updating the UI based on the state and result of a CRUD operation.
class LdCrudMasterDetail<T extends CrudItemMixin<T>> extends StatefulWidget {
  final LdCrudOperations<T> crud;
  final LdCrudActionSettings defaultActionSettings;

  // LdCrudMasterDetails-pecific builders
  final LdCrudDetailBuilder<T, Widget>? buildDetailTitle;
  final LdCrudMasterBuilder<T, Widget>? buildMasterTitle;
  final LdCrudDetailBuilder<T, Widget> buildDetail;
  final LdCrudMasterBuilder<T, Widget> buildMaster;
  final LdCrudMasterBuilder<T, List<Widget>>? buildMasterActions;
  final LdCrudDetailBuilder<T, List<Widget>>? buildDetailActions;
  final bool Function(T? openItem, LdCrudListState<T> listState)? isMasterAppBarLoading;
  final bool Function(T? openItem, LdCrudListState<T> listState)? isDetailAppBarLoading;

  final LdMasterDetail<T> Function(
    BuildContext context,
    LdMasterDetailBuilders<T> masterDetailBuilders,
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
    this.defaultActionSettings = const LdCrudActionSettings(),
    this.isMasterAppBarLoading,
    this.isDetailAppBarLoading,
  });

  @override
  State<LdCrudMasterDetail<T>> createState() => LdCrudMasterDetailState<T>();
}

class LdCrudMasterDetailState<T extends CrudItemMixin<T>> extends State<LdCrudMasterDetail<T>> {
  late final crud = widget.crud;
  late final _listState = LdCrudListState<T>(
    fetchListFunction: crud.fetchAll,
  );
  LdCrudListState<T> get listState => _listState;
  LdMasterDetailController<T> get controller => context.read<LdMasterDetailController<T>>();

  bool _isMasterAppBarLoading(T? openItem) {
    return widget.isMasterAppBarLoading?.call(openItem, listState) ?? listState.busy;
  }

  bool _isDetailAppBarLoading(T? openItem) {
    return widget.isDetailAppBarLoading?.call(openItem, listState) ??
        openItem != null && listState.isItemLoading(openItem);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.masterDetailBuilder(
      context,
      LdMasterDetailBuilders<T>(
        buildDetailTitle: _wrapCrudDetailBuilder(widget.buildDetailTitle),
        buildMasterTitle: _wrapCrudMasterBuilder(widget.buildMasterTitle),
        buildDetail: _wrapCrudDetailBuilder(widget.buildDetail)!,
        buildMaster: _wrapCrudMasterBuilder(widget.buildMaster)!,
        buildMasterActions: _wrapBuildMasterActions(widget.buildMasterActions),
        buildDetailActions: _wrapBuildDetailActions(widget.buildDetailActions),
        isMasterAppBarLoading: (openItem) => _isMasterAppBarLoading(openItem),
        isDetailAppBarLoading: (openItem) => _isDetailAppBarLoading(openItem),
        injectables: (context) => [
          Provider<LdCrudMasterDetailState<T>>.value(value: this),
          ListenableProvider<LdCrudListState<T>>.value(value: listState),
        ],
      ),
    );
  }

  LdMasterBuilder<T, Widget>? _wrapCrudMasterBuilder(LdCrudMasterBuilder<T, Widget>? original) {
    return original == null
        ? null
        : (context, openItem, isSeparatePage, controller) {
            final listState = isSeparatePage ? _listState : context.watch<LdCrudListState<T>>();
            final optimisticOpenItem = openItem == null ? null : listState.getItemOptimistically(openItem);
            return original.call(context, openItem, optimisticOpenItem, isSeparatePage, controller, listState);
          };
  }

  LdDetailBuilder<T, Widget>? _wrapCrudDetailBuilder(LdCrudDetailBuilder<T, Widget>? original) {
    return original == null
        ? null
        : (context, item, isSeparatePage, ctrl) {
            final listState = isSeparatePage ? _listState : context.watch<LdCrudListState<T>>();
            final optimisticItem = listState.getItemOptimistically(item);
            return original.call(context, item, optimisticItem, isSeparatePage, ctrl, listState);
          };
  }

  Widget _wrapCrudActionWithKey(Widget widget, int index, [T? item]) {
    if (widget is LdCrudAction) {
      // wrap LdCrudAction with KeyedSubtree to keep track the state of the action
      return KeyedSubtree(
        key: GlobalObjectKey("$hashCode$index${item?.id}"),
        child: widget,
      );
    }
    return widget;
  }

  LdMasterBuilder<T, List<Widget>>? _wrapBuildMasterActions(LdCrudMasterBuilder<T, List<Widget>>? original) {
    return (context, openItem, isSeparatePage, ctrl) {
      final listState = isSeparatePage ? _listState : context.watch<LdCrudListState<T>>();
      final optimisticOpenItem = openItem == null ? null : listState.getItemOptimistically(openItem);
      return (original?.call(context, openItem, optimisticOpenItem, isSeparatePage, ctrl, listState) ?? [])
          .mapIndexed((index, action) => _wrapCrudActionWithKey(action, index))
          .toList();
    };
  }

  LdDetailBuilder<T, List<Widget>>? _wrapBuildDetailActions(LdCrudDetailBuilder<T, List<Widget>>? original) {
    return (context, item, isSeparatePage, ctrl) {
      final listState = isSeparatePage ? _listState : context.watch<LdCrudListState<T>>();
      final optimisticItem = listState.getItemOptimistically(item);
      return (original?.call(context, item, optimisticItem, isSeparatePage, ctrl, listState) ?? [])
          .mapIndexed((index, action) => _wrapCrudActionWithKey(action, index, item))
          .toList();
    };
  }
}
