import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/intersperse.dart';
import 'package:provider/provider.dart';

part 'list.variants.g.dart';

/// A model class representing an item in the list.

enum LdListRenderItemType {
  item,
  separator,
  groupHeader,
}

class LdListRenderItem<T extends Identifiable> {
  LdListRenderItem({
    required this.type,
    this.item,
    this.groupItems = const [],
    this.separationCriterion,
    this.position,
  }) : assert(
          !(type == LdListRenderItemType.item && position == null),
          "Items must have a position",
        );

  final LdPaginatorItem<T>? item;
  final LdListRenderItemType type;
  final List<LdListRenderItem<T>> groupItems;
  final dynamic separationCriterion;

  /// The position that this item belongs to.
  /// Can be null for separator items.
  /// For regular items:
  /// - If item is null but position is not, the item is yet to be loaded
  /// - If both item and position are null, it's likely a separator
  final int? position;
}

/// Extension to convert [LdPaginator] data into a list of [LdListRenderItem]s
extension GetItemList<T extends Identifiable<IdType>, IdType> on LdPaginator<T, IdType> {
  List<LdListRenderItem<T>> currentList() {
    final result = <LdListRenderItem<T>>[];
    if (totalItems == 0) return result;
    for (int i = 0; i < totalItems; i++) {
      final item = getItemAt(i);
      result.add(LdListRenderItem<T>(
        item: item,
        position: i,
        type: LdListRenderItemType.item,
      ));
    }
    return result;
  }
}

typedef LdListItemBuilder<T extends Identifiable> = Widget Function(
  BuildContext context,
  LdPaginatorLoadedItem<T> item,
  int index,
);

/// A sophisticated list widget that supports:
/// - Pagination with loading indicators
/// - Item grouping with custom separators
/// - Bidirectional scrolling
/// - Error handling and retry mechanisms
/// - Pull-to-refresh functionality
/// - Empty state handling

@Variants([])
class LdListWidget<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdListWidget({
    super.key,
    @ContextConfigurable() required this.itemBuilder,
    @ContextConfigurable() required this.paginator,
    @ContextConfigurable() this.areEqual,
    @ContextConfigurable() this.assumedItemHeight,
    @ContextConfigurable() this.emptyBuilder,
    @ContextConfigurable() this.errorBuilder,
    @ContextConfigurable() this.footer,
    @ContextConfigurable() this.groupHeaderBuilder,
    @ContextConfigurable() this.groupingCriterion,
    @ContextConfigurable() this.header,
    @ContextConfigurable() this.loadingBuilder,
    @ContextConfigurable() this.padding = EdgeInsets.zero,
    @ContextConfigurable() this.physics,
    @ContextConfigurable() this.primary = false,
    @ContextConfigurable() this.retryConfig,
    @ContextConfigurable() this.scrollController,
    @ContextConfigurable() this.separatorBuilder,
    @ContextConfigurable() this.shrinkWrap = false,
  });

  /// Function that builds a [T] in the list.
  final LdListItemBuilder<T> itemBuilder;

  /// Built when there are no items call [refresh] to trigger [paginator]'s refresh
  /// function
  final Widget Function(
    BuildContext context,
    Future<void> Function(BuildContext context) refresh,
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
  final dynamic Function(T item)? groupingCriterion;
  final Widget Function(BuildContext context, dynamic criterion, List<LdPaginatorItem<T>> items)? groupHeaderBuilder;

  /// Built between items. Not called between items and group headers.
  final Widget Function(BuildContext context)? separatorBuilder;

  /// The paginator to use
  final LdPaginator<T, IdType> paginator;

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

  /// The padding of the list.
  final EdgeInsets padding;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('primary', primary));
    properties.add(DiagnosticsProperty<bool>('shrinkWrap', shrinkWrap));
    properties.add(DoubleProperty('assumedItemHeight', assumedItemHeight));
    properties.add(DiagnosticsProperty<ScrollPhysics?>('physics', physics));
    properties.add(DiagnosticsProperty<Widget?>('header', header));
    properties.add(DiagnosticsProperty<Widget?>('footer', footer));
    properties.add(FlagProperty(
      'hasGrouping',
      value: groupingCriterion != null && groupHeaderBuilder != null,
      ifTrue: 'enabled',
    ));
    properties.add(FlagProperty(
      'hasSeparator',
      value: separatorBuilder != null,
      ifTrue: 'enabled',
    ));
    properties.add(DiagnosticsProperty<LdRetryConfig?>('retryConfig', retryConfig));
    properties.add(DiagnosticsProperty<ScrollController?>('scrollController', scrollController));
    properties.add(DiagnosticsProperty("paginator", paginator));
  }

  @override
  State<LdListWidget<T, IdType>> createState() => _LdListState<T, IdType>();
}

class _LdListState<T extends Identifiable<IdType>, IdType> extends State<LdListWidget<T, IdType>> {
  // State variables
  List<LdListRenderItem<T>> _groupedItems = [];
  late final ScrollController _scrollController;

  late final LdRetryController _retryController;

  final Map<IdType, GlobalKey> _itemKeys = {};
  final Set<int> _pendingGapOffsets = {};

  @override
  void initState() {
    super.initState();

    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else if (widget.primary) {
      _scrollController = PrimaryScrollController.of(context);
    } else {
      _scrollController = ScrollController();
    }

    _initializeRetryController();
    _setupDataListener();
  }

  void _initializeRetryController() {
    _retryController = LdRetryController(
      onRetry: () => _onRefresh(context),
      config: widget.retryConfig ?? LdRetryConfig.unlimitedManualRetries(),
    );
  }

  void _setupDataListener() {
    widget.paginator.addListener(_onDataChange);
    _onDataChange();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger an initial fetch if the paginator has no items and is not already
    // fetching. This handles the case where LdList is mounted with a fresh
    // paginator that has no initialItems (totalItems == 0).
    if (widget.paginator.totalItems == 0 && !widget.paginator.busy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.paginator.refreshList(context: context);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant LdListWidget<T, IdType> oldWidget) {
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

    if (widget.paginator.initialOffset != oldWidget.paginator.initialOffset) {
      _performedInitialScroll = false;
      _maybePerformInitialScroll();
    }

    if (widget.footer != oldWidget.footer) {
      setState(() {});
    }
  }

  bool _shouldRegroupItems(LdListWidget<T, IdType> oldWidget) {
    return oldWidget.groupingCriterion != widget.groupingCriterion || widget.paginator != oldWidget.paginator;
  }

  bool _shouldUpdateDataListener(LdListWidget<T, IdType> oldWidget) {
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
  List<LdListRenderItem<T>> _groupItems() {
    final result = <LdListRenderItem<T>>[];
    dynamic lastSeparationCriterion;

    int groupIndex = -1;

    for (final item in widget.paginator.currentList()) {
      if (item.item == null) {
        // Loader
        result.add(
          LdListRenderItem<T>(
            position: item.position,
            type: LdListRenderItemType.item,
          ),
        );
        continue;
      }

      final currentCriterion = widget.groupingCriterion!(item.item!.value!);
      if (lastSeparationCriterion != currentCriterion) {
        // Group header
        result.add(
          LdListRenderItem(
            position: item.position,
            type: LdListRenderItemType.groupHeader,
            separationCriterion: currentCriterion,
            groupItems: [],
          ),
        );
        lastSeparationCriterion = currentCriterion;
        groupIndex = result.length - 1;
      } else {
        // Separator
        if (widget.separatorBuilder != null) {
          result.add(LdListRenderItem<T>(
            position: item.position,
            type: LdListRenderItemType.separator,
          ));
        }
      }

      if (groupIndex != -1) {
        result[groupIndex].groupItems.add(item);
      }
      result.add(item);
    }

    return result;
  }

  Future<void> _onDataChange() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    _pendingGapOffsets.clear();
    _updateRetryControllerState();
    _updateGroupedItems();

    _maybePerformInitialScroll();
    _maybeScrollToPendingItem();
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

  Future<void> _onRefresh(BuildContext context) async {
    _retryController.notifyOperationStarted();
    await widget.paginator.refreshList(
      context: context,
      reason: LdFetchReason.refresh,
    );
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
        _groupedItems = widget.paginator.currentList();
      }

      // We remove keys that are no longer in the list
      final presentIds = _groupedItems.map((item) => item.item?.value?.id).where((id) => id != null).toSet();
      _itemKeys.removeWhere((id, key) => !presentIds.contains(id));
    });
  }

  // Alternate between a separator and an item
  List<LdListRenderItem<T>> _createInterspersedList() {
    return intersperseIterable(
      LdListRenderItem<T>(
        type: LdListRenderItemType.separator,
      ),
      widget.paginator.currentList().map((item) => item),
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
      if (widget.header != null)
        SliverSafeArea(
            minimum: widget.padding.copyWith(bottom: 00),
            sliver: SliverToBoxAdapter(
              child: widget.header!,
            )),
      SliverSafeArea(
        top: widget.header == null,
        bottom: widget.footer == null,
        left: false,
        right: false,
        sliver: _buildListItems(),
      ),
      if (widget.footer != null)
        SliverSafeArea(
          minimum: widget.padding.copyWith(top: 0),
          sliver: SliverToBoxAdapter(
            child: widget.footer!,
          ),
        ),
    ];
  }

  Widget _buildListItems() {
    return SliverList.builder(
      itemCount: _groupedItems.length,
      itemBuilder: (context, index) => LdListItemConfigProvider(
        config: LdListItemConfig(
          padding: MediaQuery.of(context).padding + LdTheme.of(context).pad(),
        ),
        child: _buildListItem(context, index),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _groupedItems[index];

    if (item.type == LdListRenderItemType.groupHeader) {
      return widget.groupHeaderBuilder!(
        context,
        item.separationCriterion,
        item.groupItems.map((e) {
          return e.item!;
        }).toList(),
      );
    }

    if (item.type == LdListRenderItemType.separator) {
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

    final pageSize = widget.paginator.pageSize;
    final normalizedOffset = (position ~/ pageSize) * pageSize;
    if (_pendingGapOffsets.add(normalizedOffset)) {
      widget.paginator.fetchPageAtOffset(context, position);
    }

    return _buildLoader(context, position);
  }

  Widget _buildActualItem(
    BuildContext context,
    LdListRenderItem<T> listEntry,
    int index,
  ) {
    final item = LdPaginatorLoadedItem(value: listEntry.item!.value, state: listEntry.item!.state);

    _itemKeys[item.value.id] ??= GlobalKey(debugLabel: "list${item.value.id}");

    if (listEntry.item!.state == LdPaginatorItemState.pendingRefresh) {
      widget.paginator.fetchPageAtOffset(context, listEntry.position!);
    }

    return KeyedSubtree(
      key: _itemKeys[item.value.id],
      child: switch (listEntry.item!.state) {
        LdPaginatorItemState.fetching => _buildLoader(context, listEntry.position!),
        _ => widget.itemBuilder(context, item, listEntry.position!),
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context, _onRefresh);
    }

    return LdListEmpty(onRefresh: () => _onRefresh(context));
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

  Widget _buildError(
    LdException error,
  ) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, () => _onRefresh(context));
    }

    // return the default error view (LdExceptionView)
    return Center(
      child: LdExceptionView(
        exception: error,
        direction: Axis.vertical,
        retryController: _retryController,
      ),
    ).padL();
  }

  double _getAverageItemHeight() {
    double totalHeight = 0;
    double count = 0;

    for (final item in _itemKeys.values) {
      final height = item.currentContext?.findRenderObject()?.paintBounds.height;

      if (height != null) {
        totalHeight += height;
        count++;
      }
    }

    if (count == 0) {
      return widget.assumedItemHeight ?? 0;
    }

    return totalHeight / count;
  }

  bool _performedInitialScroll = false;
  int _pendingScrollAttempts = 0;
  static const _maxPendingScrollAttempts = 120;

  void _maybeScrollToPendingItem() {
    final scrollToId = widget.paginator.pendingScrollToItemId;
    if (scrollToId == null) {
      _pendingScrollAttempts = 0;
      return;
    }

    final index = widget.paginator.getItemIndexById(scrollToId);
    if (index == null) {
      _pendingScrollAttempts = 0;
      return;
    }

    if (!_scrollController.hasClients) {
      if (_pendingScrollAttempts++ >= _maxPendingScrollAttempts) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.paginator.pendingScrollToItemId == scrollToId) {
          _maybeScrollToPendingItem();
        }
      });
      return;
    }

    _pendingScrollAttempts = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollPendingItemIntoView(scrollToId, index));
    });
  }

  Future<void> _scrollPendingItemIntoView(IdType id, int index) async {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    if (widget.paginator.pendingScrollToItemId != id) {
      return;
    }

    await widget.paginator.fetchPageAtOffset(context, index);
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    if (widget.paginator.pendingScrollToItemId != id) {
      return;
    }

    final averageHeight = _getAverageItemHeight();
    if (averageHeight <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.paginator.pendingScrollToItemId == id) {
          _maybeScrollToPendingItem();
        }
      });
      return;
    }

    final target = (averageHeight * index).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    final scrollBefore = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    final firstVisibleIndex = (scrollBefore / averageHeight).floor();
    final lastVisibleIndex = ((scrollBefore + viewportHeight) / averageHeight).ceil();
    final isVisible = index >= firstVisibleIndex && index <= lastVisibleIndex;

    if (isVisible) {
      if (widget.paginator.pendingScrollToItemId == id) {
        widget.paginator.clearPendingScrollToItem();
      }
      return;
    }

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (!mounted) {
      return;
    }

    await WidgetsBinding.instance.endOfFrame;

    final itemContext = _itemKeys[id]?.currentContext;
    if (itemContext != null && itemContext.mounted) {
      await Scrollable.ensureVisible(
        itemContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 150),
      );
    }

    if (widget.paginator.pendingScrollToItemId == id) {
      widget.paginator.clearPendingScrollToItem();
    }
  }

  /// Helper method to perform the initial scroll to the correct position
  /// based on the initial offset.
  Future<void> _maybePerformInitialScroll() async {
    if (!_scrollController.hasClients) return;
    // We need to wait for at least the top items to load to calculate
    // the average height correctly
    if (_itemKeys.isEmpty) return;
    if (widget.paginator.initialOffset == 0) return;

    if (_performedInitialScroll) return;

    _performedInitialScroll = true;

    final averageHeight = _getAverageItemHeight();

    final offset = averageHeight * widget.paginator.initialOffset;

    _scrollController.animateTo(offset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paginator.hasError) {
      return _buildError(
        widget.paginator.error!,
      );
    }

    if (widget.paginator.currentItemCount == 0 && !widget.paginator.busy) {
      return _buildEmpty(context);
    }

    return RefreshIndicator.adaptive(
      edgeOffset: MediaQuery.of(context).padding.top,
      onRefresh: () => widget.paginator.refreshList(
        context: context,
        reason: LdFetchReason.refresh,
      ),
      child: _buildListView(context),
    );
  }
}
