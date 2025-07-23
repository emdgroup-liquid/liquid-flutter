import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/conditional_parent.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:provider/provider.dart';

enum LdScaffoldSlot {
  body,
  appBar,
  bottomNavigationBar,
  drawer,
}

class LdScaffoldLayoutState {
  final bool hasDrawer;
  final bool isDrawerOpen;
  final bool isSideBySide;
  final ValueNotifier<double> bodyScrollOffset;
  final ValueNotifier<double> drawerScrollOffset;
  final LdScaffoldSlot slot;
  final int level;

  const LdScaffoldLayoutState({
    required this.hasDrawer,
    required this.isDrawerOpen,
    required this.isSideBySide,
    required this.slot,
    required this.bodyScrollOffset,
    required this.drawerScrollOffset,
    required this.level,
  });

  LdScaffoldLayoutState copyWith({
    bool? hasDrawer,
    bool? isDrawerOpen,
    ValueNotifier<double>? bodyScrollOffset,
    ValueNotifier<double>? drawerScrollOffset,
    bool? isSideBySide,
    LdScaffoldSlot? slot,
    int? level,
  }) {
    return LdScaffoldLayoutState(
      level: level ?? this.level,
      bodyScrollOffset: bodyScrollOffset ?? this.bodyScrollOffset,
      drawerScrollOffset: drawerScrollOffset ?? this.drawerScrollOffset,
      hasDrawer: hasDrawer ?? this.hasDrawer,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      isSideBySide: isSideBySide ?? this.isSideBySide,
      slot: slot ?? this.slot,
    );
  }

  @override
  String toString() {
    return 'LdScaffoldLayoutState(hasDrawer: $hasDrawer, isDrawerOpen: $isDrawerOpen, isSideBySide: $isSideBySide, slot: $slot)';
  }
}

class LdScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final Widget? drawer;
  final double drawerWidth;
  final bool? autoLayoutBody;
  final double? reflowBreakpoint;

  const LdScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.autoLayoutBody = true,
    this.drawer,
    this.drawerWidth = 304,
    this.reflowBreakpoint = 900,
  });

  @override
  State<LdScaffold> createState() => LdScaffoldState();
}

class LdScaffoldState extends State<LdScaffold> {
  final _appBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));
  final _bottomNavigationBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));

  final StreamController<bool> _drawerStreamController = StreamController<bool>.broadcast();

  final _bodyScrollOffset = ValueNotifier<double>(0);
  final _drawerScrollOffset = ValueNotifier<double>(0);
  bool _isSideBySide = false;

  Stream<bool> get drawerStream => _drawerStreamController.stream;

  @override
  void didUpdateWidget(LdScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) {
      _appBarSizeNotifier.value = Size.zero;
    }
    if (widget.bottomNavigationBar == null) {
      _bottomNavigationBarSizeNotifier.value = Size.zero;
    }
  }

  double _drawerOffset = 0;

  bool _isDragging = false;

  bool get _isDrawerOpen => _drawerOffset > widget.drawerWidth / 2;

  bool get hasDrawer => widget.drawer != null;

  double _effectiveDrawerWidth = 0;

  void openDrawer() {
    _ensureHistoryEntry();

    setState(() {
      _drawerOffset = _effectiveDrawerWidth;
    });
  }

  void closeDrawer() {
    _historyEntry?.remove();
  }

  LocalHistoryEntry? _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(
          onRemove: _handleHistoryEntryRemoved,
          impliesAppBarDismissal: false,
        );
        route.addLocalHistoryEntry(_historyEntry!);
        FocusScope.of(context).setFirstFocus(_focusScopeNode);
        _drawerStreamController.add(true);
      }
    }
  }

  void _handleHistoryEntryRemoved() {
    setState(() {
      _drawerOffset = 0;
      _drawerStreamController.add(false);
    });

    _historyEntry = null;

    FocusScope.of(context).unfocus();
  }

  void _onDragEnd() {
    if (_isDragging) {
      _isDragging = false;

      if (_drawerOffset > _effectiveDrawerWidth / 2) {
        _ensureHistoryEntry();
        setState(() {
          _drawerOffset = _effectiveDrawerWidth;
        });
      } else {
        _handleHistoryEntryRemoved();
        setState(() {
          _drawerOffset = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _drawerStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return LdSpring(
        mass: 1,
        springConstant: 12,
        dampingCoefficient: 5,
        initialPosition: _drawerOffset,
        position: _drawerOffset,
        child: widget.body,
        builder: (context, state, body) {
          return LayoutBuilder(
            builder: (context, constraints) {
              _isSideBySide = constraints.maxWidth >= widget.reflowBreakpoint! && widget.drawer != null;

              final mediaQuery = MediaQuery.of(context);
              final drawerInset = 0.0;
              final bodyInset = 0.0;

              print(mediaQuery.viewPadding.bottom);

              Border? drawerBorder;

              BorderRadius drawerRadius = BorderRadius.circular(0);

              Color backgroundColor;

              final level = (context.read<LdScaffoldLayoutState?>()?.level ?? 0) + 1;

              _effectiveDrawerWidth = widget.drawerWidth + MediaQuery.of(context).padding.left;
              double drawerLeft, drawerWidth, bodyLeft;

              if (_isSideBySide) {
                drawerLeft = state.position - _effectiveDrawerWidth;
                drawerWidth = _effectiveDrawerWidth;
                bodyLeft = state.position;
                backgroundColor = theme.surface;
              } else {
                drawerLeft = state.position - _effectiveDrawerWidth;
                drawerWidth = widget.drawerWidth;
                bodyLeft = 0;
                backgroundColor = theme.background;
              }

              if (widget.backgroundColor != null) {
                backgroundColor = widget.backgroundColor!;
              }

              final layoutState = LdScaffoldLayoutState(
                level: level,
                hasDrawer: hasDrawer,
                isDrawerOpen: _isDrawerOpen,
                isSideBySide: _isSideBySide,
                slot: LdScaffoldSlot.body,
                bodyScrollOffset: _bodyScrollOffset,
                drawerScrollOffset: _drawerScrollOffset,
              );

              return Material(
                type: MaterialType.transparency,
                child: ColoredBox(
                  color: backgroundColor,
                  child: ValueListenableBuilder(
                      valueListenable: _bottomNavigationBarSizeNotifier,
                      builder: (context, bottomNavigationBarSize, child) {
                        return ValueListenableBuilder(
                            valueListenable: _appBarSizeNotifier,
                            builder: (context, appBarSize, child) {
                              return LdWrapConditional(
                                condition: widget.drawer != null,
                                builder: (context, child) => GestureDetector(
                                  onHorizontalDragStart: (details) {
                                    if (widget.drawer == null) return;
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    if (!_isDragging && (details.localPosition.dx - _drawerOffset).abs() <= 75) {
                                      _isDragging = true;
                                    }
                                    if (widget.drawer == null) return;
                                    if (_isDragging) {
                                      setState(() {
                                        _drawerOffset = details.localPosition.dx;
                                        _drawerOffset = _drawerOffset.clamp(0, _effectiveDrawerWidth);
                                      });
                                    }
                                  },
                                  onHorizontalDragEnd: (details) {
                                    if (widget.drawer == null) return;
                                    _onDragEnd();
                                  },
                                  child: child,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: bodyLeft,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: bodyInset,
                                          right: bodyInset,
                                          left: 0,
                                          bottom: bodyInset,
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          color: LdTheme.of(context).background,
                                          border: Border.all(
                                            color: LdTheme.of(context).border,
                                            strokeAlign: BorderSide.strokeAlignOutside,
                                            width: 1,
                                          ),
                                          boxShadow: [ldShadowSticky],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Body
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: MediaQuery(
                                                data: MediaQuery.of(context).copyWith(
                                                  viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
                                                  viewInsets: mediaQuery.viewPadding.copyWith(top: 0),
                                                  padding: mediaQuery.padding.copyWith(
                                                    top: appBarSize.height,
                                                    bottom:
                                                        max(bottomNavigationBarSize.height, mediaQuery.padding.bottom),
                                                  ),
                                                ),
                                                child: ScrollNotificationObserver(
                                                  child: _ScrollObserver(
                                                    position: _bodyScrollOffset,
                                                    child: Provider.value(
                                                      value: layoutState.copyWith(slot: LdScaffoldSlot.body),
                                                      child: body!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // AppBar
                                            if (widget.appBar != null)
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: MeasureSize(
                                                  sizeNotifier: _appBarSizeNotifier,
                                                  child: Provider.value(
                                                    value: layoutState.copyWith(slot: LdScaffoldSlot.appBar),
                                                    child: widget.appBar!,
                                                  ),
                                                ),
                                              ),
                                            // Bottom Navigation Bar
                                            if (widget.bottomNavigationBar != null)
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: MeasureSize(
                                                  sizeNotifier: _bottomNavigationBarSizeNotifier,
                                                  child: Provider.value(
                                                    value: layoutState.copyWith(
                                                      slot: LdScaffoldSlot.bottomNavigationBar,
                                                    ),
                                                    child: widget.bottomNavigationBar!,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Drawer backdrop
                                    if (_isDrawerOpen && !_isSideBySide)
                                      ModalBarrier(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        onDismiss: () {
                                          closeDrawer();
                                        },
                                      ),
                                    // Drawer
                                    if (widget.drawer != null)
                                      Positioned(
                                        top: 0,
                                        left: drawerLeft,
                                        width: drawerWidth,
                                        bottom: 0,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 0,
                                            right: 0,
                                            top: drawerInset,
                                            bottom: drawerInset,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius: drawerRadius,
                                            color: _isSideBySide ? null : LdTheme.of(context).surface,
                                            border: drawerBorder,
                                            boxShadow: _isSideBySide ? null : [ldShadowSticky],
                                          ),
                                          child: Provider.value(
                                            value: layoutState.copyWith(slot: LdScaffoldSlot.drawer),
                                            child: SafeArea(
                                              top: false,
                                              bottom: false,
                                              child: RepaintBoundary(
                                                child: FocusScope(
                                                  node: _focusScopeNode,
                                                  child: ScrollNotificationObserver(
                                                    child: _ScrollObserver(
                                                      position: _drawerScrollOffset,
                                                      child: widget.drawer!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ].reverseIf(_isSideBySide),
                                ),
                              );
                            });
                      }),
                ),
              );
            },
          );
        });
  }
}

class _ScrollObserver extends StatefulWidget {
  final ValueNotifier<double> position;
  final Widget child;

  const _ScrollObserver({required this.position, required this.child});

  @override
  State<_ScrollObserver> createState() => _ScrollObserverState();
}

class _ScrollObserverState extends State<_ScrollObserver> {
  ScrollNotificationObserverState? _scrollNotificationObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
      _scrollNotificationObserver?.addListener(_handleScrollNotification);
    });
  }

  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      final offset = notification.metrics.pixels;
      widget.position.value = offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
