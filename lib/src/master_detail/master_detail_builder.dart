part of 'master_detail.dart';

abstract class _LdMasterDetailBuilder<T> {
  Widget buildDetailTitle(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  );

  Widget buildMasterTitle(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  );

  Widget buildDetail(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  );

  Widget buildMaster(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  );

  List<Widget> buildMasterActions(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  ) {
    return [];
  }

  List<Widget> buildDetailActions(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  ) {
    return [];
  }
}

abstract class LdMasterDetailBuilder<T> extends _LdMasterDetailBuilder<T> {}

/// A builder for a CRUD master detail view.
/// For [buildMaster], [LdCrudMasterList] may be a good fit.
abstract class LdCrudMasterDetailBuilder<T extends CrudItemMixin<T>>
    extends _LdMasterDetailBuilder<T> {
  LdCrudListState<T> getData(BuildContext context) =>
      context.read<LdCrudListState<T>>();

  @override
  Widget buildDetail(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  ) {
    final error = getData(context).getItemError(item);
    if (error != null) {
      return buildDetailError(context, item, error, isSeparatePage, controller);
    }
    return buildDetailContent(context, item, isSeparatePage, controller);
  }

  Widget buildDetailContent(
    BuildContext context,
    T item,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  );

  Widget buildDetailError(
    BuildContext context,
    T item,
    LdException error,
    bool isSeparatePage,
    LdMasterDetailController<T> controller,
  ) {
    return Center(child: LdExceptionView(exception: error));
  }
}
