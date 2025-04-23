import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSelectableList<T, GroupingCriterion> extends StatefulWidget {
  final Widget Function({
    required BuildContext context,
    required T item,
    required int index,
    required bool selected,
    required bool isMultiSelect,
    required void Function(bool selected) onSelectionChange,
    required VoidCallback onTap,
  }) itemBuilder;

  final LdList<T, GroupingCriterion> Function(
    BuildContext context,
    ScrollController scrollController,
    LdListItemBuilder<T> itemBuilder,
  ) listBuilder;

  final bool multiSelect;

  final LdPaginator<T> paginator;

  const LdSelectableList({
    super.key,
    required this.itemBuilder,
    required this.listBuilder,
    this.multiSelect = false,
    required this.paginator,
  });

  @override
  State<LdSelectableList<T, GroupingCriterion>> createState() => _LdSelectableListState<T, GroupingCriterion>();
}

class _LdSelectableListState<T, GroupingCriterion> extends State<LdSelectableList<T, GroupingCriterion>>
    with ChangeNotifier {
  Set<T> selectedItems = {};

  final FocusNode _focusNode = FocusNode();

  late final ScrollController _scrollController;

  final OverlayPortalController _overlayPortalController = OverlayPortalController();

  Offset? _dragStartOffset = Offset.zero;
  Offset? _dragEndOffset = Offset.zero;

  final Map<T, GlobalKey> _itemKeys = {};

  final GlobalKey _rootKey = GlobalKey();

  bool _shiftPressed = false;
  bool _ctrlPressed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  bool get isMultiSelect => widget.multiSelect;

  bool isSelected(T item) {
    return selectedItems.contains(item);
  }

  void onTap(T item) {
    if (!isMultiSelect) {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems = {item};
      }
      notifyListeners();
      return;
    }

    if (selectedItems.isEmpty) {
      selectedItems.add(item);
    } else {
      if (_shiftPressed) {
        final index = widget.paginator.items.indexOf(item);
        final startIndex = widget.paginator.items.indexOf(selectedItems.last);

        for (var i = min(startIndex, index); i <= max(startIndex, index); i++) {
          final item = widget.paginator.items[i];
          if (item != null) {
            selectedItems.add(item);
          }
        }
      } else if (_ctrlPressed) {
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          selectedItems.add(item);
        }
      } else {
        selectedItems = {item};
      }
    }

    notifyListeners();
  }

  Rect? _dragRect() {
    if (_dragStartOffset == null || _dragEndOffset == null) {
      return null;
    }

    final start = _dragStartOffset!;
    final end = _dragEndOffset!;

    final startX = min(start.dx, end.dx);
    final startY = min(start.dy, end.dy);
    final endX = max(start.dx, end.dx);
    final endY = max(start.dy, end.dy);

    return Rect.fromLTWH(
      startX,
      startY,
      (endX - startX).abs(),
      (endY - startY).abs(),
    );
  }

  bool _isWithinDragRect(Rect rect) {
    final dragRect = _dragRect();

    if (dragRect == null) {
      return false;
    }

    return dragRect.overlaps(rect);
  }

  void onSelectionChange(T item, bool selected) {
    if (isMultiSelect) {
      if (selected) {
        if (_shiftPressed) {
          final index = widget.paginator.items.indexOf(item);
          final startIndex = widget.paginator.items.indexOf(selectedItems.last);

          for (var i = min(startIndex, index); i <= max(startIndex, index); i++) {
            final item = widget.paginator.items[i];
            if (item != null) {
              selectedItems.add(item);
            }
          }
        } else {
          selectedItems.add(item);
        }
      } else {
        selectedItems.remove(item);
      }
    } else {
      if (selected) {
        selectedItems = {item};
      } else {
        selectedItems.clear();
      }
    }

    notifyListeners();
  }

  void clearSelection() {
    selectedItems.clear();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.targetsRootOverlay(
      key: _rootKey,
      controller: _overlayPortalController,
      overlayChildBuilder: (context) {
        if (_dragStartOffset == null || _dragEndOffset == null) {
          return const SizedBox.shrink();
        }

        final sizeX = (_dragEndOffset!.dx - _dragStartOffset!.dx).abs();
        final sizeY = (_dragEndOffset!.dy - _dragStartOffset!.dy).abs();

        return Positioned(
          left: min(_dragStartOffset!.dx, _dragEndOffset!.dx),
          top: min(_dragStartOffset!.dy, _dragEndOffset!.dy),
          child: Container(
            width: sizeX,
            height: sizeY,
            decoration: BoxDecoration(
              border: Border.all(
                color: LdTheme.of(context).primaryColor,
                width: 1,
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onPanStart: (details) {
          _dragStartOffset = details.globalPosition;
          _overlayPortalController.show();
          _dragEndOffset = null;
        },
        onPanUpdate: (details) {
          _dragEndOffset = details.globalPosition;

          // Check if we are close to the bottom of the list

          for (final item in _itemKeys.entries) {
            final box = item.value.currentContext?.findRenderObject() as RenderBox?;

            if (box == null) continue;

            final globalRect = box.localToGlobal(Offset.zero);

            final rect = Rect.fromLTWH(
              globalRect.dx,
              globalRect.dy,
              box.size.width,
              box.size.height,
            );

            if (_isWithinDragRect(rect)) {
              selectedItems.add(item.key);
            } else {
              selectedItems.remove(item.key);
            }
          }

          setState(() {});
        },
        onPanCancel: () {
          if (_dragStartOffset != null) {
            _dragEndOffset = null;
            _overlayPortalController.hide();
            _dragStartOffset = null;
            selectedItems.clear();
            notifyListeners();
          }
        },
        onPanEnd: (details) {
          _dragEndOffset = null;
          _overlayPortalController.hide();
          _dragStartOffset = null;
        },
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
              _shiftPressed = event is KeyDownEvent;
            }
            if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
                event.logicalKey == LogicalKeyboardKey.controlRight ||
                event.logicalKey == LogicalKeyboardKey.metaLeft ||
                event.logicalKey == LogicalKeyboardKey.metaRight) {
              _ctrlPressed = event is KeyDownEvent;
            }
          },
          child: widget.listBuilder(context, _scrollController, (context, item, index) {
            if (!_itemKeys.containsKey(item)) {
              _itemKeys[item] = GlobalKey();
            }

            return AnimatedBuilder(
                animation: this,
                key: _itemKeys[index],
                builder: (context, child) {
                  return widget.itemBuilder(
                    context: context,
                    item: item,
                    index: index,
                    selected: isSelected(item),
                    isMultiSelect: isMultiSelect,
                    onSelectionChange: (selected) => onSelectionChange(item, selected),
                    onTap: () => onTap(item),
                  );
                });
          }),
        ),
      ),
    );
  }
}
