import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ExampleBuilder<int> extends LdMasterDetailBuilder<int> {
  final LdPaginator<int> _paginator;

  ExampleBuilder(this._paginator);

  @override
  Widget buildDetail(
      BuildContext context, item, bool isSeparatePage, VoidCallback deselect) {
    return LdAutoSpace(
      children: [
        const LdTextHl("Detail"),
        LdTextL("Item $item"),
        LdButton(child: const Text("Go back"), onPressed: deselect)
      ],
    ).padL();
  }

  @override
  Widget buildDetailTitle(
      BuildContext context, item, bool isSeparatePage, VoidCallback deselect) {
    return Text("Detail $item");
  }

  @override
  Widget buildMaster(BuildContext context, LdMasterDetailOnSelect<int> onSelect,
      int? selectedItem, bool isSeparatePage) {
    return LdList<int, void>(
      data: _paginator,
      itemBuilder: (context, item, index) {
        return LdListItem(
          trailingForward: isSeparatePage,
          active: selectedItem == item,
          title: Text("Item $item"),
          subtitle: const Text("This is a subtitle"),
          onTap: () {
            onSelect(item);
          },
        );
      },
    );
  }

  @override
  Widget buildMasterTitle(
      BuildContext context,
      LdMasterDetailOnSelect<int> onSelect,
      int? selectedItem,
      bool isSeparatePage) {
    return const Text("List of items");
  }
}

class MasterDetailDemo extends StatefulWidget {
  const MasterDetailDemo({Key? key}) : super(key: key);

  @override
  State<MasterDetailDemo> createState() => _MasterDetailDemoState();
}

class _MasterDetailDemoState extends State<MasterDetailDemo> {
  late final LdPaginator<int> _paginator = LdPaginator<int>(
    fetchListFunction: _fetchItems,
  );

  MasterDetailLayoutMode _layoutMode = MasterDetailLayoutMode.split;
  MasterDetailPresentationMode _presentationMode =
      MasterDetailPresentationMode.dialog;

  Future<LdListPage<int>> _fetchItems(
    int page,
    int loadedItems,
    String? nextPageToken,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (loadedItems == 200) {
      return LdListPage<int>(newItems: [], hasMore: false, total: 100);
    }
    return LdListPage<int>(
      newItems: List.generate(30, (index) => loadedItems + index),
      hasMore: true,
      total: 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdMasterDetail",
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
                builder: ExampleBuilder<int>(_paginator),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
