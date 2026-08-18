import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_scrolled_under.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/theme/adaptive_radius.dart';
import 'package:provider/provider.dart';

class LdTabNavigation extends StatefulWidget {
  /// The currently active route. Used to determine which tab is highlighted
  /// when [pageController] is not provided, or to supplement initial state
  /// when [pageController] is provided.
  ///
  /// Either [activeRoute] or [pageController] must be non-null.
  final String? activeRoute;

  final void Function(String route) onTabPressed;
  final List<LdNavigationTab> tabs;
  final LdAppBarAttachedMode attachedMode;
  final LdAppBarBackgroundMode backgroundMode;
  final Color? backgroundColor;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBorderMode borderMode;
  final LdAppBarPositionMode position;
  final LdAppBarScrollBehavior scrollBehavior;
  final bool addContainer;
  final bool enableGradient;

  final double minTabWidth;

  /// Optional [PageController] to keep the tab indicator in continuous sync
  /// with a [PageView]. When provided:
  ///
  /// - The indicator tracks [PageController.page] frame-by-frame during swipes
  ///   (spring is bypassed while the page is scrolling, then re-enabled on
  ///   release so the indicator settles with the characteristic bounce).
  /// - Tapping a tab calls [PageController.animateToPage] in addition to
  ///   [onTabPressed].
  /// - Dragging the tab indicator also calls [PageController.animateToPage]
  ///   on release.
  ///
  /// The [PageController.initialPage] is used to seed the initial indicator
  /// position when [activeRoute] is null.
  final PageController? pageController;

  /// The subtree that this tab bar wraps.
  final Widget child;

  final String? debugName;

  const LdTabNavigation({
    super.key,
    this.activeRoute,
    required this.tabs,
    this.backgroundColor,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    required this.onTabPressed,
    this.debugName,
    required this.child,
    this.addContainer = false,
    this.enableGradient = true,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.position = LdAppBarPositionMode.adaptive,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.minTabWidth = 75,
    this.pageController,
  }) : assert(
          activeRoute != null || pageController != null,
          'LdTabNavigation: either activeRoute or pageController must be provided.',
        );

  @override
  State<LdTabNavigation> createState() => _LdTabNavigationState();
}

class _LdTabNavigationState extends State<LdTabNavigation> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  /// Integer index of the currently highlighted tab. Used when [activeRoute]
  /// is null and the position is driven by [pageController].
  int _currentPageIndex = 0;

  /// When true, the [LdSpring] is bypassed and the indicator follows the
  /// [pageController] position directly (no lag during swipe).
  bool _springOverridden = false;

  // ── PageController wiring ──────────────────────────────────────────────────

  void _attachPageController() {
    final pc = widget.pageController;
    if (pc == null) return;
    pc.addListener(_onPageControllerUpdate);
    // Seed the index from the initial page if activeRoute is absent.
    if (widget.activeRoute == null) {
      _currentPageIndex = pc.initialPage.clamp(0, _tabCount - 1);
    }
  }

  void _detachPageController(PageController? pc) {
    pc?.removeListener(_onPageControllerUpdate);
  }

  void _onPageControllerUpdate() {
    final pc = widget.pageController;
    if (pc == null || !pc.hasClients) return;
    final page = pc.page;
    if (page == null) return;
    _updateIndicatorFromPage(page);
  }

  /// Translates a fractional [page] value (e.g. 1.37 mid-swipe) into a pixel
  /// indicator position. Overrides the spring while the page is non-integer so
  /// the indicator follows the finger directly; releases the spring once the
  /// page settles.
  ///
  /// The active tab highlight ([_currentPageIndex]) is only committed once the
  /// page fully settles — matching the behaviour of dragging the indicator
  /// directly, where the active tab only updates on drag end.
  void _updateIndicatorFromPage(double page) {
    final isScrolling = (page - page.roundToDouble()).abs() > 0.001;
    final newPosition = page.clamp(0, _tabCount - 1) * _tabStride;

    setState(() {
      // Only snap the active-tab highlight when the page has settled to an
      // integer. Mid-swipe the indicator moves but no tab becomes active yet.
      if (!isScrolling) {
        _currentPageIndex = page.round().clamp(0, _tabCount - 1);
      }
      _indicatorPosition = newPosition;
      _springOverridden = isScrolling;
    });

    if (!isScrolling) {
      _scrollToIndicator();
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _attachPageController();
  }

  @override
  void dispose() {
    _detachPageController(widget.pageController);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LdTabNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageController != widget.pageController) {
      _detachPageController(oldWidget.pageController);
      _attachPageController();
    }

    // Route-based update only when we are not in PageController mode.
    if (widget.pageController == null && oldWidget.activeRoute != widget.activeRoute) {
      _updateIndicatorPosition();
    }
  }

  // ── Position & layout ──────────────────────────────────────────────────────

  LdAppBarPosition get _effectivePosition {
    return switch (widget.position) {
      LdAppBarPositionMode.adaptive =>
        LdTheme.of(context).platform.isDesktop ? LdAppBarPosition.top : LdAppBarPosition.bottom,
      LdAppBarPositionMode.top => LdAppBarPosition.top,
      LdAppBarPositionMode.bottom => LdAppBarPosition.bottom,
    };
  }

  bool _effectivelyAttached(BuildContext context) {
    final position = _effectivePosition;
    final attached = switch (widget.attachedMode) {
      LdAppBarAttachedMode.attached => true,
      LdAppBarAttachedMode.adaptive => switch (position) {
          LdAppBarPosition.bottom => LdTheme.of(context).platform.isDesktop,
          _ => true,
        },
      LdAppBarAttachedMode.floating => false,
    };
    return attached;
  }

  bool _isTabActive(LdNavigationTab tab) {
    final route = widget.activeRoute;

    // PageController mode: active tab is determined by the integer page index.
    if (route == null) {
      return widget.tabs.indexOf(tab) == _currentPageIndex;
    }

    return tab.matches(context, route);
  }

  int _activeIndex() {
    if (widget.activeRoute == null) {
      return _currentPageIndex.clamp(0, _tabCount - 1);
    }
    return widget.tabs.indexWhere(_isTabActive);
  }

  double _indicatorPosition = 0;

  double _navWidth = 0;

  void _updateIndicatorPosition() {
    final activeIndex = _activeIndex().clamp(0, _tabCount - 1);
    setState(() {
      _indicatorPosition = activeIndex * _tabStride;
    });
    _scrollToIndicator();
  }

  int get _tabCount => max(1, widget.tabs.length);

  double get _tabSpacing => LdTheme.of(context).paddingSize(size: LdSize.s);

  double get _tabStride => _tabWidth + _tabSpacing;

  double get _contentWidth => _totalSpacing + _tabCount * _tabWidth;

  double get _tabWidth => max(widget.minTabWidth, (_availableWidth - _totalSpacing) / _tabCount);

  double get _availableWidth => _navWidth - LdTheme.of(context).paddingSize(size: LdSize.s) * 2;

  double get _totalSpacing => _tabSpacing * (_tabCount - 1);

  bool get _compactMode => _navWidth < 500;

  // ── Drag gesture on the indicator ─────────────────────────────────────────

  double _dragStartPosition = 0;
  int _lastDraggedTabIndex = 0;
  double _dragStartIndicatorPosition = 0;

  int _getClosestTab(BuildContext context) {
    final closestTabIndex = (_indicatorPosition / _tabStride).round().clamp(0, _tabCount - 1);
    return closestTabIndex;
  }

  void _onIndicatorDragEnd(DragEndDetails details) {
    final closestTabIndex = _getClosestTab(context);
    widget.onTabPressed(widget.tabs[closestTabIndex].route);
    widget.pageController?.animateToPage(
      closestTabIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _updateIndicatorPosition();
  }

  void _onIndicatorDragUpdate(DragUpdateDetails details) {
    final currentTabIndex = _getClosestTab(context);

    if (_lastDraggedTabIndex != currentTabIndex) {
      LdHaptics.vibrate(HapticsType.heavy);
      _lastDraggedTabIndex = currentTabIndex;
    }
    setState(() {
      _indicatorPosition = (_dragStartIndicatorPosition + (details.localPosition.dx - _dragStartPosition))
          .clamp(0, max(0, _contentWidth - _tabWidth));
    });
  }

  void _onTabTap(int tabIndex) {
    final route = widget.tabs[tabIndex].route;
    widget.onTabPressed(route);
    widget.pageController?.animateToPage(
      tabIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _updateIndicatorPosition();
    LdHaptics.vibrate(HapticsType.light);
  }

  // ── Scroll to keep active tab visible ─────────────────────────────────────

  void _scrollToIndicator() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) {
      return;
    }

    final targetOffset = (_indicatorPosition - (_navWidth - _tabWidth) / 2)
        .clamp(
          0,
          maxScrollExtent,
        )
        .toDouble();

    if (ldDisableAnimations) {
      _scrollController.jumpTo(targetOffset);
    } else {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final isAttached = _effectivelyAttached(context);
    final position = _effectivePosition;

    final decorationBuilder = LdAppBarDecorationBuilder(
      backgroundColor: widget.backgroundColor,
      shadowMode: widget.shadowMode,
      borderMode: widget.borderMode,
      backgroundMode: widget.backgroundMode,
      scrollBehavior: widget.scrollBehavior,
    );

    // The tab bar surface widget — passed as [child] to AppBarFrame.
    final tabBarSurface = LayoutBuilder(
      builder: (context, constraints) {
        final isScrolledUnder = LdAppBarScrolledUnderScope.of(context);
        final isSurface = decorationBuilder
            .resolveAppearance(context, isScrolledUnder: isScrolledUnder, position: position)
            .childIsSurface;

        if (constraints.maxWidth != _navWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _navWidth = constraints.maxWidth;

                final activeIndex = _activeIndex().clamp(0, _tabCount - 1);
                _indicatorPosition = activeIndex * _tabStride;
              });
              _scrollToIndicator();
            }
          });
        }

        return Provider.value(
          value: LdSurfaceInfo(isSurface: isSurface),
          child: Builder(builder: (context) {
            return LdScrollEdgeFade(
              axis: Axis.horizontal,
              fadeColor: context.surfaceColor,
              fadeExtent: _tabWidth / 2,
              controller: _scrollController,
              child: Builder(builder: (context) {
                return SingleChildScrollView(
                  padding: LdTheme.of(context).pad(size: LdSize.s),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Stack(
                    children: [
                      Row(
                        spacing: _tabSpacing,
                        children: [
                          ...widget.tabs.mapIndexed(
                            (index, tab) => SizedBox(
                              width: _tabWidth,
                              child: LdTouchableSurface(
                                active: _isTabActive(tab),
                                onPressed: () => _onTabTap(index),
                                builder: (context, status, _) {
                                  final colors = switch (_isTabActive(tab)) {
                                    true => ghostColor(theme.primary, theme, status),
                                    false => neutralGhostColor(theme, status),
                                  };
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: context.adaptiveRadius.childRadius.max.atLeast(
                                        theme.radius(LdSize.m),
                                      ),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        final iconColor = colors.icon;
                                        final textColor = colors.text;
                                        final icon = IconTheme(
                                          data: IconThemeData(
                                            color: iconColor,
                                            size: theme.labelSize(LdSize.l),
                                          ),
                                          child: tab.icon,
                                        );

                                        if (_compactMode) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              icon,
                                              ldSpacerXS,
                                              LdText.ls(
                                                tab.label,
                                                color: textColor,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ).padXS();
                                        }
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            icon,
                                            ldSpacerS,
                                            Flexible(
                                              child: LdText.l(
                                                tab.label,
                                                color: textColor,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ).padS();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      LdSpring(
                        springConstant: 20,
                        dampingCoefficient: 20,
                        mass: 5,
                        overriden: _springOverridden,
                        position: _indicatorPosition,
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            _dragStartPosition = details.localPosition.dx;
                            _dragStartIndicatorPosition = _indicatorPosition;
                            _lastDraggedTabIndex = _getClosestTab(context);
                          },
                          onHorizontalDragUpdate: _onIndicatorDragUpdate,
                          onHorizontalDragCancel: () {
                            _updateIndicatorPosition();
                          },
                          onHorizontalDragEnd: _onIndicatorDragEnd,
                          // The indicator is purely decorative (onPressed is a
                          // no-op); it must not swallow taps meant for the
                          // real tab button it currently overlaps, so pointer
                          // events are passed through to the widgets below it
                          // in the stack.
                          child: IgnorePointer(
                            child: LdTouchableSurface(
                              onPressed: () {},
                              trackPan: true,
                              builder: (context, status, _) => LdTouchableTouchFeedback(
                                  scaleFactor: 100,
                                  status: status,
                                  child: Container(
                                    width: _tabWidth,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withAlpha(26),
                                      borderRadius:
                                          context.adaptiveRadius.childRadius.max.atLeast(theme.radius(LdSize.m)),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        builder: (context, state, child) {
                          return Positioned(
                            bottom: 0,
                            top: 0,
                            left: state.position,
                            child: child!,
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
        );
      },
    );

    final frame = AnnotatedRegion<SystemUiOverlayStyle>(
      value: appBarSystemUiOverlayStyle(theme),
      child: AppBarFrame(
        debugName: widget.debugName,
        position: position,
        attached: isAttached,
        isTabNavigation: true,
        addContainer: widget.addContainer,
        insidePadding: EdgeInsets.zero,
        scrollBehavior: widget.scrollBehavior,
        wrappedChild: widget.child,
        outsideAdditionalPadding: !isAttached ? LdTheme.of(context).pad(size: LdSize.s) : null,
        insideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildInsideDecoration(
          context: context,
          isScrolledUnder: isScrolledUnder,
          isAttached: isAttached,
          position: position,
        ),
        outsideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildOutsideDecoration(
          context: context,
          isScrolledUnder: isScrolledUnder,
          isAttached: isAttached,
          position: position,
        ),
        child: tabBarSurface,
      ),
    );

    return frame;
  }
}
