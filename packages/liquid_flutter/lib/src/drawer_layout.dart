import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

class LdDrawerLayout extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final double reflowBreakpoint;
  final bool enableScaling;
  final bool drawerRight;
  final double drawerMinWidth;
  final bool insetBody;

  /// Whether the user may hide the drawer. When false, a side-by-side drawer
  /// is kept open and no close toggle is shown (useful for navigation rails).
  final bool collapsible;

  final void Function(LdDrawerState) onStateChange;

  final double drawerWidth;
  const LdDrawerLayout({
    super.key,
    required this.drawer,
    required this.body,
    required this.reflowBreakpoint,
    required this.drawerWidth,
    required this.drawerMinWidth,
    this.drawerRight = false,
    this.insetBody = false,
    this.enableScaling = false,
    this.collapsible = true,
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

  // `mounted` is still true for the whole duration of dispose() (the
  // element reference isn't cleared until after dispose() returns), even
  // though the element's lifecycle is already defunct at that point. Since
  // dispose() removes the local history entry synchronously, which can
  // synchronously invoke _handleHistoryEntryRemoved -> _hideDrawer ->
  // setState, `mounted` alone isn't a reliable guard here. Track disposal
  // explicitly instead.
  bool _disposed = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onStateChange();
      }
      if (LdTheme.of(context).platform.isDesktop && _isSideBySide) {
        _showDrawer();
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
    _disposed = true;
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
    widget.onStateChange(
      LdDrawerState(
        isOpen: (!widget.collapsible && _isSideBySide) || _panelVisible,
        isSideBySide: _isSideBySide,
        isCollapsible: widget.collapsible,
      ),
    );
  }

  void _handleHistoryEntryRemoved() {
    if (!_disposed && mounted) {
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
    if (_disposed || !mounted) {
      return;
    }
    // A non-collapsible side-by-side drawer cannot be hidden.
    if (!_canCollapse) {
      return;
    }
    setState(() {
      _panelVisible = false;
    });
    _historyEntry?.remove();
    _historyEntry = null;
    _onStateChange();
    LdHaptics.vibrate(HapticsType.light);
  }

  bool get _isDrawerOpen => _panelVisible;

  /// Whether the drawer may currently be hidden. A non-collapsible drawer is
  /// only pinned while laid out side-by-side; in stacked mode it stays a
  /// dismissible overlay.
  bool get _canCollapse => widget.collapsible || !_isSideBySide;

  bool get _insetBody =>
      widget.insetBody || (context.findAncestorStateOfType<LdDrawerLayoutState>()?._insetBody != true && _isSideBySide);

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

            // A non-collapsible drawer is pinned open while side-by-side.
            final effectivePanelVisible = (!widget.collapsible && _isSideBySide) || _panelVisible;
            final drawerState = LdDrawerState(
              isOpen: effectivePanelVisible,
              isSideBySide: _isSideBySide,
              isCollapsible: widget.collapsible,
            );

            return Stack(
              children: [
                LdMultiPanelLayout(
                  insetBody: _insetBody,
                  enableScaling: widget.enableScaling,
                  mode: mode,
                  panelVisible: effectivePanelVisible,
                  onPanelVisibilityChanged: _onPanelVisibilityChanged,
                  panelWidth: _effectiveDrawerWidth,
                  panelPosition: widget.drawerRight ? LdPanelPosition.right : LdPanelPosition.left,
                  allowResize: true,
                  minPanelWidth: widget.drawerMinWidth,
                  mass: 1,
                  springConstant: 12,
                  dampingCoefficient: 9,
                  panel: Provider.value(
                    value: LdDrawerSlot.drawer,
                    child: Provider.value(
                      value: drawerState,
                      child: widget.drawer,
                    ),
                  ),
                  body: Provider.value(
                    value: LdDrawerSlot.body,
                    child: Provider.value(
                      value: drawerState,
                      child: widget.body,
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
