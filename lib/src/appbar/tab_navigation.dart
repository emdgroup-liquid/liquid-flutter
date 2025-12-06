import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/haptics.dart';

class LdNavigationTab {
  final String label;
  final Widget icon;
  final String route;
  final bool Function(BuildContext context)? isActive;

  const LdNavigationTab({required this.label, required this.icon, required this.route, this.isActive});
}

enum TabAttachedMode {
  always,
  desktopOnly,
  mobileOnly,
  whenTop,
  whenBottom,
}

class TabNavigation extends StatefulWidget {
  final String activeRoute;
  final void Function(String route) onTabPressed;
  final List<LdNavigationTab> tabs;
  final TabAttachedMode attachedMode;
  final AppBarPosition position;
  final LdAppBarScrollBehavior scrollBehavior;
  final int order;

  const TabNavigation({
    super.key,
    required this.activeRoute,
    required this.tabs,
    required this.onTabPressed,
    this.attachedMode = TabAttachedMode.whenTop,
    this.position = AppBarPosition.bottom,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
  });

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  final FocusNode _focusNode = FocusNode();

  bool get _attached {
    final theme = LdTheme.of(context, listen: true);
    return switch (widget.attachedMode) {
      TabAttachedMode.always => true,
      TabAttachedMode.desktopOnly => theme.platform.isDesktop,
      TabAttachedMode.mobileOnly => !theme.platform.isDesktop,
      TabAttachedMode.whenTop => _effectivePosition == AppBarPosition.top,
      TabAttachedMode.whenBottom => _effectivePosition == AppBarPosition.bottom,
    };
  }

  AppBarPosition get _effectivePosition {
    return widget.position;
  }

  int _activeIndex() {
    return widget.tabs.indexWhere((tab) {
      if (tab.isActive != null) {
        return tab.isActive!(context);
      }
      return widget.activeRoute == tab.route;
    });
  }

  double _indicatorPosition = 0;

  double _navWidth = 0;

  @override
  void didUpdateWidget(TabNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeRoute != widget.activeRoute) {
      _updateIndicatorPosition();
    }
  }

  void _updateIndicatorPosition() {
    setState(() {
      _indicatorPosition = _activeIndex() * _navWidth / widget.tabs.length;
    });
  }

  double get _tabWidth => _navWidth / widget.tabs.length;

  double _dragStartPosition = 0;
  int _lastDraggedTabIndex = 0;
  double _dragStartIndicatorPosition = 0;
  bool _dragging = false;

  int _getClosestTab(BuildContext context) {
    // Calculate which tab the indicator is closest to based on its left position
    final closestTabIndex = (_indicatorPosition / _tabWidth).round().clamp(0, widget.tabs.length - 1);
    return closestTabIndex;
  }

  void _onIndicatorDragEnd(DragEndDetails details) {
    final closestTabIndex = _getClosestTab(context);
    widget.onTabPressed(widget.tabs[closestTabIndex].route);
    _updateIndicatorPosition();
    setState(() {
      _dragging = false;
    });
  }

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

  BoxDecoration? get _outsideDecoration {
    final theme = LdTheme.of(context, listen: true);
    if (_attached) {
      return BoxDecoration(
          color: theme.surface,
          border: switch (_effectivePosition) {
            AppBarPosition.top => Border(bottom: BorderSide(color: theme.border, width: theme.borderWidth)),
            AppBarPosition.bottom => Border(top: BorderSide(color: theme.border, width: theme.borderWidth)),
          });
    }
    return BoxDecoration(
        gradient: LinearGradient(
      begin: switch (_effectivePosition) {
        AppBarPosition.top => Alignment.bottomCenter,
        AppBarPosition.bottom => Alignment.topCenter,
      },
      end: switch (_effectivePosition) {
        AppBarPosition.top => Alignment.topCenter,
        AppBarPosition.bottom => Alignment.bottomCenter,
      },
      stops: const [0, 0.3],
      colors: [
        LdTheme.of(context).absolute.withAlpha(0),
        LdTheme.of(context).absolute.withAlpha(200),
      ],
    ));
  }

  BoxDecoration? get _insideDecoration {
    if (_attached) {
      return const BoxDecoration();
    }
    final theme = LdTheme.of(context, listen: true);
    return BoxDecoration(
      color: theme.surface,
      border: Border.all(color: theme.floatingBorder, width: theme.borderWidth),
      borderRadius: LdTheme.of(context).radius(LdSize.m),
    );
  }

  EdgeInsets? get _insidePadding {
    if (_attached) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    return LdAppBarRegistryEntry(
      order: widget.order,
      child: Builder(
        builder: (context) {
          final theme = LdTheme.of(context, listen: true);
          return LdAppBarScrollWrapper(
            position: widget.position,
            scrollBehavior: widget.scrollBehavior,
            child: LdTouchableSurface(
              focusNode: _focusNode,
              onPressed: () {},
              builder: (context, colors, status, _) {
                return LdTouchableTouchFeedback(
                  status: status,
                  child: AppBarFrame(
                    position: _effectivePosition,
                    attached: _attached,
                    insidePadding: _insidePadding,
                    outsideDecoration: _outsideDecoration,
                    outsideMinPadding: _attached ? EdgeInsets.zero : null,
                    insideDecoration: _insideDecoration,
                    insetBorderRadius: !_attached,
                    child: LayoutBuilder(builder: (context, constraints) {
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.tabs
                                .map((tab) => Expanded(
                                      child: LdTouchableSurface(
                                        mode: LdTouchableSurfaceMode.neutralGhost,
                                        onPressed: () => _onTabTap(tab.route),
                                        builder: (context, colors, status, _) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: colors.surface,
                                              borderRadius: _attached ? null : LdTheme.of(context).radius(LdSize.m),
                                            ),
                                            child: Builder(
                                              builder: (context) {
                                                final iconColor = theme.palette.text;
                                                final textColor = theme.palette.text;
                                                final icon = IconTheme(
                                                  data:
                                                      IconThemeData(color: iconColor, size: theme.labelSize(LdSize.l)),
                                                  child: tab.icon,
                                                );

                                                if (constraints.maxWidth < 500) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      icon,
                                                      ldSpacerXS,
                                                      LdText.ls(tab.label, color: textColor)
                                                    ],
                                                  ).padXS();
                                                }
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    icon,
                                                    ldSpacerS,
                                                    Flexible(child: LdText.l(tab.label, color: textColor)),
                                                  ],
                                                ).padS();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
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
                                  width: constraints.maxWidth / widget.tabs.length,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withAlpha(100),
                                    border: switch (_attached) {
                                      true => switch (_effectivePosition) {
                                          AppBarPosition.top => Border(
                                              bottom: BorderSide(color: theme.primaryColor, width: theme.borderWidth)),
                                          AppBarPosition.bottom => Border(
                                              top: BorderSide(color: theme.primaryColor, width: theme.borderWidth)),
                                        },
                                      false => Border.all(color: theme.primaryColor, width: theme.borderWidth),
                                    },
                                    borderRadius: _attached ? null : LdTheme.of(context).radius(LdSize.m),
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
            ),
          );
        },
      ),
    );
  }
}
