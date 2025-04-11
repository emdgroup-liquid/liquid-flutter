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

  Future<LdListPage<int>> _fetchItems({
    required int offset,
    required int pageSize,
    String? pageToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

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

  @override
  Widget build(BuildContext context) {
    return LdList<int, int>(
      data: _paginator,
      groupingCriterion: (item) => (item - 1) ~/ 10,
      separatorBuilder: (context, remainder) => LdListSeperator(
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
      loadingBuilder: (context, position, totalItems) => LdListItemLoading(
        hasSubContent: false,
      ),
    );
  }
}
