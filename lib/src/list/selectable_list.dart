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

  final void Function(Set<T> selectedItems)? onSelectionChange;

  const LdSelectableList({
    super.key,
    required this.itemBuilder,
    required this.listBuilder,
    this.onSelectionChange,
    this.multiSelect = false,
    required this.paginator,
  });

  @override
  State<LdSelectableList<T, GroupingCriterion>> createState() =>
      _LdSelectableListState<T, GroupingCriterion>();
}

class _LdSelectableListState<T, GroupingCriterion>
    extends State<LdSelectableList<T, GroupingCriterion>> {
  late final _selectedItems = _SetNotifier<T>(
    {},
    widget.multiSelect,
  );

  late final _dragRectItems = _SetNotifier<T>(
    {},
    true,
  );

  final _changeNotifier = ChangeNotifier();

  final _focusNode = FocusNode();
  late final ScrollController _scrollController;

  final Map<T, GlobalKey> _itemKeys = {};

  final GlobalKey _rootKey = GlobalKey();

  bool _shiftPressed = false;
  bool _ctrlPressed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedItems.addListener(() {
      widget.onSelectionChange?.call(_selectedItems.value);

      _changeNotifier.notifyListeners();
    });
    _dragRectItems.addListener(() {
      _changeNotifier.notifyListeners();
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _changeNotifier.notifyListeners();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _selectedItems.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LdSelectableList<T, GroupingCriterion> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.multiSelect != widget.multiSelect) {
      _selectedItems.allowMultiple = widget.multiSelect;
    }
  }

  bool get isMultiSelect => widget.multiSelect;

  bool isSelected(T item) {
    if (_ctrlPressed || _shiftPressed) {
      return _selectedItems.contains(item) || _dragRectItems.contains(item);
    }
    if (_dragRectItems.value.isNotEmpty) {
      return _dragRectItems.contains(item);
    }
    return _selectedItems.contains(item);
  }

  // Called when the user taps an item
  void onTap(T item) {
    if (!isMultiSelect) {
      _selectedItems.toggle(item);
      return;
    }

    // We allow multi select and the user is holding shift
    // We select all items between the last selected item and the current item
    if (_shiftPressed) {
      _selectRange(item);
    } else if (_ctrlPressed) {
      // We allow multi select and the user is holding ctrl, therefore we toggle the item
      // while keeping the other selected items
      _selectedItems.toggle(item);
    } else {
      // Only select the item the user tapped
      _selectedItems.clear();
      _selectedItems.add(item);
    }
  }

  // Selects all items between the last selected item and the given item
  void _selectRange(T end) {
    final start = _selectedItems.value.last;
    final startIndex = widget.paginator.items.indexOf(start);
    final endIndex = widget.paginator.items.indexOf(end);

    for (var i = min(startIndex, endIndex);
        i <= max(startIndex, endIndex);
        i++) {
      final item = widget.paginator.items[i];
      if (item != null) {
        _selectedItems.add(item);
      }
    }
  }

  // Called when the user selects an item using the checkbox or radio
  void onSelectionChange(T item, bool selected) {
    if (isMultiSelect) {
      if (selected) {
        if (_shiftPressed) {
          _selectRange(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        _selectedItems.remove(item);
      }
    } else {
      if (selected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.clear();
      }
    }
  }

  void _onUpdateDragRect(Rect dragRect) {
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

      if (dragRect.overlaps(rect)) {
        _dragRectItems.add(item.key);
      } else {
        _dragRectItems.remove(item.key);
      }
    }
    setState(() {});
  }

  void _onEndDrag(Rect rect) {
    if (_shiftPressed || _ctrlPressed) {
      _selectedItems.addAll(_dragRectItems.value);
    } else {
      _selectedItems.clear();
      _selectedItems.addAll(_dragRectItems.value);
    }
    _dragRectItems.clear();
    setState(() {});
  }

  void _onCancel() {
    _dragRectItems.clear();
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event) {
    bool isShift = {
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.shift,
    }.contains(event.logicalKey);

    bool isCtrl = {
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
    }.contains(event.logicalKey);

    if (isShift) {
      _shiftPressed = event is KeyDownEvent;
    }

    if (isCtrl) {
      _ctrlPressed = event is KeyDownEvent;
    }

    if (isShift || isCtrl) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DragRect(
        key: _rootKey,
        onUpdateRect: _onUpdateDragRect,
        onEndDrag: _onEndDrag,
        onCancel: _onCancel,
        child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: widget.listBuilder(context, _scrollController,
                (context, item, index) {
              if (!_itemKeys.containsKey(item)) {
                _itemKeys[item] = GlobalKey();
              }

              return AnimatedBuilder(
                  animation: _changeNotifier,
                  key: _itemKeys[item],
                  builder: (context, child) {
                    return widget.itemBuilder(
                      context: context,
                      item: item,
                      index: index,
                      selected: isSelected(item),
                      isMultiSelect: isMultiSelect,
                      onSelectionChange: (selected) => onSelectionChange(
                        item,
                        selected,
                      ),
                      onTap: () => onTap(item),
                    );
                  });
            })));
  }
}

class _SetNotifier<T> extends ValueNotifier<Set<T>> {
  _SetNotifier([Set<T>? value, this.allowMultiple = false])
      : super(value ?? {});

  bool allowMultiple;

  void add(T item) {
    if (allowMultiple) {
      value = {...value, item};
    } else {
      value = {item};
    }
  }

  void toggle(T item) {
    if (contains(item)) {
      remove(item);
    } else {
      add(item);
    }
  }

  void remove(T item) {
    value = {...value}..remove(item);
  }

  void clear() {
    value = {};
  }

  void addAll(Set<T> items) {
    if (allowMultiple) {
      value = {...value, ...items};
    } else {
      value = {items.first};
    }
  }

  bool contains(T item) => value.contains(item);
}

class _DragRect extends StatefulWidget {
  final void Function(Rect rect) onUpdateRect;
  final void Function(Rect rect) onEndDrag;
  final void Function() onCancel;

  final Widget child;

  const _DragRect({
    required this.onUpdateRect,
    required this.onEndDrag,
    required this.child,
    required this.onCancel,
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

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.targetsRootOverlay(
      controller: _overlayPortalController,
      overlayChildBuilder: (context) {
        final rect = _dragRect;
        if (rect == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: rect.left,
          top: rect.top,
          child: Container(
            width: rect.width,
            height: rect.height,
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
          final rect = _dragRect;
          if (rect == null) {
            return;
          }
          widget.onUpdateRect(rect);
        },
        onPanCancel: () {
          if (_dragStartOffset != null) {
            _dragEndOffset = null;
            _overlayPortalController.hide();
            _dragStartOffset = null;
            widget.onCancel();
          }
        },
        onPanEnd: (details) {
          final rect = _dragRect;
          if (rect == null) {
            return;
          }

          _dragEndOffset = null;
          _overlayPortalController.hide();
          _dragStartOffset = null;
          widget.onEndDrag(rect);
        },
        child: widget.child,
      ),
    );
  }
}
