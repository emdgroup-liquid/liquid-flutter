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

class ExampleRepository extends CrudOperations<ExampleItem> {
  static int pageSize = 25;
  final List<ExampleItem> _data = List.generate(
    exampleTitles.length,
    (index) => ExampleItem(index, exampleTitles[index]),
  );

  /// Find the next available ID
  int? _nextId;
  int get nextId {
    _nextId ??= _data.lastOrNull?.id ?? -1;
    _nextId = _nextId! + 1;
    return _nextId!;
  }

  @override
  Future<ExampleItem> create(ExampleItem item) async {
    if (!item.isNew) {
      throw LdException(message: "Item already exists");
    }
    final newItem = ExampleItem(nextId, item.name);
    await Future.delayed(const Duration(seconds: 1));
    _data.add(newItem);
    return Future.value(newItem);
  }

  @override
  Future<ExampleItem> update(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _data.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _data[index] = item;
    } else {
      Future.error(LdException(message: "Item with id ${item.id} not found."));
    }
    return Future.value(item);
  }

  @override
  Future<void> delete(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));
    _data.removeWhere((element) => element.id == item.id);
  }

  @override
  FetchListFunction<ExampleItem> get fetchAll =>
      (page, loadedItems, nextPageToken) async {
        final newItems = _data.skip(page * pageSize).take(pageSize).toList();
        await Future.delayed(const Duration(seconds: 1));

        return LdListPage<ExampleItem>(
          newItems: newItems,
          hasMore: page * pageSize + loadedItems < _data.length,
          total: _data.length,
        );
      };
}

class ExampleBuilder extends LdMasterDetailBuilder<ExampleItem> {
  final LdPaginator<ExampleItem> paginator;

  ExampleBuilder(this.paginator);

  static Widget createDetailWidget(
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
          child: const Text("Go back"),
          onPressed: controller.onCloseItem,
        )
      ],
    ).padL();
  }

  static Widget createMasterWidget(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
    LdPaginator<ExampleItem> paginator,
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
            controller.onOpenItem(item);
          },
          isSelected: (controller is LdCrudMasterDetailController<ExampleItem>)
              ? controller.data.isItemSelected(item)
              : false,
          showSelectionControls:
              (controller is LdCrudMasterDetailController<ExampleItem>)
                  ? controller.data.isMultiSelectMode
                  : false,
          onSelectionChange: (selected) {
            if (controller is LdCrudMasterDetailController<ExampleItem>) {
              controller.data.toggleItemSelection(item);
            }
          },
          onLongPress: () {
            if (controller is LdCrudMasterDetailController<ExampleItem>) {
              controller.data.toggleMultiSelectMode();
              if (controller.data.isMultiSelectMode) {
                controller.data.toggleItemSelection(item);
              }
            }
          },
        );
      },
    );
  }

  static Widget createMasterTitle(BuildContext context, ExampleItem? openItem) {
    return const Text("List of Example Items");
  }

  static Widget createDetailTitle(BuildContext context, ExampleItem item) {
    return Text("Detail ${item.name}");
  }

  @override
  Widget buildDetail(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return createDetailWidget(context, item, isSeparatePage, controller);
  }

  @override
  Widget buildDetailTitle(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return createDetailTitle(context, item);
  }

  @override
  Widget buildMaster(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdMasterDetailController<ExampleItem> controller,
  ) {
    return createMasterWidget(
      context,
      openItem,
      isSeparatePage,
      controller,
      paginator,
    );
  }

  @override
  Widget buildMasterTitle(BuildContext context, ExampleItem? openItem,
      bool isSeparatePage, LdMasterDetailController<ExampleItem> controller) {
    return createMasterTitle(context, openItem);
  }
}

class ExampleCrudBuilder extends LdCrudMasterDetailBuilder<ExampleItem> {
  @override
  Widget buildDetail(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdCrudMasterDetailController<ExampleItem> controller,
  ) {
    return ExampleBuilder.createDetailWidget(
      context,
      item,
      isSeparatePage,
      controller,
    );
  }

  @override
  Widget buildDetailTitle(
    BuildContext context,
    ExampleItem item,
    bool isSeparatePage,
    LdCrudMasterDetailController<ExampleItem> controller,
  ) {
    return ExampleBuilder.createDetailTitle(context, item);
  }

  @override
  Widget buildMaster(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdCrudMasterDetailController<ExampleItem> controller,
  ) {
    return ExampleBuilder.createMasterWidget(
      context,
      openItem,
      isSeparatePage,
      controller,
      controller.data,
    );
  }

  @override
  Widget buildMasterTitle(
    BuildContext context,
    ExampleItem? openItem,
    bool isSeparatePage,
    LdCrudMasterDetailController<ExampleItem> controller,
  ) {
    return ExampleBuilder.createMasterTitle(context, openItem);
  }

  @override
  List<Widget> buildMasterActions(
      BuildContext context,
      ExampleItem? openItem,
      bool isSeparatePage,
      LdCrudMasterDetailController<ExampleItem> controller) {
    if (controller.data.isMultiSelectMode) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            controller.batchDelete(
              controller.data.selectedItems,
              onItemsDeleted: () {
                LdNotificationsController.of(context).error(
                  "Items deleted",
                );
              },
            );
          },
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          controller.create(ExampleItem(null, "New item"),
              onItemCreated: (item) {
            LdNotificationsController.of(context).success(
              "Item successfully created",
            );
          });
        },
      ),
    ];
  }

  @override
  List<Widget> buildDetailActions(
      BuildContext context,
      ExampleItem item,
      bool isSeparatePage,
      LdCrudMasterDetailController<ExampleItem> controller) {
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final notification =
              (await LdNotificationsController.of(context).addNotification(
            LdInputNotification(
              inputHint: "Edit item",
              inputLabel: "Name",
              type: LdNotificationType.enterText,
              message: "Enter new name",
            ),
          )) as LdInputNotification;
          final newName = await notification.inputCompleter.future;
          if (newName?.isNotEmpty ?? false) {
            controller.save(ExampleItem(item.id, newName!),
                onItemSaved: (item) {
              LdNotificationsController.of(context).success(
                "Item successfully saved",
              );
            });
          }
        },
      ),
      IconButton(
        onPressed: () async {
          await controller.delete(item, onItemDeleted: (item) {
            LdNotificationsController.of(context).error(
              "Item deleted",
            );
          });
        },
        icon: const Icon(Icons.delete),
      ),
    ];
  }
}

class MasterDetailDemo extends StatefulWidget {
  const MasterDetailDemo({Key? key}) : super(key: key);

  @override
  State<MasterDetailDemo> createState() => _MasterDetailDemoState();
}

class _MasterDetailDemoState extends State<MasterDetailDemo> {
  final ExampleRepository _crudRepository = ExampleRepository();
  Future<LdListPage<ExampleItem>> _fetchItems(
    int page,
    int loadedItems,
    String? nextPageToken,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (loadedItems == 200) {
      return LdListPage<ExampleItem>(newItems: [], hasMore: false, total: 100);
    }
    return LdListPage<ExampleItem>(
      newItems: List.generate(
        30,
        (index) => ExampleItem(index, "Item $index"),
      ),
      hasMore: true,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
