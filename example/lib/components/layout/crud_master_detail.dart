import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
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
}

class ExampleRepository extends LdCrudOperations<ExampleItem> {
  bool simulateErrors = false;

  final List<ExampleItem> _items = List.generate(
      exampleTitles.length, (i) => ExampleItem(i, exampleTitles[i]));

  ExampleRepository._privateConstructor();

  static final ExampleRepository _instance =
      ExampleRepository._privateConstructor();

  factory ExampleRepository.instance() {
    return _instance;
  }

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
    await _simulateNetworkRequest();

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
    await _simulateNetworkRequest();

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items[index] = item;
      return Future.value(item);
    }
    throw LdException(message: "Item not found");
  }

  @override
  Future<void> delete(ExampleItem item) async {
    await _simulateNetworkRequest();

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items.removeAt(index);
      return;
    }
    throw LdException(message: "Item not found");
  }

  ExampleItem? getItemById(int id) {
    return _items.firstWhereOrNull((element) => element.id == id);
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

  Future<void> _simulateNetworkRequest() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(500)));
    if (simulateErrors) {
      throw LdException(message: "Simulated error");
    }
  }
}

class CrudMasterDetailDemo extends StatefulWidget {
  const CrudMasterDetailDemo({super.key});

  @override
  State<CrudMasterDetailDemo> createState() => _CrudMasterDetailDemoState();
}

class _CrudMasterDetailDemoState extends State<CrudMasterDetailDemo> {
  MasterDetailLayoutMode _layoutMode = MasterDetailLayoutMode.split;
  MasterDetailPresentationMode _presentationMode =
      MasterDetailPresentationMode.dialog;
  bool _showLoadingDialog = false;
  bool _showNotificationOnError = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdCrudMasterDetail",
      apiComponents: const [
        "LdMasterDetail",
        "LdMasterDetailBuilder",
        "LdMasterDetailController",
      ],
      demo: LdAutoSpace(
        children: [
          const LdTextP(
            "LdCrudMasterDetail wraps around the LdMasterDetail widget to provide CRUD functionality for a list of items of type T. "
            "It handles various CRUD operations like create, update, delete, and fetchAll, and performs the usual UI operations "
            "like selecting and deselecting items or updating the UI based on the state and result of a CRUD operation.",
          ),
          ldSpacerL,
          const LdTextH("Demo"),
          ldSpacerS,
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
          LdToggle(
            label: "Show loading dialog",
            checked: _showLoadingDialog,
            onChanged: (value) {
              setState(() => _showLoadingDialog = value);
            },
          ),
          LdToggle(
            label: "Simulate errors",
            checked: ExampleRepository.instance().simulateErrors,
            onChanged: (value) {
              setState(() {
                ExampleRepository.instance().simulateErrors = value;
              });
            },
          ),
          LdToggle(
            label: "Show notification on error",
            disabled: !ExampleRepository.instance().simulateErrors,
            checked: _showNotificationOnError,
            onChanged: (value) {
              setState(() => _showNotificationOnError = value);
            },
          ),
          ComponentWell(
            padding: EdgeInsets.zero,
            title: const LdTextHs("Demo"),
            child: SizedBox(
              height: 300,
              child: LdCard(
                padding: EdgeInsets.zero,
                expandChild: true,
                child: LdCrudMasterDetail<ExampleItem>(
                  crud: ExampleRepository.instance(),
                  defaultActionSettings: LdCrudActionSettings(
                    showLoadingDialog: _showLoadingDialog,
                    errorNotificationMessage: _showNotificationOnError
                        ? "An error occurred while performing the operation."
                        : null,
                  ),
                  masterDetailBuilder: (context, builders) =>
                      LdMasterDetail.builders(
                    builders: builders,
                    layoutMode: _layoutMode,
                    detailPresentationMode: _presentationMode,
                  ),
                  buildDetailTitle: (context, item, optimisticItem,
                          isSeparatePage, controller, listState) =>
                      Text("Detail ${item.name}"),
                  buildMasterTitle: (context, openItem, optimisticOpenItem,
                      isSeparatePage, controller, listState) {
                    final title = listState.isMultiSelectMode
                        ? "${listState.selectedItems.length}/${listState.totalItems} selected"
                        : "List of Example Items";
                    return Text(title);
                  },
                  buildDetail: (
                    context,
                    item,
                    optimisticItem,
                    isSeparatePage,
                    controller,
                    listState,
                  ) =>
                      LdAutoSpace(
                    children: [
                      const LdTextHl("Detail"),
                      LdTextL("Item ${item.id}: ${item.name}"),
                      LdButton(
                        onPressed: controller.closeItem,
                        child: const Text("Go back"),
                      )
                    ],
                  ).padL(),
                  buildMaster: (context, openItem, optimisticOpenItem,
                          isSeparatePage, controller, listState) =>
                      LdCrudMasterList<ExampleItem>(
                    listState: listState,
                    controller: controller,
                    titleBuilder: (context, item, optimisticItem) =>
                        Text(item.name),
                    subtitleBuilder: (context, item, optimisticItem) =>
                        Text("ID: ${item.id}"),
                  ),
                  buildMasterActions: (context, openItem, optimisticOpenItem,
                          isSeparatePage, controller, listState) =>
                      [
                    LdCrudAction.createItem<ExampleItem>(
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
                        final newName =
                            await notification.inputCompleter.future;
                        if (newName?.isNotEmpty ?? false) {
                          return ExampleItem(null, newName!);
                        }
                        return null;
                      },
                    ),
                    LdCrudAction.deleteSelectedItems<ExampleItem>(),
                  ],
                  buildDetailActions: (context, item, optimisticItem,
                          isSeparatePage, controller, listState) =>
                      [
                    LdCrudAction.updateItem<ExampleItem>(
                      getUpdatedItem: () async {
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
                        final newName =
                            await notification.inputCompleter.future;
                        if (newName?.isNotEmpty ?? false) {
                          return ExampleItem(item.id, newName!);
                        }
                        return null;
                      },
                    ),
                    LdCrudAction.deleteItem<ExampleItem>(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
