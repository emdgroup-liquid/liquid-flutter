import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/intersperse.dart';

/// A model class representing an item in the list.

enum _ListItemType {
  item,
  separator,
  groupHeader,
}

class _ListItem<T, SeparationCriterion> {
  _ListItem({
    this.item,
    required this.type,
    this.separationCriterion,
    this.position,
  }) : assert(
          !(type == _ListItemType.item && position == null),
          "Items must have a position",
        );

  final T? item;
  final _ListItemType type;
  final SeparationCriterion? separationCriterion;

  /// The position that this item belongs to.
  /// Can be null for separator items.
  /// For regular items:
  /// - If item is null but position is not, the item is yet to be loaded
  /// - If both item and position are null, it's likely a separator
  final int? position;
}

/// Extension to convert [LdPaginator] data into a list of [_ListItem]s
extension GetItemList<T> on LdPaginator<T> {
  List<_ListItem<T, GroupingCriterion>> currentList<GroupingCriterion>() {
    final result = <_ListItem<T, GroupingCriterion>>[];
    if (totalItems == 0) return result;

    for (int i = 0; i < totalItems; i++) {
      final item = getItemAt(i);
      result.add(_ListItem<T, GroupingCriterion>(
        item: item,
        position: i,
        type: _ListItemType.item,
      ));
    }

    return result;
  }
}

typedef LdListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// A sophisticated list widget that supports:
/// - Pagination with loading indicators
/// - Item grouping with custom separators
/// - Bidirectional scrolling
/// - Error handling and retry mechanisms
/// - Pull-to-refresh functionality
/// - Empty state handling
class LdList<T, GroupingCriterion> extends StatefulWidget {
  const LdList({
    super.key,
    this.scrollController,
    this.areEqual,
    this.emptyBuilder,
    this.errorBuilder,
    this.header,
    this.loadingBuilder,
    this.assumedItemHeight,
    this.physics,
    required this.itemBuilder,
    required this.paginator,
    this.groupHeaderBuilder,
    this.groupingCriterion,
    this.separatorBuilder,
    this.primary = false,
    this.footer,
    this.shrinkWrap = false,
    this.retryConfig,
  });

  /// Function that builds a [T] in the list.
  final LdListItemBuilder<T> itemBuilder;

  /// Built when there are no items call [refresh] to trigger [paginator]'s refresh
  /// function
  final Widget Function(
    BuildContext context,
    Future<void> Function() refresh,
  )? emptyBuilder;

  /// Built when an error occurs while loading data [error] is the error that
  /// occurred and [retry] is a callback to retry the operation.
  final Widget Function(
    BuildContext context,
    Object? error,
    VoidCallback retry,
  )? errorBuilder;

  /// Built when there are missing items that are being loaded
  final Widget Function(BuildContext context, int position, int totalItems)? loadingBuilder;

  // Grouping configuration
  final GroupingCriterion Function(T item)? groupingCriterion;
  final Widget Function(BuildContext context, GroupingCriterion criterion)? groupHeaderBuilder;

  /// Built between items. Not called between items and group headers.
  final Widget Function(BuildContext context)? separatorBuilder;

  /// The paginator to use
  final LdPaginator<T> paginator;

  /// The scroll controller to use.
  /// If not provided, the list will use the primary scroll controller if [primary] is true.
  /// Otherwise, it will create a new scroll controller.
  final ScrollController? scrollController;

  /// The assumed height of an item. Is used to calculate the scroll space
  /// to virtually allocate for items that are not yet loaded.
  final double? assumedItemHeight;

  /// Function that checks if two items are equal.
  final bool Function(T a, T b)? areEqual;

  /// Whether the list should be wrapped in a shrink-wrap container.
  final bool shrinkWrap;

  /// The physics of the list.
  final ScrollPhysics? physics;

  /// Whether the list is the primary scroll view of the screen.
  final bool primary;

  /// A widget that is displayed at the top of the list.
  final Widget? header;

  /// A widget that is displayed at the bottom of the list.
  final Widget? footer;

  // Error handling
  final LdRetryConfig? retryConfig;

  @override
  State<LdList<T, GroupingCriterion>> createState() => _LdListState<T, GroupingCriterion>();
}

class _LdListState<T, GroupingCriterion> extends State<LdList<T, GroupingCriterion>> {
  // State variables
  List<_ListItem<T, GroupingCriterion>> _groupedItems = [];
  late final ScrollController _scrollController;

  GlobalKey? _assumeItemKey;

  late final LdRetryController _retryController;

  double? get _effectiveAssumedHeight => widget.assumedItemHeight ?? calculatedItemHeight;

  double? get calculatedItemHeight {
    if (_assumeItemKey == null) return null;

    return _assumeItemKey?.currentContext?.size?.height;
  }

  @override
  void initState() {
    super.initState();

    double initialOffset = 0;

    if (widget.assumedItemHeight != null && widget.paginator.initialOffset != 0) {
      initialOffset = widget.paginator.initialOffset * widget.assumedItemHeight!;
    }

    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else if (widget.primary) {
      _scrollController = PrimaryScrollController.of(context);
    } else {
      _scrollController = ScrollController(
        initialScrollOffset: initialOffset,
      );
    }

    _initializeRetryController();
    _setupDataListener();
  }

  void _initializeRetryController() {
    _retryController = LdRetryController(
      onRetry: _onRefresh,
      config: widget.retryConfig ?? LdRetryConfig.unlimitedManualRetries(),
    );
  }

  void _setupDataListener() {
    widget.paginator.addListener(_onDataChange);
    _onDataChange();
  }

  @override
  void didUpdateWidget(covariant LdList<T, GroupingCriterion> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldRegroupItems(oldWidget)) {
      _onDataChange();
    }

    if (_shouldUpdateDataListener(oldWidget)) {
      oldWidget.paginator.removeListener(_onDataChange);
      widget.paginator.addListener(_onDataChange);
    }

    if (widget.header != oldWidget.header) {
      setState(() {});
    }

    if (widget.footer != oldWidget.footer) {
      setState(() {});
    }
  }

  bool _shouldRegroupItems(LdList<T, GroupingCriterion> oldWidget) {
    return oldWidget.groupingCriterion != widget.groupingCriterion || widget.paginator != oldWidget.paginator;
  }

  bool _shouldUpdateDataListener(LdList<T, GroupingCriterion> oldWidget) {
    return widget.paginator != oldWidget.paginator;
  }

  @override
  void dispose() {
    _retryController.dispose();
    widget.paginator.removeListener(_onDataChange);
    if (widget.scrollController == null && !widget.primary) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// Groups items sequentially based on the grouping criterion
  List<_ListItem<T, GroupingCriterion>> _groupItems() {
    final groupedItems = <_ListItem<T, GroupingCriterion>>[];
    GroupingCriterion? lastSeparationCriterion;

    for (final item in widget.paginator.currentList<GroupingCriterion>()) {
      if (item.item == null) {
        // Loader
        groupedItems.add(
          _ListItem<T, GroupingCriterion>(
            position: item.position,
            type: _ListItemType.item,
          ),
        );
        continue;
      }

      final currentCriterion = widget.groupingCriterion!(item.item!);
      if (lastSeparationCriterion != currentCriterion) {
        // Group header
        groupedItems.add(
          _ListItem(
            position: item.position,
            type: _ListItemType.groupHeader,
            separationCriterion: currentCriterion,
          ),
        );
        lastSeparationCriterion = currentCriterion;
      } else {
        // Separator
        if (widget.separatorBuilder != null) {
          groupedItems.add(
            _ListItem(
              position: item.position,
              type: _ListItemType.separator,
            ),
          );
        }
      }
      groupedItems.add(item);
    }

    return groupedItems;
  }

  Future<void> _onDataChange() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    _updateRetryControllerState();
    _updateGroupedItems();
    _maybePerformInitialScroll();
  }

  void _updateRetryControllerState() {
    if (widget.paginator.busy) {
      _retryController.notifyOperationStarted();
    } else if (widget.paginator.hasError) {
      _retryController.handleError(canRetry: true);
    } else {
      _retryController.notifyOperationCompleted();
    }
  }

  Future<void> _onRefresh() async {
    _retryController.notifyOperationStarted();
    await widget.paginator.refreshList();
  }

  void _updateGroupedItems() {
    setState(() {
      /// If grouping is enabled, we need to group the items
      if (widget.groupHeaderBuilder != null && widget.groupingCriterion != null) {
        _groupedItems = _groupItems();

        /// Only a separator is provided.. we need to intersperse the items
      } else if (widget.groupingCriterion == null && widget.separatorBuilder != null) {
        _groupedItems = _createInterspersedList();
      } else {
        /// No grouping is provided.. we just use the items as is
        _groupedItems = widget.paginator.currentList<GroupingCriterion>();
      }
    });
  }

  // Alternate between a separator and an item
  List<_ListItem<T, GroupingCriterion>> _createInterspersedList() {
    return intersperse(
      _ListItem<T, GroupingCriterion>(
        type: _ListItemType.separator,
      ),
      widget.paginator.currentList<GroupingCriterion>().map((item) => item),
    ).toList(growable: false);
  }

  Widget _buildListView(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: _scrollPhysics,
      slivers: _buildSlivers(context),
    );
  }

  ScrollPhysics get _scrollPhysics {
    return widget.physics ??
        (widget.shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics());
  }

  List<Widget> _buildSlivers(BuildContext context) {
    return [
      if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
      if (widget.paginator.currentItemCount == 0) _buildLoadMore(context, -1),
      _buildListItems(),
      if (widget.footer != null) SliverToBoxAdapter(child: widget.footer!),
    ];
  }

  Widget _buildListItems() {
    return SliverList.builder(
      itemCount: _groupedItems.length,
      itemBuilder: (context, index) => _buildListItem(context, index),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _groupedItems[index];

    if (item.type == _ListItemType.groupHeader) {
      return widget.groupHeaderBuilder!(
        context,
        item.separationCriterion as GroupingCriterion,
      );
    }

    if (item.type == _ListItemType.separator) {
      return widget.separatorBuilder!(
        context,
      );
    }
    if (item.item == null) {
      return _buildPlaceholderItem(item.position);
    }

    return _buildActualItem(context, item, index);
  }

  Widget _buildPlaceholderItem(int? position) {
    if (position == null) {
      return const SizedBox.shrink();
    }

    widget.paginator.fetchPageAtOffset(position);

    return _buildLoader(context, position);
  }

  Widget _buildActualItem(
    BuildContext context,
    _ListItem<T, GroupingCriterion> item,
    int index,
  ) {
    if (_assumeItemKey == null) {
      _assumeItemKey = GlobalKey();
      return KeyedSubtree(
        key: _assumeItemKey,
        child: widget.itemBuilder(context, item.item!, index),
      );
    }

    return widget.itemBuilder(context, item.item!, index);
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context, _onRefresh);
    }

    return LdListEmpty(onRefresh: _onRefresh);
  }

  /// Builds a loader to indicate that an item is being loaded.
  Widget _buildLoader(BuildContext context, int position) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(
        context,
        position,
        widget.paginator.totalItems,
      );
    }

    return const LdListItemLoading();
  }

  /// Builds a battery of loaders to indicate that more items are being loaded.
  Widget _buildLoadMore(BuildContext context, int position) {
    if (widget.loadingBuilder != null) {
      return SliverList.builder(
        itemCount: max(
          widget.paginator.initialOffset + 1,
          widget.paginator.pageSize,
        ),
        itemBuilder: (context, index) {
          return _buildLoader(context, position + index);
        },
      );
    }

    return SliverList.builder(
      itemCount: widget.paginator.pageSize,
      itemBuilder: (context, index) => _buildLoader(context, position + index),
    );
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

  /// Helper method to perform the initial scroll to the correct position
  /// based on the initial offset.
  void _maybePerformInitialScroll() {
    if (!_scrollController.hasClients) return;
    if (widget.paginator.initialOffset == 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final effectiveAssumedHeight = _effectiveAssumedHeight;

      /// Dont scroll if the item height is not yet calculated, or we
      /// dont have a valid assumed height
      if (effectiveAssumedHeight == null) return;

      _scrollController.jumpTo(
        widget.paginator.initialOffset * effectiveAssumedHeight,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paginator.hasError) {
      return _buildError(widget.paginator.error!);
    }

    if (widget.paginator.currentItemCount == 0 && !widget.paginator.busy) {
      return _buildEmpty(context);
    }

    return RefreshIndicator.adaptive(
      onRefresh: widget.paginator.refreshList,
      child: _buildListView(context),
    );
  }
}
