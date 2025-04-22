import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

final exampleTitles =
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy "
            "eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam "
            "voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet "
            "clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
        .split(" ");

class ExampleItem with CrudItemMixin<ExampleItem> {
  @override
  final int? id;
  final String name;

  ExampleItem(this.id, this.name);

  @override
  String toString() {
    return "ExampleItem($id, $name)";
  }
}

class ExampleRepository extends LdCrudOperations<ExampleItem> {
  final List<ExampleItem> _items = List.generate(
      exampleTitles.length, (i) => ExampleItem(i, exampleTitles[i]));

  /// Find the next available ID
  int? _nextId;
  int get nextId {
    _nextId ??= _items.lastOrNull?.id;
    _nextId = (_nextId ?? -1) + 1;
    return _nextId!;
  }

  int get itemsCount => _items.length;

  @override
  Future<ExampleItem> create(ExampleItem item) async {
    if (!item.isNew) {
      throw LdException(message: "Item already exists");
    }
    final newItem = ExampleItem(nextId, item.name);
    await Future.delayed(const Duration(seconds: 1));

    _items.add(newItem);
    return Future.value(newItem);
  }

  @override
  Future<ExampleItem> update(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items[index] = item;
      return Future.value(item);
    }
    throw LdException(message: "Item not found");
  }

  @override
  Future<void> delete(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items.removeAt(index);
      return;
    }
    throw LdException(message: "Item not found");
  }

  @override
  FetchListFunction<ExampleItem> get fetchAll => ({
        required int offset,
        required int pageSize,
        String? pageToken,
      }) async {
        await Future.delayed(const Duration(seconds: 1));
        final endIndex = min(offset + pageSize, _items.length);
        final pageItems = offset >= _items.length
            ? <ExampleItem>[]
            : _items.sublist(offset, endIndex);
        final hasMore = endIndex < _items.length;
        return LdListPage<ExampleItem>(
          newItems: pageItems,
          hasMore: hasMore,
          total: itemsCount,
        );
      };
}

class ExampleBuilder extends LdMasterDetailBuilder<ExampleItem> {
  final LdPaginator<ExampleItem> paginator;

  ExampleBuilder(this.paginator);

  @override
  Widget buildDetail(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return LdAutoSpace(
      children: [
        const LdTextHl("Detail"),
        LdTextL("Item ${item.id}: ${item.name}"),
        LdButton(
          onPressed: controller.closeItem,
          child: const Text("Go back"),
        )
      ],
    ).padL();
  }

  @override
  Widget buildDetailTitle(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return Text("Detail ${item.name}");
  }

  @override
  Widget buildMaster(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return LdList<ExampleItem, void>(
      data: paginator,
      assumedItemHeight: 60,
      itemBuilder: (context, item, index) {
        return LdListItem(
          trailingForward: isSeparatePage,
          active: openItem?.id == item.id,
          title: Text(item.name),
          subtitle: Text("ID: ${item.id}"),
          onTap: () {
            controller.openItem(item);
          },
        );
      },
    );
  }

  @override
  Widget buildMasterTitle(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return const Text("List of Example Items");
  }
}

class ExampleCrudBuilder extends LdCrudMasterDetailBuilder<ExampleItem> {
  @override
  Widget buildDetail(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return LdAutoSpace(
      children: [
        const LdTextHl("Detail"),
        LdTextL("Item ${item.id}: ${item.name}"),
        LdButton(
          onPressed: controller.closeItem,
          child: const Text("Go back"),
        )
      ],
    ).padL();
  }

  @override
  Widget buildDetailTitle(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return Text("Detail ${item.name}");
  }

  @override
  Widget buildMaster(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return LdCrudMasterList(
      data: getData(context),
      controller: controller,
      titleBuilder: (context, item) => Text(item.name),
      subtitleBuilder: (context, item) => Text("ID: ${item.id}"),
      openItem: openItem,
    );
  }

  @override
  Widget buildMasterTitle(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    final data = getData(context);
    final title = data.isMultiSelectMode
        ? "${data.selectedItems.length}/${data.totalItems} selected"
        : "List of Example Items";
    return Text(title);
  }

  @override
  List<Widget> buildMasterActions(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return [];
  }

  @override
  List<Widget> buildDetailActions(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return [];
  }
}

class MasterDetailDemo extends StatefulWidget {
  const MasterDetailDemo({super.key});

  @override
  State<MasterDetailDemo> createState() => _MasterDetailDemoState();
}

class _MasterDetailDemoState extends State<MasterDetailDemo> {
  final ExampleRepository _crudRepository = ExampleRepository();
  Future<LdListPage<ExampleItem>> _fetchItems({
    required int offset,
    required int pageSize,
    String? pageToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return LdListPage<ExampleItem>(
      newItems: List.generate(
        pageSize,
        (index) => ExampleItem(offset + index, "Item ${offset + index}"),
      ),
      hasMore: offset + pageSize < 200,
      total: 200,
    );
  }

  MasterDetailLayoutMode _layoutMode = MasterDetailLayoutMode.split;
  MasterDetailPresentationMode _presentationMode =
      MasterDetailPresentationMode.dialog;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdMasterDetail",
      apiComponents: const [
        "LdMasterDetail",
        "LdMasterDetailBuilder",
        "LdMasterDetailController",
        "LdCrudMasterDetail",
        "CrudOperations",
        "CrudItemMixin",
        "LdCrudMasterDetailBuilder",
        "LdCrudMasterDetailController",
        "LdCrudPaginator"
      ],
      demo: LdAutoSpace(
        children: [
          LdSelect(
            label: "Layout mode",
            items: [
              ...MasterDetailLayoutMode.values.map(
                (e) => LdSelectItem(value: e, child: Text(e.toString())),
              ),
            ],
            value: _layoutMode,
            onChange: (value) {
              setState(() {
                _layoutMode = value;
              });
            },
          ),
          LdSelect(
            label: "Presentation mode (only for compact layout)",
            items: [
              ...MasterDetailPresentationMode.values.map(
                (e) => LdSelectItem(value: e, child: Text(e.toString())),
              ),
            ],
            value: _presentationMode,
            onChange: (value) {
              setState(() {
                _presentationMode = value;
              });
            },
          ),
          SizedBox(
            height: 300,
            child: LdCard(
              padding: EdgeInsets.zero,
              expandChild: true,
              child: LdMasterDetail(
                layoutMode: _layoutMode,
                detailPresentationMode: _presentationMode,
                builder: ExampleBuilder(
                  LdPaginator(fetchListFunction: _fetchItems),
                ),
              ),
            ),
          ),
          ldSpacerM,
          const LdTextH(
            "LdCrudMasterDetail",
          ),
          ldSpacerM,
          const LdTextP(
            "LdCrudMasterDetail extends the LdMasterDetail widget to provide CRUD functionality for a list of items of type T. "
            "It handles various CRUD operations like create, update, delete, and fetch and also performs the usual UI operations "
            "like selecting and deselecting items or updating the UI based on the state and result of a CRUD operation.",
          ),
          SizedBox(
            height: 300,
            child: LdCard(
              padding: EdgeInsets.zero,
              expandChild: true,
              child: LdCrudMasterDetail(
                layoutMode: _layoutMode,
                detailPresentationMode: _presentationMode,
                builder: ExampleCrudBuilder(),
                crud: _crudRepository,
                itemActions: [
                  LdMasterDetailItemAction<ExampleItem>.updateItem(
                    getNewItem: (item) async {
                      final notification =
                          (await LdNotificationsController.of(context)
                              .addNotification(
                        LdInputNotification(
                          inputHint: "Edit item",
                          inputLabel: "Name",
                          type: LdNotificationType.enterText,
                          message: "Enter new name",
                        ),
                      )) as LdInputNotification;
                      final newName = await notification.inputCompleter.future;
                      if (newName?.isNotEmpty ?? false) {
                        return ExampleItem(item.id, newName!);
                      }
                      return null;
                    },
                  ),
                  LdMasterDetailItemAction<ExampleItem>.deleteItem(),
                ],
                listActions: [
                  LdMasterDetailListAction<ExampleItem>.newItemAction(
                    getNewItem: () async {
                      final notification =
                          (await LdNotificationsController.of(context)
                              .addNotification(
                        LdInputNotification(
                          inputHint: "Create item",
                          inputLabel: "Name",
                          type: LdNotificationType.enterText,
                          message: "Enter new name",
                        ),
                      )) as LdInputNotification;
                      final newName = await notification.inputCompleter.future;
                      if (newName?.isNotEmpty ?? false) {
                        return ExampleItem(null, newName!);
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
