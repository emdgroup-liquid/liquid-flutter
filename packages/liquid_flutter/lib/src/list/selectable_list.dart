// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdSelectableList<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;

  final Widget Function(
    BuildContext context,
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
  State<LdSelectableList<T, IdType>> createState() => _LdSelectableListState<T, IdType>();
}

class _LdSelectableListState<T extends Identifiable<IdType>, IdType> extends State<LdSelectableList<T, IdType>>
    with WidgetsBindingObserver {
  late final _selectedItems = _SetNotifier<IdType>(
    widget.initialSelectedItems,
    widget.multiSelect,
  );

  late final _dragRectItems = _SetNotifier<IdType>(
    <IdType>{},
    true,
  );

  final _changeNotifier = ChangeNotifier();

  final _focusNode = FocusNode();
  late final ScrollController _scrollController;

  final Map<IdType, GlobalKey> _itemKeys = {};
  final Map<IdType, FocusNode> _itemFocusNodes = {};

  final GlobalKey _rootKey = GlobalKey(debugLabel: "Root Key");

  bool _shiftPressed = false;
  bool _ctrlPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _scrollController.dispose();
    _selectedItems.dispose();
    for (final focusNode in _itemFocusNodes.values) {
      focusNode.dispose();
    }
    _itemKeys.clear();
    _itemFocusNodes.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(LdSelectableList<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.multiSelect != widget.multiSelect) {
      _selectedItems.allowMultiple = widget.multiSelect;
    }

    if (oldWidget.initialSelectedItems != widget.initialSelectedItems) {
      _selectedItems.setValue(widget.initialSelectedItems);
      if (widget.initialSelectedItems.length == 1) {
        _itemFocusNodes[widget.initialSelectedItems.first]?.requestFocus();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _shiftPressed = false;
      _ctrlPressed = false;
      setState(() {});
    }
    super.didChangeAppLifecycleState(state);
  }

  bool get isMultiSelect => widget.multiSelect;

  bool _dragIsAdditive = true;

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
    } else if (_ctrlPressed || widget.showSelectionControls) {
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

  bool _isDragging = false;

  void _onUpdateDragRect(Rect dragRect, bool directionIsDownRight) {
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
      } else if (!widget.showSelectionControls) {
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

    setState(() {});
  }

  Future<void> _onEndDrag(Rect rect) async {
    _isDragging = false;

    if (_dragIsAdditive) {
      _selectedItems.addAll(_dragRectItems.value);
    } else {
      _selectedItems.removeAll(_dragRectItems.value);
    }

    _dragRectItems.clear();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 100));
    _focusNode.requestFocus();
  }

  void _onCancel() {
    _isDragging = false;
    _dragRectItems.clear();
    setState(() {});
  }

  void _onFocusChange(bool hasFocus) {}

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
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

    setState(() {});

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
          return KeyEventResult.handled;
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
        return KeyEventResult.handled;
      }
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyA) {
      _selectedItems.setValue(widget.paginator.items.map((e) => e?.id).whereType<IdType>().toSet());
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _selectedItems.clear();
      return KeyEventResult.handled;
    }

    if (isShift || isCtrl) {
      setState(() {});
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  LdList<T, IdType> _defaultListBuilder(BuildContext context, LdListItemBuilder<T> itemBuilder) {
    return LdList(
      paginator: widget.paginator,
      itemBuilder: itemBuilder,
    );
  }

  Widget _wrapListItem(BuildContext context, LdPaginatorItem<T> item, int index) {
    _itemKeys[item.value!.id] ??= GlobalKey(debugLabel: "Selection${item.value!.id}");
    _itemFocusNodes[item.value!.id] ??= FocusNode();

    return AnimatedBuilder(
      animation: _changeNotifier,
      key: _itemKeys[item.value!.id],
      builder: (context, child) {
        final config = LdListItemConfig(
          focusNode: _itemFocusNodes[item.value!.id],
          isSelected: isSelected(item.value!.id),
          selectionControl: switch (widget.showSelectionControls) {
            true => switch (widget.multiSelect) {
                true => LdSelectionControl.checkbox,
                false => LdSelectionControl.radio,
              },
            false => LdSelectionControl.none,
          },
          active: isSelected(item.value!.id),
          onSelectionChanged: (selected) => onSelectionChange(
            item.value!.id,
            selected,
          ),
          onPressed: () => onTap(item.value!.id),
        );
        return LdListItemConfigProvider(
          config: config,
          child: widget.itemBuilder(context, item, index),
        );
      },
    );
  }

  bool get isMobile => LdTheme.of(context).platform.isMobile;

  @override
  Widget build(BuildContext context) {
    final list = LdListConfigProvider(
      config: LdListConfig(
        paginator: widget.paginator,
        scrollController: _scrollController,
      ),
      child: widget.listBuilder?.call(context, _wrapListItem) ?? _defaultListBuilder(context, _wrapListItem),
    );

    if (isMobile) {
      return Stack(
        children: [
          list,
          if (widget.showSelectionControls)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 42,
              child: _DragRect(
                mobile: true,
                onTapOutside: () {
                  if (!_isDragging) {
                    return;
                  }

                  _selectedItems.clear();
                  setState(() {});
                  widget.onSelectionChange?.call({});
                },
                key: _rootKey,
                onUpdateRect: _onUpdateDragRect,
                onEndDrag: _onEndDrag,
                onCancel: _onCancel,
                child: Focus(
                  focusNode: _focusNode,
                  autofocus: true,
                  onFocusChange: _onFocusChange,
                  onKeyEvent: _onKeyEvent,
                  child: Container(),
                ),
              ),
            )
        ],
      );
    }

    return LdWrapConditional(
      condition: widget.multiSelect,
      builder: (context, child) => _DragRect(
        onTapOutside: () {
          if (!_isDragging) {
            return;
          }
          _selectedItems.clear();
          setState(() {});
          widget.onSelectionChange?.call({});
        },
        key: _rootKey,
        onUpdateRect: _onUpdateDragRect,
        onEndDrag: _onEndDrag,
        isAdditive: _dragIsAdditive,
        onCancel: _onCancel,
        child: child,
      ),
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onFocusChange: _onFocusChange,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: list),
            if ((_ctrlPressed || _shiftPressed) && widget.multiSelect)
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
                          if (_ctrlPressed) ...[
                            Row(
                              spacing: LdTheme.of(context).paddingSize(),
                              children: [
                                Icon(LucideIcons.command, size: 16, color: LdTheme.of(context).text),
                                LdText.l(LiquidLocalizations.of(context).ctrlListExplanation)
                              ],
                            ),
                          ],
                          if (_shiftPressed) ...[
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

  void removeAll(Set<T> items) {
    value = {...value}..removeAll(items);
  }

  bool contains(T item) => value.contains(item);
}

class _DragRect extends StatefulWidget {
  final void Function(Rect rect, bool directionIsDownRight) onUpdateRect;
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
        widget.onUpdateRect(rect, false);
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

        widget.onUpdateRect(rect, directionIsDownRight);
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
