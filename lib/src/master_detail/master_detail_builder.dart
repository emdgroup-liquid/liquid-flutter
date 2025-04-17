part of 'master_detail.dart';

abstract class _LdMasterDetailBuilder<T,
    C extends LdMasterDetailController<T>> {
  Widget buildDetailTitle(
    BuildContext context,
    T item,
    bool isSeparatePage,
    C controller,
  );

  Widget buildMasterTitle(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    C controller,
  );

  Widget buildDetail(
    BuildContext context,
    T item,
    bool isSeparatePage,
    C controller,
  );

  Widget buildMaster(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    C controller,
  );

  List<Widget> buildMasterActions(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
    C controller,
  ) {
    return [];
  }

  List<Widget> buildDetailActions(
    BuildContext context,
    T item,
    bool isSeparatePage,
    C controller,
  ) {
    return [];
  }
}

abstract class LdMasterDetailBuilder<T>
    extends _LdMasterDetailBuilder<T, LdMasterDetailController<T>> {}

/// A builder for a CRUD master detail view.
/// For [buildMaster], [LdCrudMasterList] may be a good fit.
abstract class LdCrudMasterDetailBuilder<T extends CrudItemMixin<T>>
    extends _LdMasterDetailBuilder<T, LdCrudMasterDetailController<T>> {}
