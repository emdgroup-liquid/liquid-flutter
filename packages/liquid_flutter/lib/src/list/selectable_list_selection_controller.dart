import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSelectableListSelectionController<T extends Identifiable<IdType>, IdType> extends ChangeNotifier {
  final bool multiSelect;
  final LdPaginator<T, IdType> paginator;

  late final _selectedItems = _SetNotifier<IdType>(
    <IdType>{},
    multiSelect,
  );

  late final _dragRectItems = _SetNotifier<IdType>(
    <IdType>{},
    true,
  );

  final _changeNotifier = ChangeNotifier();

  final Map<IdType, GlobalKey> _itemKeys = {};
  final Map<IdType, FocusNode> _itemFocusNodes = {};

  final FocusNode _focusNode = FocusNode();

  bool _shiftPressed = false;
  bool _ctrlPressed = false;

  LdSelectableListSelectionController({
    required this.multiSelect,
    required this.paginator,
    Set<IdType>? initialSelectedItems,
  }) {
    if (initialSelectedItems != null) {
      _selectedItems.setValue(initialSelectedItems);
    }
    _selectedItems.addListener(_onSelectionChanged);
    _dragRectItems.addListener(_onDragRectChanged);
  }

  void _onSelectionChanged() {
    _changeNotifier.notifyListeners();

    notifyListeners();
  }

  void _onDragRectChanged() {
    _changeNotifier.notifyListeners();
  }

  ChangeNotifier get changeNotifier => _changeNotifier;
  FocusNode get focusNode => _focusNode;
  Set<IdType> get selectedItems => _selectedItems.value;
  bool get isDragging => _isDragging;
  bool get shiftPressed => _shiftPressed;
  bool get ctrlPressed => _ctrlPressed;

  void updateSelectedItems(Set<IdType> items) {
    _selectedItems.setValue(items);
  }

  void setMultiSelect(bool value) {
    _selectedItems.allowMultiple = value;
  }

  bool isSelected(IdType item) {
    if (_dragRectItems.value.isNotEmpty) {
      final contains = _dragRectItems.contains(item);
      if (contains && !_dragIsAdditive) {
        return false;
      } else if (contains && _dragIsAdditive) {
        return true;
      }
    }
    return _selectedItems.contains(item);
  }

  void onTap(IdType item) {
    _focusNode.requestFocus();

    if (!multiSelect) {
      _selectedItems.toggle(item);
      return;
    }

    if (_shiftPressed) {
      _selectRange(item);
    } else if (_ctrlPressed || _showSelectionControls) {
      _selectedItems.toggle(item);
    } else {
      _selectedItems.setValue({item});
    }
  }

  bool _showSelectionControls = false;

  void setShowSelectionControls(bool value) {
    _showSelectionControls = value;
  }

  void _selectRange(IdType end) {
    if (_selectedItems.value.isEmpty) {
      _selectedItems.add(end);
      return;
    }

    final start = _selectedItems.value.last;
    final startIndex = paginator.getItemIndexById(start);
    final endIndex = paginator.getItemIndexById(end);

    if (startIndex == null || endIndex == null) {
      return;
    }

    var added = <IdType>[];

    for (var i = min(startIndex, endIndex); i <= max(startIndex, endIndex); i++) {
      final item = paginator.getItemAt(i);
      if (item != null) {
        added.add(item.value!.id);
      }
    }

    _selectedItems.addAll(added.toSet());
  }

  void onSelectionChange(IdType item, bool selected) {
    if (multiSelect) {
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

  bool _dragIsAdditive = true;
  bool _isDragging = false;

  void onUpdateDragRect(Rect dragRect, bool directionIsDownRight, bool isMobile) {
    if (!_isDragging && !isMobile) {
      if (!_ctrlPressed && !_shiftPressed) {
        _selectedItems.clear();
      }
    }
    _isDragging = true;
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
      } else if (!_showSelectionControls) {
        _dragRectItems.remove(item.key);
      }
    }

    if (isMobile) {
      if (_dragRectItems.value.length == 1) {
        _dragIsAdditive = !_selectedItems.contains(_dragRectItems.value.first);
      }
    } else {
      _dragIsAdditive = directionIsDownRight || _selectedItems.value.isEmpty;
    }
  }

  void onEndDrag() {
    _isDragging = false;

    if (_dragIsAdditive) {
      _selectedItems.addAll(_dragRectItems.value);
    } else {
      _selectedItems.removeAll(_dragRectItems.value);
    }

    _dragRectItems.clear();
    _focusNode.requestFocus();
  }

  void onCancel() {
    _isDragging = false;
    _dragRectItems.clear();
  }

  GlobalKey getKeyForItem(IdType id) {
    return _itemKeys[id] ??= GlobalKey(debugLabel: "Selection$id");
  }

  FocusNode getFocusNodeForItem(IdType id) {
    return _itemFocusNodes[id] ??= FocusNode();
  }

  KeyEventResult onKeyEvent(KeyEvent event, void Function(IdType) selectRange, void Function(IdType) requestFocus) {
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
      print('arrow down');
      for (final item in _itemFocusNodes.entries) {
        if (item.value.hasFocus) {
          print('item: ${item.key}');
          final currentIndex = paginator.getItemIndexById(item.key);

          if (currentIndex != null) {
            final nextIndex = currentIndex + 1;
            final nextItem = paginator.getItemAt(nextIndex);
            if (nextItem != null && nextItem.value != null) {
              if (_shiftPressed) {
                selectRange(nextItem.value!.id);
              }
              requestFocus(nextItem.value!.id);
              return KeyEventResult.handled;
            }
          }
        }
      }
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      print('arrow up');
      for (final item in _itemFocusNodes.entries) {
        if (item.value.hasFocus) {
          print('item: ${item.key}');
          final currentIndex = paginator.getItemIndexById(item.key);

          if (currentIndex != null) {
            final previousIndex = currentIndex - 1;
            final previousItem = paginator.getItemAt(previousIndex);
            print('previousItem: $previousItem');
            if (previousItem != null && previousItem.value != null) {
              if (_shiftPressed) {
                selectRange(previousItem.value!.id);
              }
              requestFocus(previousItem.value!.id);
            }
            return KeyEventResult.handled;
          }
        }
      }
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyA) {
      _selectedItems.setValue(paginator.items.map((e) => e?.id).whereType<IdType>().toSet());
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _selectedItems.clear();
      return KeyEventResult.handled;
    }

    if (isShift || isCtrl) {
      notifyListeners();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _shiftPressed = false;
      _ctrlPressed = false;
    }
  }

  @override
  void dispose() {
    _selectedItems.removeListener(_onSelectionChanged);
    _dragRectItems.removeListener(_onDragRectChanged);
    _focusNode.dispose();
    _selectedItems.dispose();
    for (final focusNode in _itemFocusNodes.values) {
      focusNode.dispose();
    }
    _itemKeys.clear();
    _itemFocusNodes.clear();
    super.dispose();
  }
}

class _SetNotifier<T> extends ValueNotifier<Set<T>> {
  _SetNotifier([Set<T>? value, this.allowMultiple = false]) : super(value ?? {});

  bool allowMultiple;

  void setValue(Set<T> value) {
    if (setEquals(value, this.value)) {
      return;
    }

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

  void removeAll(Set<T> items) {
    value = {...value}..removeAll(items);
  }

  bool contains(T item) => value.contains(item);
}
