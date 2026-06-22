import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/touchable/ghost_color.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';

class LdNavigationTab {
  final String label;
  final Widget icon;
  final String route;
  final bool Function(BuildContext context)? isActive;

  const LdNavigationTab({required this.label, required this.icon, required this.route, this.isActive});
}

class LdTabNavigation extends StatefulWidget {
  final String activeRoute;
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

  /// The subtree that this tab bar wraps.
  final Widget child;

  final String? debugName;

  const LdTabNavigation({
    super.key,
    required this.activeRoute,
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
  });

  @override
  State<LdTabNavigation> createState() => _LdTabNavigationState();
}

class _LdTabNavigationState extends State<LdTabNavigation> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  int _activeIndex() {
    return widget.tabs.indexWhere((tab) {
      if (tab.isActive != null) {
        return tab.isActive!(context);
      }
      if (tab.route.endsWith("*")) {
        return widget.activeRoute.startsWith(tab.route.substring(0, tab.route.length - 1));
      }
      return widget.activeRoute == (tab.route);
    });
  }

  double _indicatorPosition = 0;

  double _navWidth = 0;

  @override
  void didUpdateWidget(LdTabNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeRoute != widget.activeRoute) {
      _updateIndicatorPosition();
    }
  }

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

  double get _availableWidth => _navWidth - LdTheme.of(context).paddingSize(size: LdSize.xs) * 2;

  double get _totalSpacing => _tabSpacing * (_tabCount - 1);

  bool get _compactMode => _navWidth < 500;

  double _dragStartPosition = 0;
  int _lastDraggedTabIndex = 0;
  double _dragStartIndicatorPosition = 0;

  int _getClosestTab(BuildContext context) {
    // Calculate which tab the indicator is closest to based on its left position
    final closestTabIndex = (_indicatorPosition / _tabStride).round().clamp(0, _tabCount - 1);
    return closestTabIndex;
  }

  void _onIndicatorDragEnd(DragEndDetails details) {
    final closestTabIndex = _getClosestTab(context);
    widget.onTabPressed(widget.tabs[closestTabIndex].route);
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

  void _onTabTap(String route) {
    widget.onTabPressed(route);
    _updateIndicatorPosition();
    LdHaptics.vibrate(HapticsType.light);
  }

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
    );

    // The tab bar surface widget — passed as [child] to AppBarFrame.
    final tabBarSurface = LayoutBuilder(
      builder: (context, constraints) {
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

        return LdScrollEdgeFade(
          axis: Axis.horizontal,
          fadeColor: context.surfaceColor,
          controller: _scrollController,
          child: Builder(builder: (context) {
            return SingleChildScrollView(
              padding: LdTheme.of(context).pad(size: LdSize.xs),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  Row(
                    spacing: _tabSpacing,
                    children: [
                      ...widget.tabs.map(
                        (tab) => SizedBox(
                          width: _tabWidth,
                          child: LdTouchableSurface(
                            active: widget.activeRoute == tab.route,
                            onPressed: () => _onTabTap(tab.route),
                            builder: (context, status, _) {
                              final colors = switch (widget.activeRoute == tab.route) {
                                true => ghostColor(theme.primary, theme, status),
                                false => neutralGhostColor(theme, status),
                              };
                              return Container(
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: LdTheme.of(context).radius(LdSize.s),
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
                      child: LdTouchableSurface(
                        onPressed: () {},
                        builder: (context, status, _) => LdTouchableTouchFeedback(
                            scaleFactor: 100,
                            status: status,
                            child: Container(
                              width: _tabWidth,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withAlpha(26),
                                borderRadius: LdTheme.of(context).radius(LdSize.s),
                              ),
                            )),
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
        scrollBehavior: widget.scrollBehavior,
        wrappedChild: widget.child,
        outsideAdditionalPadding:
            !isAttached ? EdgeInsets.symmetric(vertical: LdTheme.of(context).paddingSize(size: LdSize.xs)) : null,
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
        surfaceInfoBuilder: (isScrolledUnder) => LdSurfaceInfo(
          isSurface: decorationBuilder
              .resolveAppearance(
                context,
                isScrolledUnder: isScrolledUnder,
                position: position,
              )
              .childIsSurface,
        ),
        child: tabBarSurface,
      ),
    );

    return frame;
  }
}
