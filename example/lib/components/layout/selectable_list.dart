import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/sample_list_data.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SelectableListDemo extends StatefulWidget {
  const SelectableListDemo({super.key});

  @override
  State<SelectableListDemo> createState() => _SelectableListDemoState();
}

class _SelectableListDemoState extends State<SelectableListDemo> {
  late final LdPaginator<SampleItem> _paginator = LdPaginator<SampleItem>(
    initialOffset: 0,
    fetchListFunction: _fetchItems,
  );

  bool _multiSelect = false;
  bool _showSelectionControls = false;

  Future<LdListPage<SampleItem>> _fetchItems({
    required int offset,
    required int pageSize,
    String? pageToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // return a list of 10 items for each page, except for the last page
    // in total, there are 95 items
    return LdListPage<SampleItem>(
      newItems: sampleItems.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < sampleItems.length,
      total: sampleItems.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdSelectableList",
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LdTextP(
            'LdSelectableList is a list component that supports item selection in both single and multi-select modes. '
            'It integrates with LdPaginator for pagination and allows customization of item rendering through builder functions. '
            'The component handles selection state management internally and provides callbacks for selection changes.',
          ),
          LdTextP("You can simply wrap an existing LdList with LdSelectableList to make it selectable."),
          CodeBlock(
            code: """
            LdSelectableList<int, void>(
              multiSelect: true,
              paginator: _paginator,
              listBuilder: (context, scrollController, itemBuilder) {
                // Item builder gets wrapped by LdSelectableList and lifted
                // to the LdSelectableList widget.
                return LdList<.., ..>(
                  itemBuilder: itemBuilder,
                  scrollController: scrollController,
                )
              ),
              itemBuilder: ({
                required BuildContext context,
                required int item,
                required int index,
                required bool selected,
                required bool isMultiSelect,
                required void Function(bool selected) onSelectionChange,
                required VoidCallback onTap,
              }) {

              })
            """,
          ),
          SizedBox(
            height: 500,
            child: LdSelectableList<SampleItem, void>(
              multiSelect: _multiSelect,
              paginator: _paginator,
              listBuilder: (context, scrollController, itemBuilder) {
                return LdList<SampleItem, void>(
                  scrollController: scrollController,
                  paginator: _paginator,
                  itemBuilder: itemBuilder,
                );
              },
              itemBuilder: ({
                required BuildContext context,
                required SampleItem item,
                required int index,
                required bool selected,
                required bool isMultiSelect,
                required void Function(bool selected) onSelectionChange,
                required VoidCallback onTap,
              }) {
                return LdListItem(
                  active: selected,
                  leading: LdAvatar(child: Text(item.formula)),
                  isSelected: selected,
                  radioSelection: !isMultiSelect,
                  showSelectionControls: _showSelectionControls,
                  onSelectionChange: onSelectionChange,
                  onTap: onTap,
                  subtitle: Text(item.subtitle),
                  title: Text(item.title),
                );
              },
            ),
          ),
          LdToggle(
            checked: _multiSelect,
            onChanged: (checked) {
              setState(() {
                _multiSelect = checked;
              });
            },
            label: "Multi-select",
          ),
          LdToggle(
            checked: _showSelectionControls,
            onChanged: (checked) {
              setState(() {
                _showSelectionControls = checked;
              });
            },
            label: "Show selection controls",
          )
        ],
      ),
    );
  }
}
