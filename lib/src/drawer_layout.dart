import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_state.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

class LdDrawerLayout extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final double reflowBreakpoint;
  final bool enableScaling;

  final void Function(LdDrawerState) onStateChange;

  final double drawerWidth;
  const LdDrawerLayout({
    super.key,
    required this.drawer,
    required this.body,
    required this.reflowBreakpoint,
    required this.drawerWidth,
    this.enableScaling = false,
    required this.onStateChange,
  });

  @override
  State<LdDrawerLayout> createState() => LdDrawerLayoutState();

  static LdDrawerLayoutState? maybeStateOf(BuildContext context) {
    return context.findAncestorStateOfType<LdDrawerLayoutState>();
  }

  static openDrawer(BuildContext context) {
    maybeStateOf(context)?.openDrawer();
  }

  static closeDrawer(BuildContext context) {
    maybeStateOf(context)?.closeDrawer();
  }

  static toggleDrawer(BuildContext context) {
    maybeStateOf(context)?.toggleDrawer();
  }
}

class LdDrawerLayoutState extends State<LdDrawerLayout> {
  LocalHistoryEntry? _historyEntry;

  int _visibleStartIndex = 1; // Start with only body visible (closed)
  int _visibleEndIndex = 1;
  double _effectiveDrawerWidth = 0;
  bool _isSideBySide = false;

  @override
  initState() {
    super.initState();
  }

  void openDrawer() {
    _showDrawer();
  }

  void closeDrawer() {
    _hideDrawer();
  }

  void toggleDrawer() {
    if (_isDrawerOpen) {
      _hideDrawer();
    } else {
      _showDrawer();
    }
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    super.dispose();
  }

  void _onVisibleRangeChanged(int startIndex, int endIndex) {
    final wasOpen = _isDrawerOpen;
    setState(() {
      _visibleStartIndex = startIndex;
      _visibleEndIndex = endIndex;
    });

    if (_isDrawerOpen && !wasOpen) {
      _ensureHistoryEntry();
    } else if (!_isDrawerOpen && wasOpen) {
      _historyEntry?.remove();
      _historyEntry = null;
    }

    _onStateChange();
  }

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(
          onRemove: _handleHistoryEntryRemoved,
          impliesAppBarDismissal: false,
        );
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  void _onStateChange() {
    widget.onStateChange(LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide));
  }

  void _handleHistoryEntryRemoved() {
    _hideDrawer();
  }

  void _showDrawer() {
    setState(() {
      _visibleStartIndex = 0;
      _visibleEndIndex = 1;
    });
    _ensureHistoryEntry();
    _onStateChange();
    LdHaptics.vibrate(HapticsType.light);
  }

  void _hideDrawer() {
    setState(() {
      _visibleStartIndex = 1;
      _visibleEndIndex = 1;
    });
    _historyEntry?.remove();
    _historyEntry = null;
    _onStateChange();
    LdHaptics.vibrate(HapticsType.light);
  }

  bool get _isDrawerOpen => _visibleStartIndex == 0;

  Border? get _drawerBorder {
    return Border(
      right: BorderSide(
        color: LdTheme.of(context).border,
        width: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Actions(
        actions: {
          ToggleDrawerIntent: ToggleDrawerAction(
            onToggleDrawer: () {
              if (_isDrawerOpen) {
                _hideDrawer();
              } else {
                _showDrawer();
              }
            },
          ),
          OpenDrawerIntent: CallbackAction(
            onInvoke: (intent) {
              _showDrawer();
              return null;
            },
          ),
          CloseDrawerIntent: CallbackAction(
            onInvoke: (intent) {
              _hideDrawer();
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            _isSideBySide = constraints.maxWidth >= widget.reflowBreakpoint;
            _effectiveDrawerWidth = min(constraints.maxWidth * 0.75, widget.drawerWidth);

            final mode = _isSideBySide ? LdMultiPanelLayoutMode.sideBySide : LdMultiPanelLayoutMode.stacked;

            return Stack(
              children: [
                LdMultiPanelLayout(
                  enableScaling: widget.enableScaling,
                  children: [
                    // Drawer panel (index 0)
                    Provider.value(
                      value: LdDrawerSlot.drawer,
                      child: Provider.value(
                        value: LdDrawerState(
                          isOpen: _isDrawerOpen,
                          isSideBySide: _isSideBySide,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: _drawerBorder,
                            color: LdTheme.of(context).background,
                          ),
                          child: widget.drawer,
                        ),
                      ),
                    ),
                    // Body panel (index 1)
                    Provider.value(
                      value: LdDrawerSlot.body,
                      child: Provider.value(
                        value: LdDrawerState(
                          isOpen: _isDrawerOpen,
                          isSideBySide: _isSideBySide,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [ldShadowSticky],
                            color: LdTheme.of(context).background,
                          ),
                          child: widget.body,
                        ),
                      ),
                    ),
                  ],
                  widths: [
                    PanelWidth.fixed(_effectiveDrawerWidth),
                    const PanelWidth.fill(),
                  ],
                  mode: mode,
                  visibleStartIndex: _visibleStartIndex,
                  visibleEndIndex: _visibleEndIndex,
                  onVisibleRangeChanged: _onVisibleRangeChanged,
                  mass: 1,
                  springConstant: 12,
                  dampingCoefficient: 9,
                  spacing: 0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
