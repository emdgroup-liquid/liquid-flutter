import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ListDemo extends StatefulWidget {
  const ListDemo({super.key});

  @override
  State<ListDemo> createState() => _ListDemoState();
}

class _ListDemoState extends State<ListDemo> {
  bool _showSelectionControls = false;
  bool _onSurface = false;
  bool _enableGrouping = false;
  bool _assumeItemHeight = false;
  bool _groupSequentially = false;

  bool _simulateError = false;
  bool _bidirectionalScrolling = false;

  final Set<int> _selectedItems = {};

  late LdPaginator<int> _paginator = LdPaginator<int>(
    initialOffset: 0,
    fetchListFunction: _fetchItems,
  );

  Future<LdListPage<int>> _fetchItems({
    required int offset,
    required int pageSize,
    String? pageToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_simulateError) {
      return LdListPage(
        newItems: [],
        hasMore: false,
        total: 0,
        error: "Simulated error",
      );
    }

    // return a list of 10 items for each page, except for the last page
    // in total, there are 95 items
    return LdListPage<int>(
      newItems: List.generate(
        pageSize,
        (index) => offset + index,
      ),
      hasMore: offset + pageSize < 95,
      total: 95,
    );
  }

  void _selectItem(int item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _setOnSurface(bool value) {
    setState(() {
      _onSurface = value;
    });
  }

  void _setSelectionControls(bool value) {
    setState(() {
      _showSelectionControls = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdList",
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentWell(
              padding: EdgeInsets.zero,
              onSurface: _onSurface,
              child: SizedBox(
                height: 300,
                child: LdList<int, int>(
                  header: const LdListItem(
                    leading: LdAvatar(
                      child: Text("H"),
                    ),
                    title: Text("Header"),
                    subtitle: Text("This is a header"),
                  ),
                  footer: const LdListItem(
                    leading: LdAvatar(
                      child: Text("F"),
                    ),
                    title: Text("Footer"),
                    subtitle: Text("This is a Footer"),
                  ),
                  data: _paginator,
                  assumedItemHeight: _assumeItemHeight ? 50 : null,
                  groupingCriterion:
                      _enableGrouping ? (item) => item % 10 : null,
                  groupSequentialItems: _groupSequentially,
                  separatorBuilder: _enableGrouping
                      ? (context, remainder) => LdListSeperator(
                            onSurface: _onSurface,
                            child: Text(
                              "Remainder of division by 10 - $remainder",
                            ),
                          )
                      : null,
                  loadingBuilder: (context, currentPage, totalItems) {
                    return const LdListItemLoading(
                      hasLeading: true,
                      hasSubContent: false,
                    );
                  },
                  itemBuilder: (context, item, index) {
                    return LdListItem(
                      leading: LdAvatar(
                        color: LdTheme.of(context).palette.success,
                        child: Text(item.toString()),
                      ),
                      trailingForward: true,
                      title: const Text("This is an item in a list"),
                      subtitle: const Text("This is a subtitle"),
                    );
                  },
                ),
              )),
          ldSpacerM,
          LdCard(
            child: LdAutoSpace(
              children: [
                Row(
                  children: [
                    LdButton(
                      onPressed: _paginator.refreshList,
                      child: const Text(
                        "Refresh list",
                      ),
                    ),
                    ldSpacerM,
                    LdButton(
                      child: const Text(
                        "Clear list",
                      ),
                      onPressed: () {
                        _paginator.reset();
                      },
                    ),
                    ldSpacerM,
                  ],
                ),
                LdToggle(
                  label: "On Surface",
                  checked: _onSurface,
                  onChanged: _setOnSurface,
                ),
                LdToggle(
                    checked: _simulateError,
                    label: "Simulate error",
                    onChanged: (value) {
                      setState(() {
                        _simulateError = value;
                      });
                    }),
                LdToggle(
                    checked: _bidirectionalScrolling,
                    label: "Bidirectional scrolling",
                    onChanged: (value) {
                      setState(() {
                        _bidirectionalScrolling = value;
                        _paginator = LdPaginator<int>(
                          initialOffset: _bidirectionalScrolling ? 50 : 0,
                          fetchListFunction: _fetchItems,
                        );
                      });
                    }),
              ],
            ),
          ),
          ldSpacerL,
          LdCard(
            child: LdAutoSpace(
              children: [
                LdToggle(
                    checked: _assumeItemHeight,
                    label:
                        "Assume item height (by passing the assumedItemHeight parameter). ",
                    onChanged: (value) {
                      setState(() {
                        _assumeItemHeight = value;
                      });
                    }),
                const LdTextP(
                    "This will make the scrollbar the correct size and allow flinging, but might result in more data being loaded."),
              ],
            ),
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdToggle(
                    checked: _enableGrouping,
                    label:
                        "Enable grouping (by passing the groupingCriterion parameter and a seperatorBuilder)",
                    onChanged: (value) {
                      setState(() {
                        _enableGrouping = value;
                      });
                    }),
                LdToggle(
                  checked: _groupSequentially,
                  label: "Group sequentially",
                  onChanged: (value) {
                    setState(() {
                      _groupSequentially = value;
                    });
                  },
                ),
                const LdTextPs(
                    "Sequential grouping preserves order, but does not group all items that have the same grouping criterion together."),
                const LdTextPs(
                    "Keep in mind that if you dont group sequentially and items are served in a different order than they are displayed, user experience will suffer to the list jumping around."),
              ],
            ),
          ),
          LdBundle(
            children: [
              const LdTextH("LdListItem"),
              ComponentWell(
                onSurface: _onSurface,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    LdListItem(
                      showSelectionControls: _showSelectionControls,
                      trailingForward: true,
                      isSelected: _selectedItems.contains(0),
                      onSelectionChange: (selected) => _selectItem(0),
                      leading: const LdAvatar(
                        child: Text("A"),
                      ),
                      title: const Text("Liquid Flutter List"),
                      subtitle: const Text("This is a subtitle"),
                    ),
                    const LdDivider(
                      height: 1,
                    ),
                    LdListItem(
                      showSelectionControls: _showSelectionControls,
                      tradeLeadingForSelectionControl: true,
                      isSelected: _selectedItems.contains(1),
                      onSelectionChange: (selected) => _selectItem(1),
                      leading: const LdAvatar(
                        child: Text("B"),
                      ),
                      onTap: () {
                        LdNotificationsController.of(context).addNotification(
                          LdNotification(
                              message: "You pressed the list item",
                              type: LdNotificationType.success),
                        );
                      },
                      title: const Text("Press me"),
                      subtitle: const Text(
                          "I will  trade leading for selection control"),
                    ),
                    LdListSeperator(
                      onSurface: _onSurface,
                      child: const Text("This is a separator"),
                    ),
                    LdListItem(
                      disabled: true,
                      showSelectionControls: _showSelectionControls,
                      isSelected: _selectedItems.contains(2),
                      trailing: const LdTag(
                        child: Text("Hyper hyper"),
                      ),
                      onSelectionChange: (selected) => _selectItem(2),
                      leading: const LdAvatar(
                        child: Text("C"),
                      ),
                      title: const Text("Press me"),
                      subtitle: const Text("This is another subtitle"),
                    ),
                    LdListItem(
                      leading: const LdAvatar(
                        child: Text("D"),
                      ),
                      showSelectionControls: _showSelectionControls,
                      radioSelection: true,
                      isSelected: _selectedItems.contains(3),
                      onSelectionChange: (selected) => _selectItem(3),
                      title: const Text("Very Good Option"),
                      subtitle: const Text("This is another subtitle"),
                    )
                  ],
                ),
              ),
              ldSpacerM,
              Row(
                children: [
                  Expanded(
                    child: LdToggle(
                      label: "Show selection controls",
                      checked: _showSelectionControls,
                      onChanged: _setSelectionControls,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ldSpacerM,
          const LdDivider(),
          ldSpacerM,
          const LdTextH("LdPaginator.fromList"),
          LdList(
            shrinkWrap: true,
            data: LdPaginator.fromList(["1", "2"]),
            itemBuilder: (context, item, index) {
              return LdListItem(
                leading: LdAvatar(
                  child: Text(item),
                ),
                title: const Text("This is an item in a list"),
                subtitle: const Text("This is a subtitle"),
              );
            },
          ),
          const LdTextH(
            "Empty state LdListEmpty()",
          ),
          ldSpacerM,
          SizedBox(
              height: 200,
              child: LdCard(
                  expandChild: true,
                  child: LdListEmpty(
                    onRefresh: () {
                      LdNotificationsController.of(context).addNotification(
                        LdNotification(
                            message: "Refreshed",
                            type: LdNotificationType.success),
                      );
                    },
                  ))),
          ldSpacerM,
          const LdTextH(
            "LdListSeperator()",
          ),
          ldSpacerM,
          const LdListSeperator(
            child: Text("This is a separator"),
          ),
          ldSpacerM,
          const Text("Loading state LdListLoading()"),
          ldSpacerM,
          const LdCard(
            padding: EdgeInsets.zero,
            child: LdListItemLoading(
              hasLeading: true,
              hasTrailing: true,
            ),
          )
        ],
      ),
    );
  }
}
