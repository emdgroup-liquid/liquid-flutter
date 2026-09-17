import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/shuttle_safe_key.dart';
import 'package:provider/provider.dart';

/// Injects drag-to-reorder via [LdListConfig]: chains [itemBuilder] with
/// [Draggable] / [LongPressDraggable] and provides slot keys through
/// [loadingBuilder].
///
/// Wrap an [LdList] child that reads its configuration from context.
///
/// While a drag is active, the list auto-scrolls via [EdgeDraggingAutoScroller]
/// when the dragged item is held near the top or bottom edge of the scrollable
/// viewport, so items can be reordered beyond the visible region. Set
/// [velocityScalar] to 0 to disable auto-scrolling.
class LdListReorderScope<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdListReorderScope({
    super.key,
    required this.onReorder,
    required this.child,
    this.velocityScalar = 50,
  });

  final Future<void> Function(IdType id, int fromIndex, int toIndex) onReorder;
  final Widget child;

  /// The auto-scroll velocity scalar, as described in
  /// [EdgeDraggingAutoScroller.velocityScalar]: a higher value makes the list
  /// scroll faster while dragging near an edge. Defaults to Flutter's
  /// [ReorderableListView] default of 50. Set to 0 to disable auto-scrolling.
  final double velocityScalar;

  @override
  State<LdListReorderScope<T, IdType>> createState() => _LdListReorderScopeState<T, IdType>();
}

class _LdListReorderScopeState<T extends Identifiable<IdType>, IdType> extends State<LdListReorderScope<T, IdType>> {
  final _slotKeys = <int, GlobalKey>{};

  OverlayEntry? _overlayEntry;
  IdType? _draggingId;
  int? _fromIndex;
  int? _dropIndex;

  double? _dragFeedbackWidth;

  LdListItemBuilder<T>? _innerItemBuilder;

  ScrollableState? _scrollable;
  EdgeDraggingAutoScroller? _autoScroller;
  Offset? _lastDragPosition;

  LdPaginator<T, IdType> get _paginator => Provider.of<LdListConfig<T, IdType>>(context, listen: false).paginator!;

  GlobalKey _slotKey(int position) =>
      _slotKeys.putIfAbsent(position, () => GlobalKey(debugLabel: 'reorder_slot_$position'));

  @override
  void dispose() {
    _autoScroller?.stopAutoScroll();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _ensureAutoScroller() {
    final scrollable = _scrollable;
    _autoScroller?.stopAutoScroll();
    _autoScroller = (widget.velocityScalar > 0 && scrollable != null)
        ? EdgeDraggingAutoScroller(
            scrollable,
            onScrollViewScrolled: _onAutoScrollTick,
            velocityScalar: widget.velocityScalar,
          )
        : null;
  }

  /// The rect of the dragged item used by [EdgeDraggingAutoScroller] to decide
  /// whether the drag is close enough to the viewport edge to scroll. Sized to
  /// the dragged item and centered on the pointer.
  Rect _dragTargetRect(Offset globalPosition) {
    var width = _dragFeedbackWidth ?? 1.0;
    var height = max(100.0, MediaQuery.paddingOf(context).vertical);
    return Rect.fromCenter(center: globalPosition, width: width, height: height);
  }

  /// Updates the drop indicator when the list is auto-scrolled under the
  /// pointer, and keeps the auto-scroll loop aware of the drag position.
  void _onAutoScrollTick() {
    if (_draggingId == null) {
      return;
    }

    final lastDragPosition = _lastDragPosition;
    if (lastDragPosition != null) {
      _dropIndex = _nearestDropIndex(lastDragPosition.dy);
      _markOverlayNeedsBuild();
    }

    final autoScroller = _autoScroller;
    if (autoScroller != null && lastDragPosition != null) {
      autoScroller.startAutoScrollIfNecessary(_dragTargetRect(lastDragPosition));
    }
  }

  Rect? _slotBounds(int position) {
    final box = _slotKey(position).currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  int _nearestDropIndex(double globalY) {
    final total = _paginator.totalItems;
    if (total == 0) {
      return 0;
    }

    final boundaries = <({int index, double y})>[];

    for (var i = 0; i <= total; i++) {
      final double? y;

      if (i == 0) {
        y = _slotBounds(0)?.top;
      } else if (i == total) {
        y = _slotBounds(total - 1)?.bottom;
      } else {
        final above = _slotBounds(i - 1);
        final below = _slotBounds(i);
        if (above != null && below != null) {
          y = (above.bottom + below.top) / 2;
        } else {
          y = below?.top ?? above?.bottom;
        }
      }
      if (y != null) {
        boundaries.add((index: i, y: y));
      }
    }

    if (boundaries.isEmpty) {
      return 0;
    }

    boundaries.sort((a, b) => (a.y - globalY).abs().compareTo((b.y - globalY).abs()));
    return boundaries.first.index.clamp(0, total);
  }

  void _insertOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(builder: _buildDropIndicatorOverlay);
    Overlay.of(
      context,
    ).insert(_overlayEntry!);
  }

  void _markOverlayNeedsBuild() {
    _overlayEntry?.markNeedsBuild();
  }

  void _onDragStarted(IdType id, int fromIndex) {
    debugPrint('[reorder] _onDragStarted id=$id fromIndex=$fromIndex');
    if (_draggingId != null) {
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    setState(() {
      _draggingId = id;
      _fromIndex = fromIndex;
      _dropIndex = fromIndex;
    });

    // Check if we have the size of the drag feedback
    final dragStartRect = _slotKey(fromIndex).currentContext?.findRenderObject() as RenderBox?;
    if (dragStartRect != null && dragStartRect.hasSize) {
      _dragFeedbackWidth = dragStartRect.size.width;
    }

    _ensureAutoScroller();
    _insertOverlay();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_draggingId == null) {
      return;
    }

    _dropIndex = _nearestDropIndex(details.globalPosition.dy);

    _markOverlayNeedsBuild();

    _lastDragPosition = details.globalPosition;
    final autoScroller = _autoScroller;
    if (autoScroller != null) {
      autoScroller.startAutoScrollIfNecessary(_dragTargetRect(details.globalPosition));
    }
  }

  Future<void> _onDragEnd(DraggableDetails details) async {
    _autoScroller?.stopAutoScroll();
    _lastDragPosition = null;

    final id = _draggingId;
    final from = _fromIndex;
    final to = _nearestDropIndex(details.offset.dy);

    _removeOverlay();

    setState(() {
      _draggingId = null;
      _fromIndex = null;
      _dropIndex = null;
    });

    if (id == null || from == null || from == to) {
      return;
    }

    await widget.onReorder(id, from, to);
  }

  void _onDragCanceled() {
    _autoScroller?.stopAutoScroll();
    _lastDragPosition = null;

    _removeOverlay();
    setState(() {
      _draggingId = null;
      _fromIndex = null;
      _dropIndex = null;
    });
  }

  Widget _buildDropIndicatorOverlay(BuildContext context) {
    final theme = LdTheme.of(context);
    final dropIndex = _dropIndex;

    double? indicatorY;
    double? indicatorLeft;
    double? indicatorRight;

    if (dropIndex != null) {
      final dropBounds = _slotBounds(dropIndex.clamp(0, _paginator.totalItems - 1));
      if (dropIndex == 0) {
        indicatorY = dropBounds?.top;
      } else if (dropIndex >= _paginator.totalItems) {
        indicatorY = dropBounds?.bottom;
      } else {
        final above = _slotBounds(dropIndex - 1);
        final below = dropBounds;
        if (above != null && below != null) {
          indicatorY = (above.bottom + below.top) / 2;
        } else {
          indicatorY = below?.top ?? above?.bottom;
        }
      }
      indicatorLeft = dropBounds?.left;
      indicatorRight = dropBounds?.right;
    }

    if (indicatorY == null || indicatorLeft == null || indicatorRight == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned(
          left: indicatorLeft,
          width: indicatorRight - indicatorLeft,
          top: indicatorY,
          child: Container(
            height: 2,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    LdPaginatorLoadedItem<T> item,
    int index,
  ) {
    final innerBuilder = _innerItemBuilder;
    if (innerBuilder == null) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: 0.6,
      child: Material(
        color: Colors.transparent,
        child: Provider<LdIsShuttle>.value(
          value: const LdIsShuttle(true),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _dragFeedbackWidth ?? MediaQuery.sizeOf(context).width),
            child: Builder(
              builder: (ctx) => innerBuilder(ctx, item, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithDraggable(
    BuildContext context,
    LdPaginatorLoadedItem<T> item,
    int index,
    Widget child,
  ) {
    final slotKey = _slotKey(index);
    final id = item.value.id;
    final isDraggingItem = _draggingId == id;

    // Capture the enclosing scroll view so drags can auto-scroll the list when
    // the pointer is held near the viewport edge. The item context is a
    // descendant of the [CustomScrollView]'s [Scrollable].
    _scrollable ??= context.findAncestorStateOfType<ScrollableState>();

    return KeyedSubtree(
      key: slotKey,
      child: LdListItemConfigProvider(
        config: LdListItemConfig(
          showDragHandle: true,
          dragCallbacks: LdListItemDragConfig(
            onDragStarted: () => _onDragStarted(id, index),
            onDragUpdate: _onDragUpdate,
            onDragEnd: _onDragEnd,
            onDragCanceled: (velocity, offset) => _onDragCanceled(),
            feedbackBuilder: (context) => _buildFeedback(context, item, index),
            isDragging: isDraggingItem,
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        _innerItemBuilder = Provider.of<LdListConfig<T, IdType>>(ctx, listen: true).itemBuilder;

        final chainedItemBuilder = ldChainListItemBuilder<T, IdType>(ctx, (context, item, index, parent) {
          return _wrapWithDraggable(
            context,
            item,
            index,
            parent(context, item, index),
          );
        });

        final chainedLoadingBuilder = ldChainLoadingBuilder<T, IdType>(ctx, (context, position, totalItems, parent) {
          return LdShuttleSafeKey(
            childKey: _slotKey(position),
            child: parent(context, position, totalItems),
          );
        });

        return LdListConfigProvider<T, IdType>(
          config: LdListConfig<T, IdType>(
            itemBuilder: chainedItemBuilder,
            loadingBuilder: chainedLoadingBuilder,
          ),
          child: widget.child,
        );
      },
    );
  }
}
