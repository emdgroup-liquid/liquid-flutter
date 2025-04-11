import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _ListItem<T, SeparationCriterion> {
  _ListItem({
    this.item,
    this.isSeparator = false,
    this.separationCriterion,
    this.position,
  }) :
        // if this is not a separator, position should not be null
        assert(isSeparator || position != null);

  final T? item;
  // use a bool since T or SeparationCriterion can be null
  final bool isSeparator;
  final SeparationCriterion? separationCriterion;

  /// The position that this item belongs to.
  /// It can be that item is null and position is not null, which means that this
  /// item is yet to be loaded from the appropriate position.
  /// If both item and position are null, this is probably a separator item.
  final int? position;
}

/// An extension function to create a list of [_ListItem]s from a [LdPaginator]
/// instance.
extension GetItemList<T> on LdPaginator<T> {
  List<_ListItem<T, GroupingCriterion>> currentList<GroupingCriterion>() {
    final result = <_ListItem<T, GroupingCriterion>>[];
    if (totalItems == 0) return result;

    // Iterate through all positions up to totalItems
    for (int i = 0; i < totalItems; i++) {
      final item = getItemAt(i);
      if (item != null) {
        result.add(_ListItem<T, GroupingCriterion>(item: item, position: i));
      } else {
        // This is a placeholder for an item that hasn't been loaded yet
        result.add(_ListItem<T, GroupingCriterion>(position: i));
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

  final Widget Function(BuildContext context, int position, int totalItems)?
      loadingBuilder;

  final bool Function(T a, T b)? areEqual;

  // Grouping
  final GroupingCriterion Function(T item)? groupingCriterion;

  final Widget Function(BuildContext context, GroupingCriterion criterion)?
      separatorBuilder;

  final bool groupSequentialItems;

  final bool shrinkWrap;

  final ScrollPhysics? physics;

  final Widget? header;

  final bool primary;

  final Widget? footer;

  final LdRetryConfig? retryConfig;

  // Bidirectional scrolling properties
  final bool? enableBidirectionalScrolling;
  bool get isBidirectionalScrollingEnabled =>
      enableBidirectionalScrolling ?? data.initialOffset > 0;

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
    this.separatorBuilder,
    this.groupingCriterion,
    this.primary = false,
    this.footer,
    this.groupSequentialItems = false,
    this.shrinkWrap = false,
    this.enableBidirectionalScrolling,
    this.retryConfig,
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
  bool _initialScrollPerformed = false;
  double? calculatedAssumedItemHeight;
  GlobalKey? _firstListItemWidgetKey;

  /// We either provide an assumed item height as a parameter or we calculate
  /// it after the first items have been loaded.
  double? get assumedItemHeight =>
      widget.assumedItemHeight ?? calculatedAssumedItemHeight;

  late final LdRetryController _retryController;

  // Re-group the items in the list
  List<_ListItem<T, GroupingCriterion>> _groupItemsSequentially() {
    final groupedItems = List<_ListItem<T, GroupingCriterion>>.empty(
      growable: true,
    );

    GroupingCriterion? lastSeparationCriterion;

    for (final item in widget.data.currentList<GroupingCriterion>()) {
      if (item.item == null) {
        groupedItems
            .add(_ListItem<T, GroupingCriterion>(position: item.position));
        continue;
      }
      final separationCriterion = widget.groupingCriterion!(item.item!);
      if (lastSeparationCriterion != separationCriterion) {
        groupedItems.add(
          _ListItem(
            isSeparator: true,
            separationCriterion: separationCriterion,
          ),
        );
        lastSeparationCriterion = separationCriterion;
      }
      groupedItems.add(item);
    }

    return groupedItems;
  }

  List<_ListItem<T, GroupingCriterion>> _groupItemsUniformly() {
    final Map<GroupingCriterion, List<_ListItem<T, GroupingCriterion>>>
        groupedItems = {};

    final emptyItems = <_ListItem<T, GroupingCriterion>>[];
    GroupingCriterion? lastSeparationCriterion;
    for (final item in widget.data.currentList<GroupingCriterion>()) {
      if (item.item == null) {
        final placeholder =
            _ListItem<T, GroupingCriterion>(position: item.position);
        if (lastSeparationCriterion != null) {
          // if we can't know the separation criterion, let's just add the
          // placeholder to the last group
          groupedItems[lastSeparationCriterion]!.add(placeholder);
        } else {
          emptyItems.add(placeholder);
        }
        continue;
      }
      final separationCriterion = widget.groupingCriterion!(item.item!);
      if (!groupedItems.containsKey(separationCriterion)) {
        groupedItems[separationCriterion] = [];
      }
      groupedItems[separationCriterion]!.add(
        _ListItem(
          item: item.item,
          position: item.position,
        ),
      );
      lastSeparationCriterion = separationCriterion;
    }

    return [
      ...emptyItems,
      ...groupedItems.entries
          .map((entry) => [
                _ListItem<T, GroupingCriterion>(
                  isSeparator: true,
                  separationCriterion: entry.key,
                ),
                ...entry.value,
              ])
          .expand((element) => element)
          .toList(growable: false),
    ].toList(growable: false);
  }

  @override
  void initState() {
    this._retryController = LdRetryController(
      onRetry: _onRefresh,
      config: widget.retryConfig ?? LdRetryConfig.unlimitedManualRetries(),
    );
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
    _retryController.dispose();
    widget.data.removeListener(_onDataChange);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onDataChange() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    if (widget.data.busy) {
      _retryController.notifyOperationStarted();
    } else if (widget.data.hasError) {
      _retryController.handleError(canRetry: true);
    } else {
      _retryController.notifyOperationCompleted();
    }

    if (widget.separatorBuilder != null && widget.groupingCriterion != null) {
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
        widget.separatorBuilder != null) {
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
    _maybeCalculateAssumedItemHeight();
    _maybePerformInitialScroll();
  }

  Future<void> _onRefresh() async {
    _retryController.notifyOperationStarted();
    await widget.data.refreshList();
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context, _onRefresh);
    }

    return LdListEmpty(onRefresh: _onRefresh);
  }

  Widget _buildLoadMore(BuildContext context, int position) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(
        context,
        position,
        widget.data.totalItems,
      );
    }

    return const LdListItemLoading();
  }

  Widget _buildError(Object error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, _onRefresh);
    }

    // return the default error view (LdExceptionView)
    return Center(
      child: LdExceptionView.fromDynamic(
        error,
        context,
        direction: Axis.vertical,
        retryController: _retryController,
      ),
    ).padL();
  }

  @override
  Widget build(BuildContext context) {
    int count = _groupedItems.length;

    if (widget.data.hasError) {
      return _buildError(widget.data.error!);
    }

    if (widget.data.currentItemCount == 0 && !widget.data.busy) {
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
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),

        // if there is nothing to show yet, just show a simple loading indicator:
        if (widget.data.currentItemCount == 0)
          SliverToBoxAdapter(child: _buildLoadMore(context, -1)),

        SliverList.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            final item = _groupedItems[index];
            final position = item.position;

            if (item.isSeparator) {
              return widget.separatorBuilder!(
                context,
                item.separationCriterion as GroupingCriterion,
              );
            }

            if (item.item == null) {
              // if item is null and this is no separator, this is a "placeholder"
              // item and we have to fetch the data for the appropriate position
              if (assumedItemHeight == null || position == null) {
                // as long as we don't know any assumed item height (neither
                // as parameter nor calculated), we can't build a "placeholder"
                return const SizedBox.shrink();
              }
              // call the loading operation for the appropriate position
              widget.data.fetchPageAtOffset(position);

              // build a "placeholder" item
              return SizedBox(
                height: assumedItemHeight!,
                child: _buildLoadMore(context, position),
              );
            }

            bool buildingFirstRealItem = _firstListItemWidgetKey == null;
            _firstListItemWidgetKey ??= GlobalKey();
            return KeyedSubtree(
              key: buildingFirstRealItem ? _firstListItemWidgetKey : null,
              child: widget.itemBuilder(context, item.item!, index),
            );
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

  /// Helper method to calculate the assumed item height based on the current
  /// scroll extent and the current item count.
  void _maybeCalculateAssumedItemHeight() {
    if (calculatedAssumedItemHeight != null ||
        widget.data.currentItemCount == 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _firstListItemWidgetKey?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // assume that the first item has the same height as all other items
        calculatedAssumedItemHeight = max(50, renderBox.size.height);
        setState(() {});
      }
    });
  }

  /// Helper method to perform the initial scroll to the correct position
  /// based on the initial offset.
  void _maybePerformInitialScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // we don't need to perform the initial scroll under certain conditions
      if (_initialScrollPerformed ||
          !_scrollController.hasClients ||
          !mounted ||
          !widget.isBidirectionalScrollingEnabled ||
          assumedItemHeight == null ||
          _groupedItems.isEmpty) {
        return;
      }
      _initialScrollPerformed = true;
      _scrollToIndex(widget.data.initialOffset);
    });
  }

  /// Scroll to a specific index in the list based on the item index
  /// As ListView doesn't have a built-in method to scroll to a certain item,
  /// we have to estimate the position based on the item index and the assumed
  /// item height.
  _scrollToIndex(int index) {
    index += (widget.header != null ? 1 : 0);
    final double pixels = index * assumedItemHeight!;
    _scrollController.jumpTo(pixels);
  }
}
