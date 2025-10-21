import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

enum LdAppBarScrollBehavior {
  static,
  mobileOnly,
  always,
}

class LdScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? secondaryNavigationBar;

  final Color? backgroundColor;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final double drawerWidth;

  final double? reflowBreakpoint;
  final SingleActivator? toggleDrawerShortcut;
  final LdScaffoldSecondaryNavPlacement secondaryNavPlacement;
  final LdAppBarScrollBehavior appBarScrollBehavior;

  final TextEditingController? searchController;

  const LdScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.toggleDrawerShortcut,
    this.secondaryNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.drawer,
    this.drawerWidth = 304,
    this.reflowBreakpoint = 900,
    this.resizeToAvoidBottomInset,
    this.secondaryNavPlacement = LdScaffoldSecondaryNavPlacement.auto,
    this.appBarScrollBehavior = LdAppBarScrollBehavior.static,
    this.searchController,
  });

  @override
  State<LdScaffold> createState() => LdScaffoldState();
}

class LdScaffoldLayoutState {
  final bool isDrawerOpen;
  final bool isSideBySide;
  final ValueNotifier<double> bodyScrollOffset;
  final ValueNotifier<double> drawerScrollOffset;
  final LdScaffoldSlot slot;
  final LdScaffoldLayoutState? parentLayoutState;

  const LdScaffoldLayoutState({
    required this.isDrawerOpen,
    required this.isSideBySide,
    required this.slot,
    required this.bodyScrollOffset,
    required this.drawerScrollOffset,
    required this.parentLayoutState,
  });

  int get level {
    if (parentLayoutState == null) {
      return 0;
    }
    return parentLayoutState!.level + 1;
  }

  LdScaffoldLayoutState copyWith({
    bool? isDrawerOpen,
    ValueNotifier<double>? bodyScrollOffset,
    ValueNotifier<double>? drawerScrollOffset,
    bool? isSideBySide,
    LdScaffoldSlot? slot,
    LdScaffoldLayoutState? parentLayoutState,
  }) {
    return LdScaffoldLayoutState(
      bodyScrollOffset: bodyScrollOffset ?? this.bodyScrollOffset,
      drawerScrollOffset: drawerScrollOffset ?? this.drawerScrollOffset,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      parentLayoutState: parentLayoutState ?? this.parentLayoutState,
      isSideBySide: isSideBySide ?? this.isSideBySide,
      slot: slot ?? this.slot,
    );
  }

  @override
  String toString() {
    return 'LdScaffoldLayoutState(, isDrawerOpen: $isDrawerOpen, isSideBySide: $isSideBySide, slot: $slot)';
  }
}

enum LdScaffoldSecondaryNavPlacement {
  auto,
  bottom,
  top,
}

enum LdScaffoldSlot {
  body,
  drawer,
  appBar,
  secondaryNavigationBarTop,
  secondaryNavigationBarBottom,
}

class LdScaffoldState extends State<LdScaffold> {
  final _appBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));
  final _secondaryNavigationBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));
  final StreamController<bool> _drawerStreamController = StreamController<bool>.broadcast();
  final StreamController<Intent> _intentRouterController = StreamController.broadcast();

  final _bodyScrollOffset = ValueNotifier<double>(0);

  final _drawerScrollOffset = ValueNotifier<double>(0);
  final _appBarOffset = ValueNotifier<double>(0.0);
  double _lastScrollOffset = 0.0;
  bool _isSideBySide = false;
  final FocusNode _bottomNavigationBarFocusNode = FocusNode();

  double _drawerOffset = 0;

  bool _isDragging = false;

  double _effectiveDrawerWidth = 0;

  LocalHistoryEntry? _historyEntry;

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  Stream<bool> get drawerStream => _drawerStreamController.stream;

  bool get hasDrawer => widget.drawer != null;

  Stream<Intent> get intentRouter => _intentRouterController.stream;

  bool get _isDrawerOpen => _drawerOffset > widget.drawerWidth / 2;

  SingleActivator get toggleDrawerShortcut =>
      widget.toggleDrawerShortcut ??
      const SingleActivator(
        LogicalKeyboardKey.keyS,
        meta: true,
      );

  BoxDecoration? get _scaffoldDecoration {
    final theme = LdTheme.of(context, listen: true);
    Color backgroundColor = widget.backgroundColor ?? theme.surface;

    if (theme.platform == LdPlatform.macos && _layoutState.level == 0) {
      return BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: theme.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(LdTheme.of(context).screenRadius),
      );
    }
    return BoxDecoration(
      color: backgroundColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _appBarSizeNotifier.addListener(_handleAppBarSizeChange);
    _secondaryNavigationBarSizeNotifier.addListener(_handleSecondaryNavigationBarSizeChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isSideBySide && widget.drawer != null) {
        openDrawer();
      }
    });
  }

  void _handleAppBarSizeChange() {
    setState(() {});
  }

  void _handleSecondaryNavigationBarSizeChange() {
    setState(() {});
  }

  LdScaffoldLayoutState? get _parentLayoutState {
    return context.read<LdScaffoldLayoutState?>();
  }

  LdScaffoldLayoutState get _layoutState {
    final parentLayoutState = _parentLayoutState;
    return LdScaffoldLayoutState(
      parentLayoutState: parentLayoutState,
      isDrawerOpen: _isDrawerOpen,
      isSideBySide: _isSideBySide,
      slot: LdScaffoldSlot.body,
      bodyScrollOffset: _bodyScrollOffset,
      drawerScrollOffset: _drawerScrollOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Shortcuts(
      shortcuts: {
        toggleDrawerShortcut: const ToggleDrawerIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchIntent(),
      },
      child: Actions(
        actions: {
          ToggleDrawerIntent: ToggleDrawerAction(
            isActionEnabled: hasDrawer,
            onToggleDrawer: () {
              _intentRouterController.add(const ToggleDrawerIntent());
              if (_isSideBySide) {
                if (_isDrawerOpen) {
                  closeDrawer();
                } else {
                  openDrawer();
                }
              }
            },
          ),
          SearchIntent: CallbackAction(
            onInvoke: (intent) {
              _intentRouterController.add(intent);
              return null;
            },
          )
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            _isSideBySide = constraints.maxWidth >= widget.reflowBreakpoint! && widget.drawer != null;
            return LdSpring(
              mass: 1,
              springConstant: 12,
              dampingCoefficient: 9,
              initialPosition: _drawerOffset,
              position: _drawerOffset,
              child: widget.body,
              builder: (context, state, body) {
                Border? drawerBorder;

                BorderRadius drawerRadius = BorderRadius.circular(0);

                Color backgroundColor;

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
                  drawerBorder = Border(
                    right: BorderSide(
                      color: theme.border,
                      width: 1,
                    ),
                  );
                }

                final bodyTopOffset = _bodyTopOffset(context);
                final bodyBottomOffset = _bodyBottomOffset(context);

                EdgeInsets bodyPadding = MediaQuery.of(context).padding;

                if (!widget.extendBodyBehindAppBar) {
                  bodyPadding = bodyPadding.copyWith(
                    top: max(bodyPadding.top, bodyTopOffset).toDouble(),
                  );

                  if (!_hasTopSecondaryNavigationBar(context)) {
                    bodyPadding = bodyPadding.copyWith(
                      bottom: max(bodyPadding.bottom, bodyBottomOffset),
                    );
                  }
                }

                final layoutState = _layoutState;

                return Material(
                  type: MaterialType.transparency,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: _scaffoldDecoration,
                    child: LdWrapConditional(
                      condition: widget.drawer != null,
                      // Gesture detector for the drawer
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
                          // Body
                          Positioned(
                            top: 0,
                            left: bodyLeft,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: backgroundColor,
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
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        padding: bodyPadding,
                                      ),
                                      child: ScrollNotificationObserver(
                                        child: ScrollObserver(
                                          position: _bodyScrollOffset,
                                          onScrollChange: _handleScrollChange,
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
                                    ValueListenableBuilder<double>(
                                      valueListenable: _appBarOffset,
                                      builder: (context, offset, child) {
                                        return Transform.translate(
                                          offset: Offset(0, offset),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: MeasureSize(
                                              sizeNotifier: _appBarSizeNotifier,
                                              child: Provider.value(
                                                value: layoutState.copyWith(slot: LdScaffoldSlot.appBar),
                                                child: widget.appBar!,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  // Bottom Navigation Bar
                                  if (widget.secondaryNavigationBar != null)
                                    _placeSecondaryNavigationBar(
                                      context,
                                      Focus(
                                        focusNode: _bottomNavigationBarFocusNode,
                                        child: MeasureSize(
                                          sizeNotifier: _secondaryNavigationBarSizeNotifier,
                                          child: Provider.value(
                                            value: layoutState.copyWith(
                                              slot: _hasTopSecondaryNavigationBar(context)
                                                  ? LdScaffoldSlot.secondaryNavigationBarTop
                                                  : LdScaffoldSlot.secondaryNavigationBarBottom,
                                            ),
                                            child: widget.secondaryNavigationBar!,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // AppBar gradient
                          if (widget.appBar != null && _shouldHideAppBar(context))
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: ValueListenableBuilder<double>(
                                  valueListenable: _appBarOffset,
                                  builder: (context, offset, child) {
                                    final height = max(1, _appBarSizeNotifier.value.height);
                                    final ratio = (offset / height).abs();
                                    final opacity = (ratio * 255).clamp(0, 255).toInt();

                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: const [0.5, 1],
                                          colors: [
                                            LdTheme.of(context).surface.withAlpha(opacity),
                                            LdTheme.of(context).surface.withAlpha(0),
                                          ],
                                        ),
                                      ),
                                      height: MediaQuery.of(context).padding.top,
                                    );
                                  }),
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
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: drawerRadius,
                                  color: _isSideBySide ? null : LdTheme.of(context).surface,
                                  border: drawerBorder,
                                  boxShadow: _isSideBySide ? null : [ldShadowSticky],
                                ),
                                child: Provider.value(
                                  value: layoutState.copyWith(
                                    slot: LdScaffoldSlot.drawer,
                                    isDrawerOpen: _isDrawerOpen,
                                  ),
                                  child: RepaintBoundary(
                                    child: FocusScope(
                                      node: _focusScopeNode,
                                      child: ScrollNotificationObserver(
                                        child: ScrollObserver(
                                          position: _drawerScrollOffset,
                                          child: widget.drawer!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ].reverseIf(_isSideBySide),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void closeDrawer() {
    _historyEntry?.remove();
  }

  @override
  void didUpdateWidget(LdScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) {
      _appBarSizeNotifier.value = Size.zero;
    }
    if (widget.secondaryNavigationBar == null) {
      _secondaryNavigationBarSizeNotifier.value = Size.zero;
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _drawerStreamController.close();
    _bottomNavigationBarFocusNode.dispose();
    _appBarOffset.dispose();
    _intentRouterController.close();
    _appBarSizeNotifier.removeListener(_handleAppBarSizeChange);
    _secondaryNavigationBarSizeNotifier.removeListener(_handleSecondaryNavigationBarSizeChange);
    super.dispose();
  }

  void openDrawer() {
    _ensureHistoryEntry();

    setState(() {
      _drawerOffset = _effectiveDrawerWidth;
    });
  }

  double _bodyBottomOffset(BuildContext context) {
    if (!_hasTopSecondaryNavigationBar(context)) {
      return _secondaryNavigationBarSizeNotifier.value.height;
    }
    return 0;
  }

  double _bodyTopOffset(BuildContext context) {
    if (widget.extendBodyBehindAppBar) {
      return 0;
    }
    if (_hasTopSecondaryNavigationBar(context)) {
      return _appBarSizeNotifier.value.height + _appBarOffset.value + _secondaryNavigationBarSizeNotifier.value.height;
    }
    return _appBarSizeNotifier.value.height + _appBarOffset.value;
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

  void _handleScrollChange(double scrollOffset) {
    if (!_shouldHideAppBar(context)) {
      _appBarOffset.value = 0.0;
      _lastScrollOffset = scrollOffset;
      setState(() {});
      return;
    }

    final layoutState = context.read<LdScaffoldLayoutState?>();
    final level = layoutState?.level ?? 0;

    scrollOffset = scrollOffset - level * 150;

    if (scrollOffset < 100) {
      _appBarOffset.value = 0.0;
      _lastScrollOffset = scrollOffset;
      setState(() {});
      return;
    }

    // Calculate scroll direction and velocity
    final double scrollDelta = scrollOffset - _lastScrollOffset;
    final bool isScrollingDown = scrollDelta > 0;
    final bool isScrollingUp = scrollDelta < 0;

    // Apply some hysteresis for better UX
    double newOffset = _appBarOffset.value;

    if (isScrollingDown) {
      // Scrolling down - hide app bar
      newOffset = max(newOffset - scrollDelta, -_appBarSizeNotifier.value.height);
    } else if (isScrollingUp) {
      // Scrolling up - show app bar
      newOffset = min(newOffset - scrollDelta, 0);
    }

    _appBarOffset.value = newOffset;

    _lastScrollOffset = scrollOffset;
    setState(() {});
  }

  bool _hasTopSecondaryNavigationBar(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    return (widget.secondaryNavPlacement == LdScaffoldSecondaryNavPlacement.auto && isDesktop) ||
        widget.secondaryNavPlacement == LdScaffoldSecondaryNavPlacement.top;
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

  Widget _placeSecondaryNavigationBar(BuildContext context, Widget secondaryNavigationBar) {
    if (_hasTopSecondaryNavigationBar(context)) {
      // On desktop we place the secondary navigation bar at the top, we offset by the app bar height
      return Positioned(
        top: _appBarSizeNotifier.value.height - _appBarOffset.value,
        left: 0,
        right: 0,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: MediaQuery.of(context).padding.copyWith(top: 0)),
          child: secondaryNavigationBar,
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.4],
                colors: [
                  LdTheme.of(context).surface.withAlpha(0),
                  LdTheme.of(context).surface.withAlpha(200),
                ],
              ),
            ),
            height: _secondaryNavigationBarSizeNotifier.value.height,
          ),
          Align(alignment: Alignment.bottomCenter, child: secondaryNavigationBar),
        ],
      ),
    );
  }

  bool _shouldHideAppBar(BuildContext context) {
    switch (widget.appBarScrollBehavior) {
      case LdAppBarScrollBehavior.static:
        return false;
      case LdAppBarScrollBehavior.mobileOnly:
        return MediaQuery.sizeOf(context).width <= 900;
      case LdAppBarScrollBehavior.always:
        return true;
    }
  }

  static LdScaffoldState of(BuildContext context) {
    return context.findAncestorStateOfType<LdScaffoldState>()!;
  }
}

class ScrollObserver extends StatefulWidget {
  final ValueNotifier<double> position;
  final Widget child;
  final Function(double)? onScrollChange;

  const ScrollObserver({
    super.key,
    required this.position,
    required this.child,
    this.onScrollChange,
  });

  @override
  State<ScrollObserver> createState() => _ScrollObserverState();
}

class _ScrollObserverState extends State<ScrollObserver> {
  ScrollNotificationObserverState? _scrollNotificationObserver;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
      _scrollNotificationObserver?.addListener(_handleScrollNotification);
    });
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      final offset = notification.metrics.pixels;
      widget.position.value = offset;
      widget.onScrollChange?.call(offset);
    }
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

extension AtLeast on EdgeInsets {
  EdgeInsets atLeast(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      max(left, other.left),
      max(top, other.top),
      max(right, other.right),
      max(bottom, other.bottom),
    );
  }
}
