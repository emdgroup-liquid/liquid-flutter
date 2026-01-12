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

  late LdPaginator<_DemoItem, int> _paginator = LdPaginator<_DemoItem, int>(
    initialOffset: 0,
    fetchListFunction: _fetchItems,
  );

  Future<LdListPage<_DemoItem>> _fetchItems({required int offset, required int pageSize, String? pageToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_simulateError) {
      throw Exception("Simulated error");
    }

    // return a list of 10 items for each page, except for the last page
    // in total, there are 95 items
    return LdListPage<_DemoItem>(
      newItems: _demoItems.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < _demoItems.length,
      total: _demoItems.length,
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
      path: "lib/components/layout/list.dart",
      title: "LdList",
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentWell(
            padding: EdgeInsets.zero,
            onSurface: _onSurface,
            child: SizedBox(
              height: 300,
              child: LdList<_DemoItem, int>(
                header: const LdListItem(
                  leading: LdAvatar(child: Text("H")),
                  title: Text("Header"),
                  subtitle: Text("This is a header"),
                ),
                footer: const LdListItem(
                  leading: LdAvatar(child: Text("F")),
                  title: Text("Footer"),
                  subtitle: Text("This is a Footer"),
                ),
                paginator: _paginator,
                assumedItemHeight: _assumeItemHeight ? 50 : null,
                groupingCriterion: _enableGrouping ? (item) => item.category : null,
                groupHeaderBuilder: _enableGrouping
                    ? (context, remainder, items) =>
                          LdListSeperator(onSurface: _onSurface, child: Text("Range $remainder"))
                    : null,
                loadingBuilder: (context, currentPage, totalItems) {
                  return const LdListItemLoading(hasLeading: true, hasSubContent: false);
                },
                separatorBuilder: (context) {
                  return Padding(padding: const EdgeInsets.only(left: 16), child: const LdDivider());
                },
                itemBuilder: (context, item, state) {
                  return LdListItem(
                    leading: LdAvatar(
                      color: LdTheme.of(context).palette.success,
                      child: Text(item.value.name.toString().substring(0, 1)),
                    ),
                    title: Text(item.value.name),
                    subtitle: Text(item.value.category),
                  );
                },
              ),
            ),
          ),
          ldSpacerM,
          LdCard(
            child: LdAutoSpace(
              children: [
                Wrap(
                  children: [
                    LdButton(onPressed: _paginator.refreshList, child: const Text("Refresh list")),
                    LdButton(
                      child: const Text("Clear list"),
                      onPressed: () {
                        _paginator.reset();
                      },
                    ),
                    LdButton(
                      child: const Text("Delete item 1"),
                      onPressed: () {
                        _paginator.scheduleItemDeletion(1);
                      },
                    ),
                    LdButton(
                      child: const Text("Try to delete item 2 but fail"),
                      onPressed: () async {
                        _paginator.scheduleItemDeletion(2);
                        await Future.delayed(const Duration(seconds: 1));
                        _paginator.rollbackItemDeletion(2);
                      },
                    ),
                    LdButton(
                      child: const Text("Update item 3 to be something else"),
                      onPressed: () async {
                        _paginator.scheduleItemUpdate(3, _demoItems[3]);

                        await Future.delayed(const Duration(seconds: 1));

                        _paginator.confirmItemUpdate(3, null);
                      },
                    ),
                    LdButton(
                      child: const Text("Update item 3 but fail"),
                      onPressed: () async {
                        _paginator.scheduleItemUpdate(3, _demoItems[3]);
                        await Future.delayed(const Duration(seconds: 1));
                        _paginator.rollbackItemUpdate(3);
                      },
                    ),
                  ],
                ).spaceM(),
                LdToggle(label: "On Surface", checked: _onSurface, onChanged: _setOnSurface),
                LdToggle(
                  checked: _simulateError,
                  label: "Simulate error",
                  onChanged: (value) {
                    setState(() {
                      _simulateError = value;
                    });
                  },
                ),
                LdToggle(
                  checked: _bidirectionalScrolling,
                  label: "Bidirectional scrolling",
                  onChanged: (value) {
                    setState(() {
                      _bidirectionalScrolling = value;
                      _paginator = LdPaginator<_DemoItem, int>(
                        initialOffset: _bidirectionalScrolling ? 50 : 0,
                        fetchListFunction: _fetchItems,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          ldSpacerL,
          LdCard(
            child: LdAutoSpace(
              children: [
                LdToggle(
                  checked: _assumeItemHeight,
                  label: "Assume item height (by passing the assumedItemHeight parameter). ",
                  onChanged: (value) {
                    setState(() {
                      _assumeItemHeight = value;
                    });
                  },
                ),
                LdText.p(
                  "This will make the scrollbar the correct size and allow flinging, but might result in more data being loaded.",
                ),
              ],
            ),
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdToggle(
                  checked: _enableGrouping,
                  label: "Enable grouping (by passing the groupingCriterion parameter and a seperatorBuilder)",
                  onChanged: (value) {
                    setState(() {
                      _enableGrouping = value;
                    });
                  },
                ),
              ],
            ),
          ),
          LdBundle(children: []),
          ldSpacerM,
          const LdDivider(),
          ldSpacerM,
          LdText.h("LdPaginator.fromList"),
          LdList(
            shrinkWrap: true,
            paginator: LdPaginator.fromList(_demoItems),
            itemBuilder: (context, item, index) {
              return LdListItem(
                leading: LdAvatar(child: Text(item.value.name)),
                title: Text(item.value.name),
                subtitle: Text(item.value.category),
              );
            },
          ),
          LdText.h("Empty state LdListEmpty()"),
          ldSpacerM,
          SizedBox(
            height: 200,
            child: LdCard(
              expandChild: true,
              child: LdListEmpty(
                onRefresh: () {
                  LdNotificationsController.of(
                    context,
                  ).addNotification(LdNotification(message: "Refreshed", type: LdNotificationType.success));
                },
              ),
            ),
          ),
          ldSpacerM,
          LdText.h("LdListSeperator()"),
          ldSpacerM,
          const LdListSeperator(child: Text("This is a separator")),
          ldSpacerM,
          const Text("Loading state LdListLoading()"),
          ldSpacerM,
          const LdCard(padding: EdgeInsets.zero, child: LdListItemLoading(hasLeading: true, hasTrailing: true)),
        ],
      ),
    );
  }
}

class _DemoItem with Identifiable<int> {
  @override
  int get id => _id;

  final int _id;

  final String name;

  final String category;

  _DemoItem(this._id, this.name, this.category);
}

final List<_DemoItem> _demoItems = [
  _DemoItem(1, "Apples", "Fruits"),
  _DemoItem(2, "Bananas", "Fruits"),
  _DemoItem(3, "Oranges", "Fruits"),
  _DemoItem(4, "Carrots", "Vegetables"),
  _DemoItem(5, "Broccoli", "Vegetables"),
  _DemoItem(6, "Spinach", "Vegetables"),
  _DemoItem(7, "Chicken", "Meat"),
  _DemoItem(8, "Beef", "Meat"),
  _DemoItem(9, "Pork", "Meat"),
  _DemoItem(10, "Milk", "Dairy"),
  _DemoItem(11, "Cheese", "Dairy"),
  _DemoItem(12, "Yogurt", "Dairy"),
  _DemoItem(13, "Bread", "Bakery"),
  _DemoItem(14, "Croissants", "Bakery"),
  _DemoItem(15, "Bagels", "Bakery"),
  _DemoItem(16, "Strawberries", "Fruits"),
  _DemoItem(17, "Blueberries", "Fruits"),
  _DemoItem(18, "Grapes", "Fruits"),
  _DemoItem(19, "Potatoes", "Vegetables"),
  _DemoItem(20, "Tomatoes", "Vegetables"),
  _DemoItem(21, "Cucumber", "Vegetables"),
  _DemoItem(22, "Turkey", "Meat"),
  _DemoItem(23, "Lamb", "Meat"),
  _DemoItem(24, "Salmon", "Seafood"),
  _DemoItem(25, "Tuna", "Seafood"),
  _DemoItem(26, "Shrimp", "Seafood"),
  _DemoItem(27, "Butter", "Dairy"),
  _DemoItem(28, "Cream", "Dairy"),
  _DemoItem(29, "Sour Cream", "Dairy"),
  _DemoItem(30, "Muffins", "Bakery"),
  _DemoItem(31, "Donuts", "Bakery"),
  _DemoItem(32, "Cookies", "Bakery"),
  _DemoItem(33, "Cereal", "Breakfast"),
  _DemoItem(34, "Oatmeal", "Breakfast"),
  _DemoItem(35, "Granola", "Breakfast"),
];
