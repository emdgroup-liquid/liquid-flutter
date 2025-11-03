import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:provider/provider.dart';

class LdNavigationTab {
  final String label;
  final Widget icon;
  final String route;
  final bool Function(BuildContext context)? isActive;

  const LdNavigationTab({required this.label, required this.icon, required this.route, this.isActive});
}

class TabNavigation extends StatefulWidget {
  final String activeRoute;
  final void Function(String route) onTabPressed;
  final List<LdNavigationTab> tabs;

  const TabNavigation({super.key, required this.activeRoute, required this.tabs, required this.onTabPressed});

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  final FocusNode _focusNode = FocusNode();

  LdScaffoldLayoutState get _layoutState {
    return context.read<LdScaffoldLayoutState>();
  }

  LdScaffoldSlot get _slot {
    return _layoutState.slot;
  }

  LdScaffoldAppBarState? get _appBarState {
    return _slot.role == AppBarRole.primary ? _layoutState.appBarState : _layoutState.secondaryAppBarState;
  }

  void _updateMargin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_appBarState == null) return;
      LdScaffoldState.maybeOf(context)?.onAppBarMarginChange(_slot, _outsideContainerPadding);
    });
  }

  EdgeInsets get _outsideContainerPadding {
    final pad = LdTheme.of(context).pad(size: LdSize.s);
    final viewPadding = MediaQuery.of(context).viewPadding;

    final minimumPadding =
        (viewPadding.atLeast(pad)).trimToEffectivePosition(_slot.effectivePosition ?? EffectivePosition.top);

    // Now we need to add the padding for the other app bars, that are either in the same scaffold or in the parent scaffold.

    final otherAppBarHeight = _layoutState.effectiveHeightOfOthers(_slot) ?? 0;

    return (minimumPadding)
        .atLeast(EdgeInsets.only(
          top: _slot.effectivePosition == EffectivePosition.top ? otherAppBarHeight : 0,
          bottom: _slot.effectivePosition == EffectivePosition.bottom ? otherAppBarHeight : 0,
        ))
        .trimToEffectivePosition(_slot.effectivePosition ?? EffectivePosition.top);
  }

  EdgeInsets _padding(BuildContext context) {
    final theme = LdTheme.of(context);

    if (_layoutState.slot == LdScaffoldSlot.secondaryAppBarTop) {
      return theme.pad(size: LdSize.s).atLeast(EdgeInsets.all(theme.screenRadius / 4)).copyWith(
            top: 0,
          );
    }

    return theme.pad(size: LdSize.xs);
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

  Border? get _border {
    final theme = LdTheme.of(context, listen: true);
    if (_layoutState.slot == LdScaffoldSlot.secondaryAppBarTop) {
      return Border(bottom: BorderSide(color: theme.border, width: theme.borderWidth));
    }
    return Border.all(color: theme.border, width: theme.borderWidth);
  }

  void _onSizeChange(Size size) {
    final scaffold = LdScaffoldState.maybeOf(context);
    if (scaffold == null) return;
    scaffold.onAppBarSizeChange(_layoutState.slot, size);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return LdTouchableSurface(
        focusNode: _focusNode,
        onPressed: () {},
        builder: (context, colors, status, _) {
          _updateMargin();
          return LdTouchableTouchFeedback(
            status: status,
            child: Container(
              margin: _outsideContainerPadding,
              child: MeasureSize(
                onSizeChange: _onSizeChange,
                child: Container(
                  padding: _padding(context),
                  decoration: BoxDecoration(
                    color: LdTheme.of(context).surface,
                    borderRadius: LdTheme.of(context).radius(LdSize.m),
                    boxShadow: _layoutState.slot == LdScaffoldSlot.secondaryAppBarTop ? null : [ldShadowSticky],
                    border: _border,
                  ),
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
                                            borderRadius: LdTheme.of(context).radius(LdSize.m),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              final isActive = widget.activeRoute == tab.route;
                                              final iconColor = isActive ? theme.primaryColor : theme.palette.text;
                                              final textColor = isActive ? theme.primaryColor : theme.palette.text;
                                              final icon = IconTheme(
                                                data: IconThemeData(color: iconColor, size: theme.labelSize(LdSize.l)),
                                                child: tab.icon,
                                              );

                                              if (constraints.maxWidth < 500) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [icon, ldSpacerXS, LdText.ls(tab.label, color: textColor)],
                                                ).padXS();
                                              }
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  icon,
                                                  ldSpacerS,
                                                  Flexible(child: LdText.l(tab.label, color: textColor)),
                                                ],
                                              ).padXS();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                              .toList(),
                        ).spaceM(),
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
                                    borderRadius: LdTheme.of(context).radius(LdSize.m),
                                  ),
                                ),
                              ),
                            ),
                            builder: (context, state, child) {
                              return Positioned(bottom: 0, top: 0, left: state.position, child: child!);
                            }),
                      ],
                    );
                  }),
                ),
              ),
            ),
          );
        });
  }
}
