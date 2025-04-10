import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ListFullScreen extends StatefulWidget {
  const ListFullScreen({super.key});

  @override
  State<ListFullScreen> createState() => _ListFullScreenState();
}

class _ListFullScreenState extends State<ListFullScreen> {
  late final LdPaginator<int> _paginator = LdPaginator<int>(
    fetchListFunction: _fetchItems,
  );

  Future<LdListPage<int>> _fetchItems(
    int page,
    int loadedItems,
    String? nextPageToken,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (loadedItems == 100) {
      return LdListPage<int>(newItems: [], hasMore: false, total: 100);
    }
    return LdListPage<int>(
        newItems: List.generate(10, (index) => loadedItems + index),
        hasMore: true,
        total: 100);
  }

  @override
  Widget build(BuildContext context) {
    return LdList<int, int>(
      data: _paginator,
      groupingCriterion: (item) => (item - 1) ~/ 10,
      seperatorBuilder: (context, remainder) => LdListSeperator(
        onSurface: false,
        child: Text("Group $remainder"),
      ),
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
    );
  }
}
