import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/haptics.dart';

part 'tab_navigation_components.dart';

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

  final Widget? trailing;
  final Widget? leading;

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
    this.minTabWidth = 60,
    this.pageController,
    this.trailing,
    this.leading,
  }) : assert(
          activeRoute != null || pageController != null,
          'LdTabNavigation: either activeRoute or pageController must be provided.',
        );

  @override
  State<LdTabNavigation> createState() => _LdTabNavigationState();
}

class _LdTabNavigationState extends State<LdTabNavigation> {
  static const _pageAnimationDuration = Duration(milliseconds: 300);
  static const _scrollAnimationDuration = Duration(milliseconds: 220);

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  /// Integer index of the currently highlighted tab. Used when [activeRoute]
  /// is null and the position is driven by [pageController].
  int _currentPageIndex = 0;

  /// When true, the [LdSpring] is bypassed and the indicator follows the
  /// [pageController] position directly (no lag during swipe).
  bool _springOverridden = false;

  double _indicatorPosition = 0;
  double _navWidth = 0;

  double _dragStartPosition = 0;
  int _lastDraggedTabIndex = 0;
  double _dragStartIndicatorPosition = 0;

  int get _tabCount => max(1, widget.tabs.length);

  _TabBarMetrics get _metrics => _TabBarMetrics(
        navWidth: _navWidth,
        tabCount: _tabCount,
        minTabWidth: widget.minTabWidth,
        padding: LdTheme.of(context).paddingSize(size: LdSize.xs),
      );

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
    final newPosition = page.clamp(0, _tabCount - 1) * _metrics.tabStride;

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

  void _animateToPage(int index) {
    widget.pageController?.animateToPage(
      index,
      duration: _pageAnimationDuration,
      curve: Curves.easeInOut,
    );
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
    return switch (widget.attachedMode) {
      LdAppBarAttachedMode.attached => true,
      LdAppBarAttachedMode.adaptive => switch (position) {
          LdAppBarPosition.bottom => LdTheme.of(context).platform.isDesktop,
          _ => true,
        },
      LdAppBarAttachedMode.floating => false,
    };
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

  void _updateIndicatorPosition() {
    final activeIndex = _activeIndex().clamp(0, _tabCount - 1);
    setState(() {
      _indicatorPosition = activeIndex * _metrics.tabStride;
    });
    _scrollToIndicator();
  }

  void _scheduleNavWidthSync(double width) {
    if (width == _navWidth) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _navWidth = width;
        final activeIndex = _activeIndex().clamp(0, _tabCount - 1);
        _indicatorPosition = activeIndex * _metrics.tabStride;
      });
      _scrollToIndicator();
    });
  }

  // ── Drag gesture on the indicator ─────────────────────────────────────────

  int _closestTabIndex() {
    return (_indicatorPosition / _metrics.tabStride).round().clamp(0, _tabCount - 1);
  }

  void _onIndicatorDragStart(DragStartDetails details) {
    _dragStartPosition = details.localPosition.dx;
    _dragStartIndicatorPosition = _indicatorPosition;
    _lastDraggedTabIndex = _closestTabIndex();
  }

  void _onIndicatorDragUpdate(DragUpdateDetails details) {
    final currentTabIndex = _closestTabIndex();

    if (_lastDraggedTabIndex != currentTabIndex) {
      LdHaptics.vibrate(HapticsType.heavy);
      _lastDraggedTabIndex = currentTabIndex;
    }

    final metrics = _metrics;
    setState(() {
      _indicatorPosition = (_dragStartIndicatorPosition + (details.localPosition.dx - _dragStartPosition))
          .clamp(0, max(0, metrics.contentWidth - metrics.tabWidth));
    });
  }

  void _onIndicatorDragEnd(DragEndDetails details) {
    _selectTab(_closestTabIndex());
  }

  void _onTabTap(int tabIndex) {
    _selectTab(tabIndex);
    LdHaptics.vibrate(HapticsType.light);
  }

  void _selectTab(int index) {
    widget.onTabPressed(widget.tabs[index].route);
    _animateToPage(index);
    _updateIndicatorPosition();
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

    final targetOffset =
        (_indicatorPosition - (_navWidth - _metrics.tabWidth) / 2).clamp(0, maxScrollExtent).toDouble();

    if (ldDisableAnimations) {
      _scrollController.jumpTo(targetOffset);
    } else {
      _scrollController.animateTo(
        targetOffset,
        duration: _scrollAnimationDuration,
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appBarSystemUiOverlayStyle(theme),
      child: AppBarFrame(
        debugName: widget.debugName,
        position: _effectivePosition,
        attached: isAttached,
        addContainer: widget.addContainer,
        scrollBehavior: widget.scrollBehavior,
        outsideAdditionalPadding: !isAttached ? LdTheme.of(context).pad(size: LdSize.s) : null,
        insideBuilder: (context, metrics, child) {
          return Row(
            children: [
              Expanded(
                child: AppbarInsideContainer(
                  metrics: metrics,
                  borderMode: widget.borderMode,
                  shadowMode: widget.shadowMode,
                  backgroundMode: widget.backgroundMode,
                  backgroundColor: widget.backgroundColor,
                  child: child,
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          );
        },
        outsideBuilder: (context, metrics, child) {
          return AppbarOutsideContainer(
            metrics: metrics,
            borderMode: widget.borderMode,
            shadowMode: widget.shadowMode,
            backgroundMode: widget.backgroundMode,
            backgroundColor: widget.backgroundColor,
            child: child,
          );
        },
        wrappedChild: widget.child,
        child: _buildTabBar(
          decorationBuilder: decorationBuilder,
          position: position,
        ),
      ),
    );
  }

  Widget _buildTabBar({
    required LdAppBarDecorationBuilder decorationBuilder,
    required LdAppBarPosition position,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleNavWidthSync(constraints.maxWidth);

        final metrics = _metrics;

        return _LdTabBarScrollArea(
          controller: _scrollController,
          fadeExtent: metrics.tabWidth / 2,
          child: Stack(
            children: [
              _buildTabRow(metrics),
              _LdTabNavigationIndicator(
                tabWidth: metrics.tabWidth,
                position: _indicatorPosition,
                springOverridden: _springOverridden,
                onDragStart: _onIndicatorDragStart,
                onDragUpdate: _onIndicatorDragUpdate,
                onDragEnd: _onIndicatorDragEnd,
                onDragCancel: _updateIndicatorPosition,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabRow(_TabBarMetrics metrics) {
    return Row(
      spacing: metrics.tabSpacing,
      children: [
        ...widget.tabs.mapIndexed(
          (index, tab) => _LdTabNavigationItem(
            tab: tab,
            active: _isTabActive(tab),
            compact: metrics.compactMode,
            width: metrics.tabWidth,
            onPressed: () => _onTabTap(index),
          ),
        ),
      ],
    );
  }
}
