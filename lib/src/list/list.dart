import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/list_error.dart';

class _ListItem<T, SeperationCriterion> {
  _ListItem({
    this.item,
    this.isSeparator = false,
    this.seperationCriterion,
  });
  final T? item;
  // use a bool since T or SeperationCriterion can be null
  final bool isSeparator;
  final SeperationCriterion? seperationCriterion;
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
  bool get _enableBidirectionalScrolling =>
      enableBidirectionalScrolling ?? data.startPage > 0;
  final double topScrollThreshold;

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
    this.topScrollThreshold = 50.0,
  });

  @override
  State<LdList<T, GroupingCriterion>> createState() =>
      _LdListState<T, GroupingCriterion>();
}

class _LdListState<T, GroupingCriterion>
    extends State<LdList<T, GroupingCriterion>> {
  // Holds the items that are currently displayed in the list
  List<_ListItem<T, GroupingCriterion>> _groupedItems = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingPrevious = false;

  final topLoadingKey = GlobalKey();
  final bottomLoadingKey = GlobalKey();

  // Re-group the items in the list
  List<_ListItem<T, GroupingCriterion>> _groupItemsSequentially() {
    final groupedItems = List<_ListItem<T, GroupingCriterion>>.empty(
      growable: true,
    );

    GroupingCriterion? lastSeperationCriterion;

    for (final item in widget.data.currentList) {
      final seperationCriterion = widget.groupingCriterion!(item);
      if (lastSeperationCriterion != seperationCriterion) {
        groupedItems.add(
          _ListItem(
            isSeparator: true,
            seperationCriterion: seperationCriterion,
          ),
        );
        lastSeperationCriterion = seperationCriterion;
      }
      groupedItems.add(_ListItem(item: item));
    }

    return groupedItems;
  }

  List<_ListItem<T, GroupingCriterion>> _groupItemsUniformly() {
    final Map<GroupingCriterion, List<T>> groupedItems = {};

    for (final item in widget.data.currentList) {
      final seperationCriterion = widget.groupingCriterion!(item);
      if (!groupedItems.containsKey(seperationCriterion)) {
        groupedItems[seperationCriterion] = [];
      }
      groupedItems[seperationCriterion]!.add(item);
    }

    return groupedItems.entries
        .map((entry) => [
              _ListItem<T, GroupingCriterion>(
                isSeparator: true,
                seperationCriterion: entry.key,
              ),
              ...entry.value
                  .map((item) => _ListItem<T, GroupingCriterion>(item: item))
            ])
        .expand((element) => element)
        .toList(growable: false);
  }

  @override
  void initState() {
    widget.data.addListener(_onDataChange);
    _onDataChange();
    _initBidirectionalScrolling();
    super.initState();
  }

  /// Initialize bidirectional scrolling if enabled
  /// Returns true if bidirectional scrolling is enabled
  bool _initBidirectionalScrolling() {
    if (widget._enableBidirectionalScrolling) {
      _scrollController.addListener(_scrollListener);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.pixels <= widget.topScrollThreshold &&
            widget.data.hasMoreDataPrev) {
          _loadPreviousPage(forceScrollUp: true);
        }
      });
    }
    return widget._enableBidirectionalScrolling;
  }

  void _scrollListener() {
    if (!widget._enableBidirectionalScrolling ||
        widget.data.busy ||
        _isLoadingPrevious) {
      return;
    }

    final topThreshold =
        (widget.assumedItemHeight ?? 0) * widget.data.remainingItemsAbove +
            widget.topScrollThreshold;

    // Check if we're at the top and need to load previous
    if (_scrollController.position.pixels <= topThreshold &&
        widget.data.hasMoreDataPrev) {
      _loadPreviousPage();
    }
  }

  Future<void> _loadPreviousPage({forceScrollUp = false}) async {
    if (_isLoadingPrevious) return;

    setState(() {
      _isLoadingPrevious = true;
    });

    // Save the current list before prepending
    final previousList = List.from(widget.data.currentList);

    // Load previous page data
    await widget.data.previousPage();

    final scrollUp = widget.assumedItemHeight == null &&
        widget.data.currentList.length - previousList.length > 0;
    print('Scroll up: $scrollUp, force: $forceScrollUp');

    if (forceScrollUp || scrollUp) {
      // If the list has changed, we scroll a bit up to make the transition
      // smoother (otherwise the user would be directly at the top of the list
      // and expect another load to happen)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollUp();
      });
    }

    setState(() {
      _isLoadingPrevious = false;
    });
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }
    print('Scrolling up');

    final jumpOffsetItemCount = widget.assumedItemHeight != null
        ? widget.data.remainingItemsAbove
        : widget.header != null
            ? 2
            : 1;
    final jumpOffset = max(
        jumpOffsetItemCount * (widget.assumedItemHeight ?? 50.0),
        widget.topScrollThreshold * 2);

    // reset scroll controller velocity
    _scrollController.position
        .jumpTo(_scrollController.position.pixels + jumpOffset);
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
    }

    if (widget._enableBidirectionalScrolling !=
        oldWidget._enableBidirectionalScrolling) {
      if (!_initBidirectionalScrolling()) {
        _scrollController.removeListener(_scrollListener);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.data.removeListener(_onDataChange);
    _scrollController.removeListener(_scrollListener);
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
                widget.data.currentList
                    .map((item) => _ListItem<T, GroupingCriterion>(item: item)))
            .toList(growable: false);
      });
    } else {
      setState(() {
        _groupedItems = widget.data.currentList
            .map((item) => _ListItem<T, GroupingCriterion>(item: item))
            .toList(growable: false);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Force a layout rebuild and position recalculation
        _scrollController.position.didUpdateScrollPositionBy(0.0);

        // Optional: Trigger a minimal jump to force position adjustment
        _scrollController.jumpTo(_scrollController.position.pixels);
      }
    });
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

  Widget _buildLoadMore(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(
        context,
        widget.data.currentPage,
        widget.data.currentList.length,
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
        widget.data.hasMoreDataNext || widget.data.busy;
    final showPrevLoadingIndicator = widget._enableBidirectionalScrolling &&
        (widget.data.hasMoreDataPrev || _isLoadingPrevious);

    int count = _groupedItems.length;

    if (widget.data.hasError) {
      return _buildError(widget.data.error!);
    }

    if (widget.data.currentList.isEmpty && !widget.data.busy) {
      return _buildEmpty(context);
    }

    final list = CustomScrollView(
      controller: _scrollController,
      primary: widget.primary,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ??
          (widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics()),
      slivers: [
        if (widget.header != null)
          SliverToBoxAdapter(
            child: widget.header!,
          ),
        if (showPrevLoadingIndicator)
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (widget.assumedItemHeight != null)
                  SizedBox(
                    height: widget.data.remainingItemsAbove *
                        widget.assumedItemHeight!,
                  ),
                KeyedSubtree(
                  key: topLoadingKey,
                  child: _buildLoadMore(context),
                ),
              ],
            ),
          ),
        SliverList.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            final item = _groupedItems[index];

            if (index == count - 1 && showNextLoadingIndicator) {
              widget.data.nextPage();
            }

            if (item.isSeparator) {
              return widget.seperatorBuilder!(
                context,
                item.seperationCriterion as GroupingCriterion,
              );
            }

            return widget.itemBuilder(context, item.item as T, index);
          },
        ),
        if (showNextLoadingIndicator)
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildLoadMore(context),
                if (widget.assumedItemHeight != null)
                  SizedBox(
                    height: widget.data.remainingItemsBelow *
                        widget.assumedItemHeight!,
                  )
              ],
            ),
          ),
        if (widget.footer != null)
          SliverToBoxAdapter(
            child: widget.footer!,
          ),
      ],
    );

    return RefreshIndicator.adaptive(
      onRefresh: widget.data.refreshList,
      child: list,
    );
  }
}
