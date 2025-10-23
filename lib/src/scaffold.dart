import 'dart:async';
import 'dart:math';

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
  final String? debugName;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final double drawerWidth;

  final double? reflowBreakpoint;
  final SingleActivator? toggleDrawerShortcut;
  final LdScaffoldSecondaryNavPlacement secondaryNavPlacement;
  final LdAppBarScrollBehavior appBarScrollBehavior;

  final TextEditingController? searchController;
  final ScrollController? primaryScrollController;

  const LdScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.debugName,
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
    this.primaryScrollController,
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
    return '''LdScaffoldLayoutState(
    level: $level, 
    parentLayoutState: ${parentLayoutState?.toString().split('\n').join('\n    ')}, 
    isDrawerOpen: $isDrawerOpen, 
    isSideBySide: $isSideBySide, 
    slot: $slot,
    bodyScrollOffset: $bodyScrollOffset,
    drawerScrollOffset: $drawerScrollOffset,
    )''';
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

  final FocusNode _bottomNavigationBarFocusNode = FocusNode();

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  ScrollController? _internalScrollController;

  Stream<bool> get drawerStream => _drawerStreamController.stream;

  bool get hasDrawer => widget.drawer != null;

  Stream<Intent> get intentRouter => _intentRouterController.stream;

  ScrollController get effectiveScrollController {
    final controller = widget.primaryScrollController ?? _internalScrollController!;
    return controller;
  }

  LdDrawerState? _drawerState;

  SingleActivator get toggleDrawerShortcut =>
      widget.toggleDrawerShortcut ??
      const SingleActivator(
        LogicalKeyboardKey.keyS,
        meta: true,
      );

  BoxDecoration? get _scaffoldDecoration {
    final theme = LdTheme.of(context, listen: true);
    Color backgroundColor = widget.backgroundColor ?? theme.surface;

    if (theme.platform == LdPlatform.macos && _layoutState(context).level == 0) {
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
    _bodyScrollOffset.addListener(_handleBodyScrollOffsetChange);

    // Create internal scroll controller if none provided
    if (widget.primaryScrollController == null) {
      _internalScrollController = ScrollController();
    }
  }

  void _handleAppBarSizeChange() {
    setState(() {});
  }

  void _handleSecondaryNavigationBarSizeChange() {
    setState(() {});
  }

  LdScaffoldLayoutState? _parentLayoutState(BuildContext context) {
    return context.watch<LdScaffoldLayoutState?>();
  }

  void _onDrawerStateChange(LdDrawerState drawerState) {
    setState(() {
      _drawerState = drawerState;
    });
  }

  void scrollToTop() {
    final controller = effectiveScrollController;
    if (controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  LdScaffoldLayoutState _layoutState(BuildContext context) {
    return LdScaffoldLayoutState(
      parentLayoutState: _parentLayoutState(context),
      isDrawerOpen: _drawerState?.isOpen ?? false,
      isSideBySide: _drawerState?.isSideBySide ?? false,
      slot: LdScaffoldSlot.body,
      bodyScrollOffset: _bodyScrollOffset,
      drawerScrollOffset: _drawerScrollOffset,
    );
  }

  void openDrawer() {
    _intentRouterController.add(const OpenDrawerIntent());
  }

  void closeDrawer() {
    if (!hasDrawer) {
      final parent = context.findAncestorStateOfType<LdScaffoldState>();
      if (parent != null) {
        parent.closeDrawer();
      }
    }
    _intentRouterController.add(const CloseDrawerIntent());
  }

  void toggleDrawer() {
    _intentRouterController.add(const ToggleDrawerIntent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final bodyTopOffset = _bodyTopOffset(context);
    final bodyBottomOffset = _bodyBottomOffset(context);

    EdgeInsets bodyPadding = MediaQuery.paddingOf(context);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: _scaffoldDecoration ?? const BoxDecoration(),
      child: Shortcuts(
        shortcuts: {
          toggleDrawerShortcut: const ToggleDrawerIntent(),
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchIntent(),
        },
        child: Actions(
          actions: {
            SearchIntent: CallbackAction(
              onInvoke: (intent) {
                _intentRouterController.add(intent);
                return null;
              },
            )
          },
          child: LayoutBuilder(builder: (context, constraints) {
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

            final layoutState = _layoutState(context);

            final bodyStack = Stack(children: [
              // Body
              Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
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
                          child: ScrollObserver(
                            position: _bodyScrollOffset,
                            child: Provider.value(
                              value: layoutState.copyWith(slot: LdScaffoldSlot.body),
                              child: PrimaryScrollController(
                                controller: effectiveScrollController,
                                child: widget.body,
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
                              child: child,
                            );
                          },
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
                    ],
                  ))
            ]);

            if (widget.drawer != null) {
              return _LdDrawerLayout(
                intents: intentRouter,
                drawerWidth: widget.drawerWidth,
                onStateChange: _onDrawerStateChange,
                drawer: Provider.value(
                  value: layoutState.copyWith(
                    slot: LdScaffoldSlot.drawer,
                    isDrawerOpen: _drawerState?.isOpen ?? false,
                  ),
                  child: RepaintBoundary(
                    child: FocusScope(
                      node: _focusScopeNode,
                      child: ScrollObserver(
                        position: _drawerScrollOffset,
                        child: widget.drawer!,
                      ),
                    ),
                  ),
                ),
                body: bodyStack,
                reflowBreakpoint: widget.reflowBreakpoint ?? 900,
              );
            }

            return Material(
              type: MaterialType.transparency,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: _scaffoldDecoration,
                child: bodyStack,
              ),
            );
          }),
        ),
      ),
    );
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
    _internalScrollController?.dispose();

    super.dispose();
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

  void _handleBodyScrollOffsetChange() {
    double scrollOffset = _bodyScrollOffset.value;

    if (_lastScrollOffset == scrollOffset) {
      return;
    }
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

class ScrollObserver extends StatelessWidget {
  final Widget child;
  final ValueNotifier<double> position;

  const ScrollObserver({super.key, required this.child, required this.position});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          position.value = notification.metrics.pixels;
        }
        return true;
      },
      child: child,
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

class LdDrawerState {
  final bool isOpen;
  final bool isSideBySide;

  const LdDrawerState({required this.isOpen, required this.isSideBySide});
}

class _LdDrawerLayout extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final double reflowBreakpoint;
  final Stream<Intent> intents;
  final void Function(LdDrawerState) onStateChange;

  final double drawerWidth;
  const _LdDrawerLayout({
    required this.drawer,
    required this.body,
    required this.reflowBreakpoint,
    required this.drawerWidth,
    required this.onStateChange,
    required this.intents,
  });

  @override
  State<_LdDrawerLayout> createState() => _LdDrawerLayoutState();
}

class _LdDrawerLayoutState extends State<_LdDrawerLayout> {
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
    return Actions(
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
                  child: widget.body,
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
                      drawerLeft = state.position - _effectiveDrawerWidth;
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
                        ),
                        child: child!,
                      ),
                    );
                  },
                  child: widget.drawer,
                )
              ].reverseIf(_isSideBySide),
            );
          },
        ),
      ),
    );
  }
}
