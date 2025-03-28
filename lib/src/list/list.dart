import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _ListItem<T, SeperationCriterion> {
  _ListItem({
    this.item,
    this.isSeparator = false,
    this.seperationCriterion,
    this.page,
  }) :
        // if this is no separator, page should not be null
        assert(isSeparator || page != null);

  final T? item;
  // use a bool since T or SeperationCriterion can be null
  final bool isSeparator;
  final SeperationCriterion? seperationCriterion;

  /// The page number that this item belongs to.
  /// It can be that item is null and page is not null, which means that this
  /// item is yet to be loaded from the appropriate page.
  /// If both item and page are null, this is probably a separator item.
  final int? page;
}

/// An extension function to create a list of [_ListItem]s from a [LdPaginator]
/// instance.
///
///
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

  final LdRetryConfig? retryConfig;

  // Bidirectional scrolling properties
  final bool? enableBidirectionalScrolling;
  bool get isBidirectionalScrollingEnabled =>
      enableBidirectionalScrolling ?? data.startPage > 0;

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

  Widget _buildLoadMore(BuildContext context, int page) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(
        context,
        page,
        widget.data.currentItemCount,
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
            final page = item.page;

            if (item.isSeparator) {
              return widget.seperatorBuilder!(
                context,
                item.seperationCriterion as GroupingCriterion,
              );
            }

            if (item.item == null) {
              // if item is null and this is no separator, this is a "placeholder"
              // item and we have to fetch the data for the appropriate page
              // (page should never be null at this point)
              if (assumedItemHeight == null || page == null) {
                // as long as we don't know any assumed item height (neither
                // as parameter nor calculated), we can't build a "placeholder"
                return const SizedBox.shrink();
              }
              // call the loading operation for the appropriate page
              widget.data.jumpToPage(page);

              // build a "placeholder" item
              return SizedBox(
                height: assumedItemHeight!,
                child: _buildLoadMore(context, page),
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
        calculatedAssumedItemHeight = renderBox.size.height;
        setState(() {});
      }
    });
  }

  /// Helper method to perform the initial scroll to the correct position
  /// based on the current page.
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
      _scrollToIndex(widget.data.startPage * widget.data.pageSize);
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
