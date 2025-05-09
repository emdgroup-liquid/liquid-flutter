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
  bool _onSurface = false;
  bool _enableGrouping = false;
  bool _assumeItemHeight = false;

  bool _simulateError = false;
  bool _bidirectionalScrolling = false;

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

  void _setOnSurface(bool value) {
    setState(() {
      _onSurface = value;
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
                  paginator: _paginator,
                  assumedItemHeight: _assumeItemHeight ? 50 : null,
                  groupingCriterion:
                      _enableGrouping ? (item) => item ~/ 10 : null,
                  groupHeaderBuilder: _enableGrouping
                      ? (context, remainder) => LdListSeperator(
                            onSurface: _onSurface,
                            child: Text(
                              "Range $remainder",
                            ),
                          )
                      : null,
                  loadingBuilder: (context, currentPage, totalItems) {
                    return const LdListItemLoading(
                      hasLeading: true,
                      hasSubContent: false,
                    );
                  },
                  separatorBuilder: (
                    context,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: const LdDivider(),
                    );
                  },
                  itemBuilder: (context, item, state) {
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
              ],
            ),
          ),
          LdBundle(
            children: [],
          ),
          ldSpacerM,
          const LdDivider(),
          ldSpacerM,
          const LdTextH("LdPaginator.fromList"),
          LdList(
            shrinkWrap: true,
            paginator: LdPaginator.fromList(["1", "2"]),
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
