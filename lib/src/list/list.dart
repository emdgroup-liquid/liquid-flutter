import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/list_error.dart';
import 'package:liquid_flutter/src/list/position_retained_scroll_physics.dart';

class _ListItem<T, SeperationCriterion> {
  _ListItem({
    this.item,
    this.isSeparator = false,
    this.seperationCriterion,
    this.page,
  });
  final T? item;
  // use a bool since T or SeperationCriterion can be null
  final bool isSeparator;
  final SeperationCriterion? seperationCriterion;

  /// The page this item belongs to
  final int? page;
}

extension GetItemList<T> on LdPaginator<T> {
  List<_ListItem<T, GroupingCriterion>> currentList<GroupingCriterion>() {
    final result = <_ListItem<T, GroupingCriterion>>[];
    for (int i = 0; i < totalItems ~/ pageSize; i++) {
      final page = pages[i];
      if (page != null) {
        result.addAll(page.newItems
            .map((item) => _ListItem<T, GroupingCriterion>(item: item, page: i))
            .toList());
      } else {
        result.addAll(List<_ListItem<T, GroupingCriterion>>.filled(
          pageSize,
          _ListItem<T, GroupingCriterion>(page: i),
        ));
      }
    }
    return result;
  }
}

class LdList<T, GroupingCriterion> extends StatefulWidget {
  // Builders
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  final Widget Function(BuildContext context, Future<void> Function() refresh)?
      emptyBuilder;

  final Widget Function(
      BuildContext context, Object? error, VoidCallback retry)? errorBuilder;

  final double? assumedItemHeight;

  // Pagination
  final LdPaginator<T> data;

  final Widget Function(BuildContext context, int currentPage, int totalItems)?
      loadingBuilder;

  final bool Function(T a, T b)? areEqual;

  // Grouping
  final GroupingCriterion Function(T item)? groupingCriterion;

  final Widget Function(BuildContext context, GroupingCriterion criterion)?
      seperatorBuilder;

  final bool groupSequentialItems;

  final bool shrinkWrap;

  final ScrollPhysics? physics;

  final Widget? header;

  final bool primary;

  final Widget? footer;

  // Bidirectional scrolling properties
  final bool? enableBidirectionalScrolling;
  bool get isBidirectionalScrollingEnabled =>
      enableBidirectionalScrolling ?? data.startPage > 0;

  /// Whether or not each missing item (i.e. items of a page that is not loaded
  /// yet) should be shown as a loading indicator.
  /// This is automatically set to true if [assumedItemHeight] is not null.
  bool get showMissingItemsAsLoading => assumedItemHeight != null;

  const LdList({
    super.key,
    this.areEqual,
    this.emptyBuilder,
    this.errorBuilder,
    this.header,
    this.loadingBuilder,
    this.assumedItemHeight,
    this.physics,
    required this.itemBuilder,
    required this.data,
    this.seperatorBuilder,
    this.groupingCriterion,
    this.primary = false,
    this.footer,
    this.groupSequentialItems = false,
    this.shrinkWrap = false,
    this.enableBidirectionalScrolling,
  });

  @override
  State<LdList<T, GroupingCriterion>> createState() =>
      _LdListState<T, GroupingCriterion>();
}

class _LdListState<T, GroupingCriterion>
    extends State<LdList<T, GroupingCriterion>> {
  // Holds the items that are currently displayed in the list
  List<_ListItem<T, GroupingCriterion>> _groupedItems = [];
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: false);
  bool _initialScrollPerformed = false;

  // Re-group the items in the list
  List<_ListItem<T, GroupingCriterion>> _groupItemsSequentially() {
    final groupedItems = List<_ListItem<T, GroupingCriterion>>.empty(
      growable: true,
    );

    GroupingCriterion? lastSeperationCriterion;

    for (final item in widget.data.currentList<GroupingCriterion>()) {
      if (item.item == null) {
        groupedItems.add(_ListItem<T, GroupingCriterion>(page: item.page));
        continue;
      }
      final seperationCriterion = widget.groupingCriterion!(item.item!);
      if (lastSeperationCriterion != seperationCriterion) {
        groupedItems.add(
          _ListItem(
            isSeparator: true,
            seperationCriterion: seperationCriterion,
          ),
        );
        lastSeperationCriterion = seperationCriterion;
      }
      groupedItems.add(item);
    }

    return groupedItems;
  }

  List<_ListItem<T, GroupingCriterion>> _groupItemsUniformly() {
    final Map<GroupingCriterion, List<T>> groupedItems = {};

    final emptyItems = <_ListItem<T, GroupingCriterion>>[];
    for (final item in widget.data.currentList<GroupingCriterion>()) {
      if (item.item == null) {
        emptyItems.add(_ListItem<T, GroupingCriterion>(page: item.page));
        continue;
      }
      final seperationCriterion = widget.groupingCriterion!(item.item!);
      if (!groupedItems.containsKey(seperationCriterion)) {
        groupedItems[seperationCriterion] = [];
      }
      groupedItems[seperationCriterion]!.add(item.item!);
    }

    return [
      ...groupedItems.entries
          .map((entry) => [
                _ListItem<T, GroupingCriterion>(
                  isSeparator: true,
                  seperationCriterion: entry.key,
                ),
                ...entry.value
                    .map((item) => _ListItem<T, GroupingCriterion>(item: item))
              ])
          .expand((element) => element)
          .toList(growable: false),
      ...emptyItems
    ].toList(growable: false);
  }

  @override
  void initState() {
    widget.data.addListener(_onDataChange);
    _onDataChange();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LdList<T, GroupingCriterion> oldWidget) {
    if (oldWidget.groupingCriterion != widget.groupingCriterion ||
        widget.data != oldWidget.data) {
      _onDataChange();
    }

    if (widget.data != oldWidget.data) {
      oldWidget.data.removeListener(_onDataChange);
      widget.data.addListener(_onDataChange);
      _initialScrollPerformed = false;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.data.removeListener(_onDataChange);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onDataChange() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    if (widget.seperatorBuilder != null && widget.groupingCriterion != null) {
      if (widget.groupSequentialItems) {
        setState(() {
          _groupedItems = _groupItemsSequentially();
        });
      } else {
        setState(() {
          _groupedItems = _groupItemsUniformly();
        });
      }
    } else if (widget.groupingCriterion == null &&
        widget.seperatorBuilder != null) {
      setState(() {
        _groupedItems = intersperse(
            _ListItem<T, GroupingCriterion>(isSeparator: true),
            widget.data
                .currentList<GroupingCriterion>()
                .map((item) => item)).toList(growable: false);
      });
    } else {
      setState(() {
        _groupedItems = widget.data
            .currentList<GroupingCriterion>()
            .map((item) => item)
            .toList(growable: false);
      });
    }
    _maybePerformInitialScroll();
  }

  Future<void> _onRefresh() async {
    await widget.data.refreshList();
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context, _onRefresh);
    }

    return LdListEmpty(onRefresh: _onRefresh);
  }

  Widget _buildLoadMore(BuildContext context, {bool isTop = false}) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(
        context,
        isTop ? widget.data.currentTopPage : widget.data.currentBottomPage,
        widget.data.currentItemCount,
      );
    }

    return const LdListItemLoading();
  }

  Widget _buildError(Object error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, _onRefresh);
    }

    return LdListError(error: error, onRefresh: _onRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final showNextLoadingIndicator =
        !widget.showMissingItemsAsLoading && (widget.data.hasMoreDataNext);
    final showPrevLoadingIndicator = !widget.showMissingItemsAsLoading &&
        widget.isBidirectionalScrollingEnabled &&
        widget.data.hasMoreDataPrev;
    int count = _groupedItems.length +
        (showPrevLoadingIndicator ? 1 : 0) +
        (showNextLoadingIndicator ? 1 : 0);

    if (widget.data.hasError) {
      return _buildError(widget.data.error!);
    }

    if (widget.data.currentItemCount == 0 && !widget.data.busy) {
      return _buildEmpty(context);
    }

    // If we are showing missing items as loading, we don't have to "hack" with
    // the physics to retain the position. Additionally, if we are grouping
    // items, the [PositionRetainedScrollPhysics] will also be glitchy.
    final useRetainedScrollPhysics = widget.isBidirectionalScrollingEnabled &&
        !widget.showMissingItemsAsLoading &&
        widget.groupingCriterion == null;
    final list = CustomScrollView(
      controller: _scrollController,
      primary: widget.primary,
      shrinkWrap: widget.shrinkWrap,
      physics: PositionRetainedScrollPhysics(
        shouldRetain: useRetainedScrollPhysics,
        parent: widget.physics ??
            (widget.shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics()),
      ),
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        SliverList.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            if (showPrevLoadingIndicator && index == 0) {
              widget.data.previousPage();
              return _buildLoadMore(context, isTop: true);
            }

            if (showNextLoadingIndicator && index == count - 1) {
              widget.data.nextPage();
              return _buildLoadMore(context, isTop: false);
            }

            index -= showPrevLoadingIndicator ? 1 : 0;
            final item = _groupedItems[index];
            final page = item.page;

            if (item.isSeparator) {
              return widget.seperatorBuilder!(
                context,
                item.seperationCriterion as GroupingCriterion,
              );
            }

            if (item.item == null) {
              // This is a "placeholder" item (a page that is not loaded yet)
              if (widget.assumedItemHeight == null) {
                // If we don't know the item height, there are no "placeholder"
                // UI elements
                return const SizedBox.shrink();
              }
              if (page != null) {
                widget.data.jumpToPage(page); // call the loading operation
              }
              // build a "placeholder" item
              return SizedBox.fromSize(
                size: Size.fromHeight(widget.assumedItemHeight!),
                child: _buildLoadMore(context),
              );
            }
            return widget.itemBuilder(context, item.item!, index);
          },
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer!),
      ],
    );

    return RefreshIndicator.adaptive(
      onRefresh: widget.data.refreshList,
      child: list,
    );
  }

  void _maybePerformInitialScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // we don't need to perform the initial scroll under certain conditions
      if (_initialScrollPerformed ||
          !_scrollController.hasClients ||
          !mounted ||
          !widget.isBidirectionalScrollingEnabled ||
          !widget.showMissingItemsAsLoading) {
        return;
      }
      _initialScrollPerformed = true;
      if (widget.isBidirectionalScrollingEnabled) {
        _scrollToIndex(widget.data.startPage * widget.data.pageSize);
      }
    });
  }

  /// Scroll to a specific index in the list based on the item index
  /// As ListView doesn't have a built-in method to scroll to a certain item,
  /// we have to estimate the position based on the item index and the assumed
  /// item height.
  _scrollToIndex(int index) {
    index += (widget.header != null ? 1 : 0);
    final double pixels = index * (widget.assumedItemHeight ?? 50);
    _scrollController.jumpTo(pixels);
  }
}
