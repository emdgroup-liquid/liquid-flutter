import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid/components/layout/crud_master_detail.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MasterDetailDemo extends StatefulWidget {
  const MasterDetailDemo({super.key});

  @override
  State<MasterDetailDemo> createState() => _MasterDetailDemoState();
}

class _MasterDetailDemoState extends State<MasterDetailDemo> {
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

  /// The paginator used for the "normal" master detail demo list.
  late final _paginator = LdPaginator(fetchListFunction: _fetchItems);

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
          ComponentWell(
            padding: EdgeInsets.zero,
            title: const LdTextHs("Demo"),
            child: SizedBox(
              height: 300,
              child: LdCard(
                padding: EdgeInsets.zero,
                expandChild: true,
                child: LdMasterDetail<ExampleItem>(
                  layoutMode: _layoutMode,
                  detailPresentationMode: _presentationMode,
                  buildDetailTitle:
                      (context, item, isSeparatePage, controller) =>
                          Text("Detail ${item.name}"),
                  buildMasterTitle:
                      (context, openItem, isSeparatePage, controller) =>
                          const Text("List of Example Items"),
                  buildDetail: (context, item, isSeparatePage, controller) =>
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
                  buildMaster:
                      (context, openItem, isSeparatePage, controller) =>
                          LdList<ExampleItem, void>(
                    paginator: _paginator,
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
