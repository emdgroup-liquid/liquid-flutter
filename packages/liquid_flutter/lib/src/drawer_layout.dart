import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:liquid_flutter/src/monkey/actions/drawer_actions.dart';
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

  static void openDrawer(BuildContext context) {
    maybeStateOf(context)?.openDrawer();
  }

  static void closeDrawer(BuildContext context) {
    maybeStateOf(context)?.closeDrawer();
  }

  static void toggleDrawer(BuildContext context) {
    maybeStateOf(context)?.toggleDrawer();
  }
}

class LdDrawerLayoutState extends State<LdDrawerLayout> {
  LocalHistoryEntry? _historyEntry;

  bool _panelVisible = false;
  double _effectiveDrawerWidth = 0;
  bool _isSideBySide = false;

  @override
  initState() {
    super.initState();
    if (LdTheme.of(context).platform.isDesktop) {
      _panelVisible = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onStateChange();
      }
    });
  }

  void openDrawer() {
    _showDrawer();
  }

  void closeDrawer() {
    _hideDrawer();
  }

  void toggleDrawer() {
    if (_panelVisible) {
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

  void _onPanelVisibilityChanged(bool visible) {
    if (_panelVisible != visible) {
      setState(() {
        _panelVisible = visible;
      });
    }
    if (visible) {
      _ensureHistoryEntry();
    } else {
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
    widget.onStateChange(LdDrawerState(isOpen: _panelVisible, isSideBySide: _isSideBySide));
  }

  void _handleHistoryEntryRemoved() {
    if (mounted) {
      _hideDrawer();
    }
  }

  void _showDrawer() {
    setState(() {
      _panelVisible = true;
    });
    _ensureHistoryEntry();
    _onStateChange();
    LdHaptics.vibrate(HapticsType.light);
  }

  void _hideDrawer() {
    setState(() {
      _panelVisible = false;
    });
    _historyEntry?.remove();
    _historyEntry = null;
    _onStateChange();
    LdHaptics.vibrate(HapticsType.light);
  }

  bool get _isDrawerOpen => _panelVisible;

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
                  mode: mode,
                  panelVisible: _panelVisible,
                  onPanelVisibilityChanged: _onPanelVisibilityChanged,
                  panelWidth: _effectiveDrawerWidth,
                  panelPosition: LdPanelPosition.left,
                  allowResize: false,
                  mass: 1,
                  springConstant: 12,
                  dampingCoefficient: 9,
                  panel: Provider.value(
                    value: LdDrawerSlot.drawer,
                    child: Provider.value(
                      value: LdDrawerState(
                        isOpen: _isDrawerOpen,
                        isSideBySide: _isSideBySide,
                      ),
                      child: widget.drawer,
                    ),
                  ),
                  body: Provider.value(
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
