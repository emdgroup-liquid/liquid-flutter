import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  final LdAppBarPositionMode position;
  final LdAppBarScrollBehavior scrollBehavior;
  final bool addContainer;
  final int order;
  final bool enableGradient;
  final int maxVisibleTabs;

  const LdTabNavigation({
    super.key,
    required this.activeRoute,
    required this.tabs,
    required this.onTabPressed,
    this.addContainer = false,
    this.enableGradient = true,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.position = LdAppBarPositionMode.adaptive,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
    this.maxVisibleTabs = 5,
  });

  @override
  State<LdTabNavigation> createState() => _LdTabNavigationState();
}

class _LdTabNavigationState extends State<LdTabNavigation> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<LdContextMenuState> _moreMenuKey = GlobalKey();

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
    setState(() {
      _indicatorPosition = min(_activeIndex(), _visibleTabs - 1) * _navWidth / _visibleTabs;
    });
  }

  int get _visibleTabs => max(1, min(widget.tabs.length, widget.maxVisibleTabs + 1));

  double get _tabWidth => _navWidth / _visibleTabs;

  double _dragStartPosition = 0;
  int _lastDraggedTabIndex = 0;
  double _dragStartIndicatorPosition = 0;
  bool _dragging = false;

  int _getClosestTab(BuildContext context) {
    // Calculate which tab the indicator is closest to based on its left position
    final closestTabIndex = (_indicatorPosition / _tabWidth).round().clamp(0, _visibleTabs - 1);
    return closestTabIndex;
  }

  void _onIndicatorDragEnd(DragEndDetails details) {
    final closestTabIndex = _getClosestTab(context);
    if (closestTabIndex == _visibleTabs - 1 && _showingMore) {
      _moreMenuKey.currentState?.open();
    } else {
      widget.onTabPressed(widget.tabs[closestTabIndex].route);
    }
    _updateIndicatorPosition();
    setState(() {
      _dragging = false;
    });
  }

  bool get _showingMore => widget.tabs.length > _visibleTabs;

  void _onIndicatorDragUpdate(DragUpdateDetails details) {
    final currentTabIndex = _getClosestTab(context);

    if (_lastDraggedTabIndex != currentTabIndex) {
      LdHaptics.vibrate(HapticsType.heavy);
      _lastDraggedTabIndex = currentTabIndex;
    }
    setState(() {
      _dragging = true;
      _indicatorPosition = (_dragStartIndicatorPosition + (details.localPosition.dx - _dragStartPosition))
          .clamp(0, _navWidth - _tabWidth);
    });
  }

  void _onTabTap(String route) {
    widget.onTabPressed(route);
    _updateIndicatorPosition();
    LdHaptics.vibrate(HapticsType.light);
  }

  int _fillOpacity(bool isScrolledUnder) {
    int opacity = 0;

    if (isScrolledUnder || _effectivePosition == LdAppBarPosition.bottom) {
      opacity = 255;
    }

    return opacity;
  }

  Color _fillColor(bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    final color = LdTheme.of(context).surface;

    return switch (widget.backgroundMode) {
      LdAppBarBackgroundMode.hidden => Colors.transparent,
      LdAppBarBackgroundMode.visible => color,
      LdAppBarBackgroundMode.whenScrolled => Color.alphaBlend(
          color.withAlpha(_fillOpacity(isScrolledUnder)),
          LdTheme.of(context).background,
        ),
      LdAppBarBackgroundMode.adaptive => switch (theme.platform.isDesktop) {
          false => Color.alphaBlend(
              color.withAlpha(_fillOpacity(isScrolledUnder)),
              LdTheme.of(context).background,
            ),
          true => color,
        },
    };
  }

  BoxDecoration _buildOutsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required LdAppBarPosition position,
  }) {
    return BoxDecoration(
      // We fill the outside container when attached.
      color: isAttached ? _fillColor(isScrolledUnder) : null,
      // Gradient behind the floating app bar.
      gradient: !isAttached && widget.enableGradient
          ? LinearGradient(
              begin: switch (position) {
                LdAppBarPosition.bottom => Alignment.topCenter,
                LdAppBarPosition.top => Alignment.bottomCenter,
              },
              end: switch (position) {
                LdAppBarPosition.bottom => Alignment.bottomCenter,
                LdAppBarPosition.top => Alignment.topCenter,
              },
              stops: const [0, 0.3],
              colors: [
                LdTheme.of(context).absolute.withAlpha(0),
                LdTheme.of(context).absolute.withAlpha(200),
              ],
            )
          : null,
      // Add a border to the app bar when attached. either top or bottom.
      border: isAttached
          ? Border(
              bottom: switch (position) {
                LdAppBarPosition.top => BorderSide(
                    color: LdTheme.of(context).border,
                    width: LdTheme.of(context).borderWidth,
                  ),
                LdAppBarPosition.bottom => BorderSide.none,
              },
              top: switch (position) {
                LdAppBarPosition.bottom => BorderSide(
                    color: LdTheme.of(context).border,
                    width: LdTheme.of(context).borderWidth,
                  ),
                LdAppBarPosition.top => BorderSide.none,
              },
            )
          : null,
    );
  }

  BoxDecoration _buildInsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required LdAppBarPosition position,
  }) {
    if (isAttached) {
      return const BoxDecoration();
    }

    final theme = LdTheme.of(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(theme.radiusSize(LdSize.m)),
      color: _fillColor(isScrolledUnder),
      border: Border.all(
        color: theme.floatingBorder,
        width: theme.borderWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdAppBarRegistryEntry(
      order: widget.order,
      child: Builder(
        builder: (context) {
          final theme = LdTheme.of(context, listen: true);
          final isAttached = _effectivelyAttached(context);
          return LdAppBarScrollWrapper(
            position: _effectivePosition,
            scrollBehavior: widget.scrollBehavior,
            child: ScrolledUnderBuilder(
              builder: (context, isScrolledUnder) {
                return LdTouchableSurface(
                  focusNode: _focusNode,
                  onPressed: () {},
                  builder: (context, colors, status, _) {
                    return LdTouchableTouchFeedback(
                      status: status,
                      child: AppBarFrame(
                        position: _effectivePosition,
                        attached: isAttached,
                        addContainer: widget.addContainer,
                        insidePadding: isAttached ? EdgeInsets.zero : LdTheme.of(context).pad(size: LdSize.s),
                        outsideDecoration: _buildOutsideDecoration(
                          context: context,
                          isScrolledUnder: isScrolledUnder,
                          isAttached: isAttached,
                          position: _effectivePosition,
                        ),
                        outsideMinPadding: isAttached ? EdgeInsets.zero : null,
                        insideDecoration: _buildInsideDecoration(
                          context: context,
                          isScrolledUnder: isScrolledUnder,
                          isAttached: isAttached,
                          position: _effectivePosition,
                        ),
                        insetBorderRadius: !isAttached,
                        child: LayoutBuilder(builder: (context, constraints) {
                          final tabWidth =
                              constraints.maxWidth ~/ max(min(widget.tabs.length, widget.maxVisibleTabs), 1);
                          final fittingTabs = constraints.maxWidth ~/ tabWidth;

                          final overflowTabs = widget.tabs.sublist(fittingTabs);

                          if (constraints.maxWidth != _navWidth) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _navWidth = constraints.maxWidth;
                                  _updateIndicatorPosition();
                                });
                              }
                            });
                          }

                          return Stack(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                ...widget.tabs.sublist(0, fittingTabs).map((tab) => Expanded(
                                      child: LdTouchableSurface(
                                        mode: LdTouchableSurfaceMode.ghost,
                                        color: theme.primary,
                                        onPressed: () => _onTabTap(tab.route),
                                        builder: (context, colors, status, _) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: colors.surface,
                                              borderRadius: isAttached ? null : LdTheme.of(context).radius(LdSize.s),
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

                                                if (constraints.maxWidth < 500) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      icon,
                                                      ldSpacerXS,
                                                      LdText.ls(tab.label, color: textColor, maxLines: 1),
                                                    ],
                                                  ).padXS();
                                                }
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    icon,
                                                    ldSpacerS,
                                                    Flexible(
                                                      child: LdText.l(tab.label, color: textColor, maxLines: 1),
                                                    ),
                                                  ],
                                                ).padS();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    )),
                                if (overflowTabs.isNotEmpty) ...[
                                  Expanded(
                                      child: LdContextMenu(
                                          key: _moreMenuKey,
                                          menuBuilder: (context) {
                                            return ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 200),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    ...overflowTabs.map((tab) {
                                                      return LdListItem(
                                                        active: tab.route == widget.activeRoute,
                                                        leading: tab.icon,
                                                        title: Text(tab.label),
                                                        onPressed: () {
                                                          _onTabTap(tab.route);
                                                          LdContextMenuDissmissNotification().dispatch(context);
                                                        },
                                                      );
                                                    })
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          builder: (context, isShuttle, trigger, isOpen, child) {
                                            return LdTouchableSurface(
                                              mode: LdTouchableSurfaceMode.ghost,
                                              color: theme.primary,
                                              onPressed: trigger,
                                              builder: (context, colors, status, _) {
                                                return Container(
                                                    decoration: BoxDecoration(
                                                      color: colors.surface,
                                                      borderRadius:
                                                          isAttached ? null : LdTheme.of(context).radius(LdSize.s),
                                                    ),
                                                    child: Builder(builder: (context) {
                                                      final iconColor = colors.icon;
                                                      final textColor = colors.text;
                                                      final icon = IconTheme(
                                                        data: IconThemeData(
                                                          color: iconColor,
                                                          size: theme.labelSize(LdSize.l),
                                                        ),
                                                        child: const Icon(LucideIcons.ellipsisVertical),
                                                      );

                                                      if (constraints.maxWidth < 500) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            icon,
                                                            ldSpacerXS,
                                                            LdText.ls("More", color: textColor, maxLines: 1),
                                                          ],
                                                        ).padXS();
                                                      }

                                                      return Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          icon,
                                                          ldSpacerS,
                                                          Flexible(
                                                            child: LdText.l("More", color: textColor, maxLines: 1),
                                                          ),
                                                        ],
                                                      ).padS();
                                                    }));
                                              },
                                            );
                                          }))
                                ]
                              ]),
                              LdSpring(
                                springConstant: 20,
                                dampingCoefficient: 20,
                                mass: 5,
                                position: _indicatorPosition,
                                child: LdSpring(
                                  position: _dragging ? 1.1 : 1,
                                  builder: (context, state, child) => Transform.scale(
                                    scale: state.position.clamp(0, 2),
                                    child: child!,
                                  ),
                                  child: GestureDetector(
                                    onHorizontalDragStart: (details) {
                                      _dragStartPosition = details.localPosition.dx;
                                      _dragStartIndicatorPosition = _indicatorPosition;
                                      _lastDraggedTabIndex = _getClosestTab(context);
                                    },
                                    onHorizontalDragUpdate: _onIndicatorDragUpdate,
                                    onHorizontalDragCancel: () {
                                      _dragging = false;
                                      _updateIndicatorPosition();
                                    },
                                    onHorizontalDragEnd: _onIndicatorDragEnd,
                                    child: Container(
                                      width: constraints.maxWidth / _visibleTabs,
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withAlpha(26),
                                        border: switch (isAttached) {
                                          true => switch (_effectivePosition) {
                                              LdAppBarPosition.top => Border(
                                                  bottom:
                                                      BorderSide(color: theme.primaryColor, width: theme.borderWidth)),
                                              LdAppBarPosition.bottom => Border(
                                                  top: BorderSide(color: theme.primaryColor, width: theme.borderWidth)),
                                            },
                                          false => null,
                                        },
                                        borderRadius: isAttached ? null : LdTheme.of(context).radius(LdSize.s),
                                      ),
                                    ),
                                  ),
                                ),
                                builder: (context, state, child) {
                                  return Positioned(bottom: 0, top: 0, left: state.position, child: child!);
                                },
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
