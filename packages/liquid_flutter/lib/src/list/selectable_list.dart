// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/shuttle_safe_key.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'selectable_list_selection_controller.dart';

class LdSelectableList<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Set<IdType> initialSelectedItems;
  final bool multiSelect;

  final LdPaginator<T, IdType> listController;

  final void Function(Set<IdType> selectedItems)? onSelectionChange;

  final bool showSelectionControls;

  /// When true, marquee/box selection drag gestures are disabled.
  final bool disableDragGestures;

  /// List subtree; defaults to [LdList] configured via context.
  final Widget? child;

  const LdSelectableList({
    super.key,
    this.child,
    this.onSelectionChange,
    this.multiSelect = false,
    required this.listController,
    this.showSelectionControls = false,
    this.initialSelectedItems = const {},
    this.disableDragGestures = false,
  });

  @override
  State<LdSelectableList<T, IdType>> createState() => LdSelectableListState<T, IdType>();
}

class LdSelectableListState<T extends Identifiable<IdType>, IdType> extends State<LdSelectableList<T, IdType>>
    with WidgetsBindingObserver {
  late final LdSelectableListSelectionController<T, IdType> _selectionController;
  late final ScrollController _scrollController;

  final GlobalKey _rootKey = GlobalKey(debugLabel: "Root Key");

  bool _isMobile = false;
  bool _suppressSelectionChange = false;

  EdgeDraggingAutoScroller? _autoScroller;
  Rect? _activeDragRect;
  bool _activeDirectionIsDownRight = true;
  Offset? _activeDragEndOffset;

  static const double _autoScrollerVelocityScalar = 50;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();

    _selectionController = LdSelectableListSelectionController<T, IdType>(
      multiSelect: widget.multiSelect,
      paginator: widget.listController,
      initialSelectedItems: widget.initialSelectedItems,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tryScrollToInitialSelection(widget.initialSelectedItems);
      }
    });

    _selectionController.setShowSelectionControls(widget.showSelectionControls);

    _selectionController.addListener(_onSelectionControllerChanged);
  }

  void _onSelectionControllerChanged() {
    if (!_suppressSelectionChange) {
      widget.onSelectionChange?.call(_selectionController.selectedItems);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _selectionController.changeNotifier.notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    WidgetsBinding.instance.removeObserver(this);
    _selectionController.removeListener(_onSelectionControllerChanged);
    _scrollController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  ScrollableState? get _scrollableState {
    if (!_scrollController.hasClients) {
      return null;
    }
    final scrollContext = _scrollController.position.context;
    if (scrollContext is ScrollableState) {
      return scrollContext;
    }
    final notificationContext = scrollContext.notificationContext;
    if (notificationContext == null) {
      return null;
    }
    return Scrollable.maybeOf(notificationContext);
  }

  void _ensureAutoScroller() {
    final scrollable = _scrollableState;
    if (scrollable == null) {
      return;
    }
    _autoScroller ??= EdgeDraggingAutoScroller(
      scrollable,
      onScrollViewScrolled: _handleAutoScrolled,
      velocityScalar: _autoScrollerVelocityScalar,
    );
  }

  void _handleAutoScrolled() {
    final dragRect = _activeDragRect;
    final dragEndOffset = _activeDragEndOffset;
    if (dragRect == null || dragEndOffset == null) {
      return;
    }
    _selectionController.onUpdateDragRect(
      dragRect,
      _activeDirectionIsDownRight,
      _isMobile,
      viewportRect: _viewportGlobalRect(),
    );
    setState(() {});
    _updateAutoScroll(dragEndOffset);
  }

  Rect? _viewportGlobalRect() {
    final scrollable = _scrollableState;
    if (scrollable == null) {
      return null;
    }
    final box = scrollable.context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  void _updateAutoScroll(Offset dragEndOffset) {
    _ensureAutoScroller();
    final pointerRect = Rect.fromCenter(center: dragEndOffset, width: 1, height: 1);
    _autoScroller?.startAutoScrollIfNecessary(pointerRect);
  }

  void _stopAutoScroll() {
    _autoScroller?.stopAutoScroll();
    _activeDragRect = null;
    _activeDragEndOffset = null;
  }

  void syncSelection(Set<IdType> items) {
    if (!mounted) {
      return;
    }
    if (setEquals(_selectionController.selectedItems, items)) {
      return;
    }
    _suppressSelectionChange = true;
    _selectionController.updateSelectedItems(items);
    _suppressSelectionChange = false;
  }

  @override
  void didUpdateWidget(LdSelectableList<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.multiSelect != widget.multiSelect) {
      _selectionController.setMultiSelect(widget.multiSelect);
    }

    if (!setEquals(oldWidget.initialSelectedItems, widget.initialSelectedItems)) {
      final hadExternalChange = !setEquals(_selectionController.selectedItems, widget.initialSelectedItems);
      syncSelection(widget.initialSelectedItems);

      final previousSelectedItems = oldWidget.initialSelectedItems;
      final newSelectedItems = widget.initialSelectedItems;

      if (hadExternalChange) {
        if (newSelectedItems.isEmpty && previousSelectedItems.isNotEmpty) {
          _tryScrollToInitialSelection(previousSelectedItems);
        } else {
          _tryScrollToInitialSelection(newSelectedItems);
        }
      }
    }

    if (oldWidget.showSelectionControls != widget.showSelectionControls) {
      _selectionController.setShowSelectionControls(widget.showSelectionControls);
    }
  }

  void _tryScrollToInitialSelection(Set<IdType> initialSelectedItems) async {
    if (initialSelectedItems.isEmpty) {
      print("No initial selected items");
      return;
    }
    final listController = widget.listController is LdListController<T, IdType>
        ? widget.listController as LdListController<T, IdType>
        : null;
    final index = listController?.getItemIndexById(initialSelectedItems.first);
    if (index == null) {
      print("Item is not loaded yet");
      // Item is not loaded yet, if there is getOffsetById, we can use that to scroll to the correct position
      if (listController?.model.getOffsetById != null) {
        final offset = await listController!.model.getOffsetById!(
          FetchOffsetParameters<T, IdType>(
            context: context,
            id: initialSelectedItems.first,
            reason: LdFetchReason.initial,
            cache: listController.cache,
          ),
        );

        if (offset != null) {
          double averageHeight = 0;
          int attempts = 0;
          do {
            averageHeight = _selectionController.getAverageItemHeight();
            if (averageHeight == 0) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
            attempts++;
          } while (averageHeight == 0 && attempts < 10);

          if (averageHeight > 0) {
            _scrollController.animateTo(offset.toDouble() * averageHeight,
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        }
      }
    } else {
      // Item is already loaded and might be in the list,

      final itemContext = _selectionController.getKeyForItem(initialSelectedItems.first).currentContext;

      if (itemContext != null && itemContext.mounted) {
        await Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
        _selectionController.getFocusNodeForItem(initialSelectedItems.first).requestFocus();
      } else {
        // Item is not rendered but loaded, we try to scroll to the item based on the index
        final index = listController?.getItemIndexById(initialSelectedItems.first);
        final averageHeight = _selectionController.getAverageItemHeight();
        if (index != null) {
          _scrollController.animateTo(index.toDouble() * averageHeight,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _selectionController.getFocusNodeForItem(initialSelectedItems.first).requestFocus();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _selectionController.handleAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      setState(() {});
    }
    super.didChangeAppLifecycleState(state);
  }

  void _onUpdateDragRect(Rect dragRect, bool directionIsDownRight, Offset dragEndOffset) {
    _activeDragRect = dragRect;
    _activeDirectionIsDownRight = directionIsDownRight;
    _activeDragEndOffset = dragEndOffset;
    _selectionController.onUpdateDragRect(
      dragRect,
      directionIsDownRight,
      _isMobile,
      viewportRect: _viewportGlobalRect(),
    );
    setState(() {});
    _updateAutoScroll(dragEndOffset);
  }

  Future<void> _onEndDrag(Rect rect) async {
    _stopAutoScroll();
    _selectionController.onEndDrag();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _onCancel() {
    _stopAutoScroll();
    _selectionController.onCancel();
    setState(() {});
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    return _selectionController.onKeyEvent(
      event,
      (id) => _selectionController.onSelectionChange(id, true),
      (id) => _selectionController.getFocusNodeForItem(id).requestFocus(),
    );
  }

  LdListItemConfig _selectionConfigFor(IdType itemId) {
    return LdListItemConfig(
      focusNode: _selectionController.getFocusNodeForItem(itemId),
      isSelected: _selectionController.isSelected(itemId),
      selectionControl: switch (widget.showSelectionControls) {
        true => switch (widget.multiSelect) {
            true => LdSelectionControl.checkbox,
            false => LdSelectionControl.radio,
          },
        false => LdSelectionControl.none,
      },
      active: _selectionController.isSelected(itemId),
      onSelectionChanged: (selected) => _selectionController.onSelectionChange(
        itemId,
        selected,
      ),
      onPressed: () => _selectionController.onTap(itemId),
    );
  }

  Widget _buildListConfigLayer(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final chainedItemBuilder = ldChainListItemBuilder<T, IdType>(ctx, (context, item, index, parent) {
          final itemId = item.value.id;
          return LdListItemConfigProvider(
            config: _selectionConfigFor(itemId),
            child: LdShuttleSafeKey(
              childKey: _selectionController.getKeyForItem(itemId),
              child: parent(context, item, index),
            ),
          );
        });

        return LdListConfigProvider<T, IdType>(
          config: LdListConfig<T, IdType>(
            paginator: widget.listController,
            scrollController: _scrollController,
            itemBuilder: chainedItemBuilder,
          ),
          child: widget.child ?? LdList<T, IdType>(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _isMobile = LdTheme.of(context).platform.isMobile;

    final list = _buildListConfigLayer(context);

    if (_isMobile) {
      return Stack(
        children: [
          list,
          if (widget.showSelectionControls && !widget.disableDragGestures)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 42,
              child: _DragRect(
                mobile: true,
                onTapOutside: () {
                  if (!_selectionController.isDragging) {
                    return;
                  }

                  _selectionController.selectedItems;
                  _selectionController.updateSelectedItems({});
                  setState(() {});
                  widget.onSelectionChange?.call({});
                },
                key: _rootKey,
                onUpdateRect: _onUpdateDragRect,
                onEndDrag: _onEndDrag,
                onCancel: _onCancel,
                child: Focus(
                  focusNode: _selectionController.focusNode,
                  autofocus: true,
                  onFocusChange: (_) {},
                  onKeyEvent: _onKeyEvent,
                  child: Container(),
                ),
              ),
            )
        ],
      );
    }

    return LdWrapConditional(
      condition: widget.multiSelect && !widget.disableDragGestures,
      builder: (context, child) => _DragRect(
        onTapOutside: () {
          if (!_selectionController.isDragging) {
            return;
          }
          _selectionController.updateSelectedItems({});
          setState(() {});
          widget.onSelectionChange?.call({});
        },
        key: _rootKey,
        onUpdateRect: _onUpdateDragRect,
        onEndDrag: _onEndDrag,
        isAdditive: true,
        onCancel: _onCancel,
        child: child,
      ),
      child: Focus(
        focusNode: _selectionController.focusNode,
        autofocus: true,
        onFocusChange: (_) {},
        onKeyEvent: _onKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: list),
            if ((_selectionController.ctrlPressed || _selectionController.shiftPressed) && widget.multiSelect)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: MediaQuery.paddingOf(context),
                  child: Container(
                      margin: LdTheme.of(context).pad(),
                      padding: LdTheme.of(context).pad(size: LdSize.s),
                      decoration: BoxDecoration(
                        color: LdTheme.of(context).surface,
                        borderRadius: LdTheme.of(context).radius(LdSize.m),
                        border: Border.all(
                          color: LdTheme.of(context).border,
                          width: LdTheme.of(context).borderWidth,
                        ),
                      ),
                      child: LdAutoSpace(
                        children: [
                          if (_selectionController.ctrlPressed) ...[
                            Row(
                              spacing: LdTheme.of(context).paddingSize(),
                              children: [
                                Icon(LucideIcons.command, size: 16, color: LdTheme.of(context).text),
                                LdText.l(LiquidLocalizations.of(context).ctrlListExplanation)
                              ],
                            ),
                          ],
                          if (_selectionController.shiftPressed) ...[
                            Row(
                              spacing: LdTheme.of(context).paddingSize(),
                              children: [
                                Icon(LucideIcons.arrowBigUp, size: 16, color: LdTheme.of(context).text),
                                LdText.l(LiquidLocalizations.of(context).shiftListExplanation)
                              ],
                            ),
                          ],
                        ],
                      )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DragRect extends StatefulWidget {
  final void Function(Rect rect, bool directionIsDownRight, Offset dragEndOffset) onUpdateRect;
  final void Function(Rect rect) onEndDrag;
  final void Function() onCancel;
  final void Function() onTapOutside;
  final bool isAdditive;
  final bool mobile;

  final Widget child;

  const _DragRect({
    required this.onTapOutside,
    required this.onUpdateRect,
    required this.onEndDrag,
    this.mobile = false,
    required this.child,
    required this.onCancel,
    this.isAdditive = true,
    super.key,
  });

  @override
  State<_DragRect> createState() => _DragRectState();
}

class _DragRectState extends State<_DragRect> {
  Offset? _dragStartOffset;
  Offset? _dragEndOffset;

  final _overlayPortalController = OverlayPortalController();

  Rect? get _dragRect {
    if (_dragStartOffset == null || _dragEndOffset == null) {
      return null;
    }

    final minX = min(_dragStartOffset!.dx, _dragEndOffset!.dx);
    final minY = min(_dragStartOffset!.dy, _dragEndOffset!.dy);
    final maxX = max(_dragStartOffset!.dx, _dragEndOffset!.dx);
    final maxY = max(_dragStartOffset!.dy, _dragEndOffset!.dy);

    return Rect.fromLTWH(minX, minY, (maxX - minX).abs(), (maxY - minY).abs());
  }

  Widget _buildMobileGestureDetector(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (details) {
        _dragStartOffset = details.globalPosition;
        _overlayPortalController.show();

        _dragEndOffset = null;
      },
      onVerticalDragUpdate: (details) {
        _dragEndOffset = details.globalPosition;
        final rect = _dragRect;
        if (rect == null) {
          return;
        }
        widget.onUpdateRect(rect, false, details.globalPosition);
      },
      onVerticalDragEnd: (details) {
        final rect = _dragRect;
        if (rect == null) {
          return;
        }
        _dragEndOffset = null;
        _dragStartOffset = null;
        _overlayPortalController.hide();
        setState(() {});
        widget.onEndDrag(rect);
      },
      onVerticalDragCancel: () {
        if (_dragStartOffset != null) {
          _dragEndOffset = null;
          _overlayPortalController.hide();
          _dragStartOffset = null;
          widget.onCancel();
        }
      },
      child: widget.child,
    );
  }

  Widget _buildDesktopGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTapOutside();
      },
      child: widget.child,
      onPanStart: (details) {
        _dragStartOffset = details.globalPosition;
        _overlayPortalController.show();

        _dragEndOffset = null;
      },
      onPanUpdate: (details) {
        _dragEndOffset = details.globalPosition;

        final rect = _dragRect;
        if (rect == null) {
          return;
        }

        final directionIsDownRight =
            _dragEndOffset!.dy > _dragStartOffset!.dy && _dragEndOffset!.dx > _dragStartOffset!.dx;

        widget.onUpdateRect(rect, directionIsDownRight, details.globalPosition);
      },
      onPanEnd: (details) {
        final rect = _dragRect;
        if (rect == null) {
          return;
        }
        setState(() {});
        _dragEndOffset = null;
        _dragStartOffset = null;
        _overlayPortalController.hide();
        setState(() {});
        widget.onEndDrag(rect);
      },
      onPanCancel: () {
        if (_dragStartOffset != null) {
          _dragEndOffset = null;
          _overlayPortalController.hide();
          _dragStartOffset = null;
          widget.onCancel();
        }
        setState(() {});
      },
    );
  }

  Widget _buildDesktopDragRect(BuildContext context, Rect rect) {
    return Container(
      width: rect.width,
      height: rect.height,
      decoration: BoxDecoration(
        color: widget.isAdditive
            ? LdTheme.of(context).primaryColor.withAlpha(50)
            : LdTheme.of(context).errorColor.withAlpha(50),
        border: !widget.mobile
            ? Border.all(
                color: widget.isAdditive ? LdTheme.of(context).primaryColor : LdTheme.of(context).errorColor,
                width: 1,
              )
            : null,
      ),
      child: Center(
        child: Icon(
          widget.isAdditive ? LucideIcons.plus : LucideIcons.minus,
          size: 12,
          color: LdTheme.of(context).text,
        ),
      ),
    );
  }

  Widget _buildDragRect(BuildContext context, Rect rect) {
    return switch (widget.mobile) {
      true => Container(),
      false => _buildDesktopDragRect(context, rect),
    };
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) {
        final rect = _dragRect;
        if (rect == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            ModalBarrier(
              dismissible: true,
              color: Colors.transparent,
              onDismiss: () {
                widget.onCancel();
              },
            ),
            Positioned(
              left: rect.left,
              top: rect.top,
              child: _buildDragRect(context, rect),
            ),
          ],
        );
      },
      child: switch (widget.mobile) {
        true => _buildMobileGestureDetector(context),
        false => _buildDesktopGestureDetector(context),
      },
    );
  }
}
