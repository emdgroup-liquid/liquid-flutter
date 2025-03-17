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

  final LdRetryConfig? retryConfig;

  // Selection controls

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
    this.retryConfig = const LdRetryConfig(),
  });

  @override
  State<LdList<T, GroupingCriterion>> createState() =>
      _LdListState<T, GroupingCriterion>();
}

class _LdListState<T, GroupingCriterion>
    extends State<LdList<T, GroupingCriterion>> {
  // Holds the items that are currently displayed in the list
  List<_ListItem<T, GroupingCriterion>> _groupedItems = [];
  late final LdRetryController _retryController;

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
    this._retryController = LdRetryController(
      onRetry: _onRefresh,
      config: widget.retryConfig ?? const LdRetryConfig(),
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
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _retryController.dispose();
    widget.data.removeListener(_onDataChange);
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

    return LdListError(
      error: error,
      retryController: _retryController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showLoadingIndicator = widget.data.hasMoreData || widget.data.busy;

    int count = _groupedItems.length;

    if (widget.data.hasError) {
      return _buildError(widget.data.error!);
    }

    if (widget.data.currentList.isEmpty && !widget.data.busy) {
      return _buildEmpty(context);
    }

    final list = CustomScrollView(
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
        SliverList.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            final item = _groupedItems[index];

            if (index == count - 1 && showLoadingIndicator) {
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
        if (showLoadingIndicator)
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildLoadMore(context),
                if (widget.assumedItemHeight != null)
                  SizedBox(
                    height:
                        widget.data.remainingItems * widget.assumedItemHeight!,
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
