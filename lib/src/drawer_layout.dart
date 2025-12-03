import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_state.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

class LdDrawerLayout extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final double reflowBreakpoint;
  final Stream<Intent> intents;
  final void Function(LdDrawerState) onStateChange;

  final double drawerWidth;
  const LdDrawerLayout({
    super.key,
    required this.drawer,
    required this.body,
    required this.reflowBreakpoint,
    required this.drawerWidth,
    required this.onStateChange,
    required this.intents,
  });

  @override
  State<LdDrawerLayout> createState() => _LdDrawerLayoutState();
}

class _LdDrawerLayoutState extends State<LdDrawerLayout> {
  bool _isDragging = false;
  LocalHistoryEntry? _historyEntry;

  double _drawerOffset = 0;
  double _effectiveDrawerWidth = 0;
  bool _isSideBySide = false;

  StreamSubscription<Intent>? _intentSubscription;

  @override
  initState() {
    super.initState();
    _intentSubscription = widget.intents.listen(_handleIntent);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isSideBySide) {
        _showDrawer();
      }
    });
  }

  void _handleIntent(Intent intent) {
    if (intent is OpenDrawerIntent) {
      _showDrawer();
    } else if (intent is CloseDrawerIntent) {
      _hideDrawer();
    } else if (intent is ToggleDrawerIntent) {
      if (_isDrawerOpen) {
        _hideDrawer();
      } else {
        _showDrawer();
      }
    }
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    _historyEntry?.remove();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isDragging) {
      _isDragging = false;
    }
    if (_drawerOffset > _effectiveDrawerWidth / 2) {
      _ensureHistoryEntry();
      setState(() {
        _drawerOffset = _effectiveDrawerWidth;
      });
    } else {
      _handleHistoryEntryRemoved();
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
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging && (details.localPosition.dx - _drawerOffset).abs() <= 75) {
      _isDragging = true;
    }
    if (_isDragging) {
      setState(() {
        _drawerOffset = details.localPosition.dx;
        _drawerOffset = _drawerOffset.clamp(0, _effectiveDrawerWidth);
      });
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
      _drawerOffset = _effectiveDrawerWidth;
    });
    _ensureHistoryEntry();
    _onStateChange();
  }

  void _hideDrawer() {
    setState(() {
      _drawerOffset = 0;
    });
    _historyEntry?.remove();
    _onStateChange();
  }

  bool get _isDrawerOpen => _drawerOffset > _effectiveDrawerWidth / 2;

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
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _isSideBySide = constraints.maxWidth >= widget.reflowBreakpoint;
              _effectiveDrawerWidth = min(constraints.maxWidth * 0.75, widget.drawerWidth);

              return Stack(
                children: [
                  LdSpring(
                    mass: 1,
                    springConstant: 12,
                    dampingCoefficient: 9,
                    initialPosition: 0,
                    position: _drawerOffset,
                    builder: (context, state, child) {
                      double bodyLeft, bodyWidth;
                      if (_isSideBySide) {
                        bodyLeft = state.position;
                        bodyWidth = constraints.maxWidth - state.position;
                      } else {
                        bodyLeft = 0;
                        bodyWidth = constraints.maxWidth;
                      }

                      return Positioned(
                        top: 0,
                        width: bodyWidth,
                        bottom: 0,
                        left: bodyLeft,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              boxShadow: [ldShadowSticky],
                              color: LdTheme.of(context).background,
                            ),
                            child: child!),
                      );
                    },
                    child: Provider.value(
                      value: LdDrawerSlot.body,
                      child: Provider.value(
                        value: LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide),
                        child: widget.body,
                      ),
                    ),
                  ),
                  if (_isDrawerOpen && !_isSideBySide)
                    ModalBarrier(
                      color: Colors.black.withValues(alpha: 0.5),
                      onDismiss: () {
                        _hideDrawer();
                      },
                    ),
                  LdSpring(
                    mass: 1,
                    springConstant: 12,
                    dampingCoefficient: 9,
                    initialPosition: 0,
                    position: _drawerOffset,
                    builder: (context, state, child) {
                      double drawerLeft, drawerWidth;
                      if (_isSideBySide) {
                        drawerLeft = state.position - _effectiveDrawerWidth;
                        drawerWidth = _effectiveDrawerWidth;
                      } else {
                        drawerLeft = min(0, state.position - _effectiveDrawerWidth);
                        drawerWidth = _effectiveDrawerWidth;
                      }

                      return Positioned(
                        top: 0,
                        bottom: 0,
                        width: drawerWidth,
                        left: drawerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            border: _drawerBorder,
                            color: LdTheme.of(context).background,
                          ),
                          child: child!,
                        ),
                      );
                    },
                    child: Provider.value(
                      value: LdDrawerSlot.drawer,
                      child: Provider.value(
                        value: LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide),
                        child: widget.drawer,
                      ),
                    ),
                  )
                ].reverseIf(_isSideBySide),
              );
            },
          ),
        ),
      ),
    );
  }
}

extension on List<Widget> {
  List<Widget> reverseIf(bool condition) {
    if (condition) {
      return reversed.toList();
    }
    return this;
  }
}
