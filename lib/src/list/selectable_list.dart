// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/identifiable.dart';

class LdSelectableList<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatefulWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index, LdListItemConfig config) itemBuilder;

  final LdList<T, IdType, GroupingCriterion> Function(
    BuildContext context,
    ScrollController scrollController,
    LdListItemBuilder<T> itemBuilder,
  )? listBuilder;

  final Set<IdType> initialSelectedItems;
  final bool multiSelect;

  final LdPaginator<T, IdType> paginator;

  final void Function(Set<IdType> selectedItems)? onSelectionChange;

  final bool showSelectionControls;

  const LdSelectableList({
    super.key,
    required this.itemBuilder,
    this.listBuilder,
    this.onSelectionChange,
    this.multiSelect = false,
    required this.paginator,
    this.showSelectionControls = false,
    this.initialSelectedItems = const {},
  });

  @override
  State<LdSelectableList<T, IdType, GroupingCriterion>> createState() =>
      _LdSelectableListState<T, IdType, GroupingCriterion>();
}

class _LdSelectableListState<T extends Identifiable<IdType>, IdType, GroupingCriterion>
    extends State<LdSelectableList<T, IdType, GroupingCriterion>> {
  late final _selectedItems = _SetNotifier<IdType>(
    widget.initialSelectedItems,
    widget.multiSelect,
  );

  late final _dragRectItems = _SetNotifier<IdType>(
    {},
    true,
  );

  final _changeNotifier = ChangeNotifier();

  final _focusNode = FocusNode();
  late final ScrollController _scrollController;

  final Map<IdType, GlobalKey> _itemKeys = {};
  final Map<IdType, FocusNode> _itemFocusNodes = {};

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

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _shiftPressed = false;
        _ctrlPressed = false;
      }
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
  void didUpdateWidget(LdSelectableList<T, IdType, GroupingCriterion> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.multiSelect != widget.multiSelect) {
      _selectedItems.allowMultiple = widget.multiSelect;
    }

    if (oldWidget.initialSelectedItems != widget.initialSelectedItems) {
      _selectedItems.setValue(widget.initialSelectedItems);
    }
  }

  bool get isMultiSelect => widget.multiSelect;

  bool isSelected(IdType item) {
    if (_ctrlPressed || _shiftPressed || widget.showSelectionControls) {
      return _selectedItems.contains(item) || _dragRectItems.contains(item);
    }
    if (_dragRectItems.value.isNotEmpty) {
      return _dragRectItems.contains(item);
    }
    return _selectedItems.contains(item);
  }

  // Called when the user taps an item
  void onTap(IdType item) {
    _focusNode.requestFocus();
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
      _selectedItems.setValue({item});
    }
  }

  // Selects all items between the last selected item and the given item
  void _selectRange(IdType end) {
    if (_selectedItems.value.isEmpty) {
      _selectedItems.add(end);
      return;
    }

    final start = _selectedItems.value.last;
    final startIndex = widget.paginator.getItemIndexById(start);
    final endIndex = widget.paginator.getItemIndexById(end);

    if (startIndex == null || endIndex == null) {
      return;
    }

    var added = <IdType>[];

    for (var i = min(startIndex, endIndex); i <= max(startIndex, endIndex); i++) {
      final item = widget.paginator.getItemAt(i);
      if (item != null) {
        added.add(item.value!.id);
      }
    }

    _selectedItems.addAll(added.toSet());
  }

  // Called when the user selects an item using the checkbox or radio
  void onSelectionChange(IdType item, bool selected) {
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
      } else if (!widget.showSelectionControls) {
        _dragRectItems.remove(item.key);
      }
    }
    setState(() {});
  }

  void _onEndDrag(Rect rect) {
    if (_shiftPressed || _ctrlPressed || widget.showSelectionControls) {
      _selectedItems.addAll(_dragRectItems.value);
    } else {
      _selectedItems.setValue(_dragRectItems.value);
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
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // Get the item that has the focus
      for (final item in _itemFocusNodes.entries) {
        if (item.value.hasFocus) {
          // Add the next item to the selection
          final currentIndex = widget.paginator.getItemIndexById(item.key);

          if (currentIndex != null) {
            final nextIndex = currentIndex + 1;
            final nextItem = widget.paginator.getItemAt(nextIndex);
            if (nextItem != null && nextItem.value != null) {
              if (_shiftPressed) {
                _itemFocusNodes[nextItem.value!.id]?.requestFocus();
                _selectRange(nextItem.value!.id);
              }
            }
          }
          break;
        }
      }
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // Get the item that has the focus
      for (final item in _itemFocusNodes.entries) {
        if (item.value.hasFocus) {
          // Add the next item to the selection
          final currentIndex = widget.paginator.getItemIndexById(item.key);
          if (currentIndex != null) {
            final nextIndex = currentIndex - 1;
            final nextItem = widget.paginator.getItemAt(nextIndex);
            if (nextItem != null && nextItem.value != null) {
              if (_shiftPressed) {
                _itemFocusNodes[nextItem.value!.id]?.requestFocus();
                _selectRange(nextItem.value!.id);
              }
            }
          }
        }
        break;
      }
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyA) {
      _selectedItems.setValue(widget.paginator.items.map((e) => e?.id).whereType<IdType>().toSet());
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _selectedItems.clear();
    }

    if (isShift || isCtrl) {
      setState(() {});
    }
  }

  LdList<T, IdType, GroupingCriterion> _defaultListBuilder(
      BuildContext context, ScrollController scrollController, LdListItemBuilder<T> itemBuilder) {
    return LdList(
      paginator: widget.paginator,
      scrollController: scrollController,
      itemBuilder: itemBuilder,
    );
  }

  Widget _wrapListItem(BuildContext context, LdPaginatorItem<T> item, int index) {
    if (!_itemKeys.containsKey(item.value!.id)) {
      _itemKeys[item.value!.id] = GlobalKey();
    }

    if (!_itemFocusNodes.containsKey(item.value!.id)) {
      _itemFocusNodes[item.value!.id] = FocusNode();
    }

    return AnimatedBuilder(
      animation: _changeNotifier,
      key: _itemKeys[item.value!.id],
      builder: (context, child) {
        return widget.itemBuilder(
          context,
          item,
          index,
          LdListItemConfig(
            focusNode: _itemFocusNodes[item.value!.id],
            isSelected: isSelected(item.value!.id),
            active: isSelected(item.value!.id),
            onSelectionChange: (selected) => onSelectionChange(
              item.value!.id,
              selected,
            ),
            onTap: () => onTap(item.value!.id),
            showSelectionControls: widget.showSelectionControls,
          ),
        );
      },
    );
  }

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    if (widget.showSelectionControls && isMobile) {
      return Stack(
        children: [
          widget.listBuilder?.call(context, _scrollController, _wrapListItem) ??
              _defaultListBuilder(
                context,
                _scrollController,
                _wrapListItem,
              ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 42,
            child: _DragRect(
              drawBorder: false,
              onTapOutside: () {
                _selectedItems.clear();
                setState(() {});
                widget.onSelectionChange?.call({});
              },
              key: _rootKey,
              onUpdateRect: _onUpdateDragRect,
              onEndDrag: _onEndDrag,
              onCancel: _onCancel,
              child: KeyboardListener(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: _onKeyEvent,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          )
        ],
      );
    }

    return _DragRect(
      onTapOutside: () {
        _selectedItems.clear();
        setState(() {});
        widget.onSelectionChange?.call({});
      },
      key: _rootKey,
      onUpdateRect: _onUpdateDragRect,
      onEndDrag: _onEndDrag,
      onCancel: _onCancel,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: widget.listBuilder?.call(context, _scrollController, _wrapListItem) ??
            _defaultListBuilder(
              context,
              _scrollController,
              _wrapListItem,
            ),
      ),
    );
  }
}

class _SetNotifier<T> extends ValueNotifier<Set<T>> {
  _SetNotifier([Set<T>? value, this.allowMultiple = false]) : super(value ?? {});

  bool allowMultiple;

  void setValue(Set<T> value) {
    this.value = value;
  }

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
  final void Function() onTapOutside;
  final bool drawBorder;

  final Widget child;

  const _DragRect({
    required this.onTapOutside,
    required this.onUpdateRect,
    required this.onEndDrag,
    this.drawBorder = true,
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
              border: widget.drawBorder
                  ? Border.all(
                      color: LdTheme.of(context).primaryColor,
                      width: 1,
                    )
                  : null,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          widget.onTapOutside();
        },
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
