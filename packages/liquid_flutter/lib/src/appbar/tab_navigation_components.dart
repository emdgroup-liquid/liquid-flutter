part of 'tab_navigation.dart';

BorderRadius _tabBarItemRadius(BuildContext context, LdTheme theme) {
  return context.adaptiveRadius.childRadius.max;
}

class _TabBarMetrics {
  static const compactBreakpoint = 500.0;

  const _TabBarMetrics({
    required this.navWidth,
    required this.tabCount,
    required this.minTabWidth,
    required this.padding,
  });

  final double navWidth;
  final int tabCount;
  final double minTabWidth;
  final double padding;

  double get tabSpacing => padding;

  double get totalSpacing => tabSpacing * (tabCount - 1);

  double get availableWidth => navWidth - padding * 2;

  double get tabWidth => max(minTabWidth, (availableWidth - totalSpacing) / tabCount);

  double get tabStride => tabWidth + tabSpacing;

  double get contentWidth => totalSpacing + tabCount * tabWidth;

  bool get compactMode => navWidth < compactBreakpoint;
}

class _LdTabBarScrollArea extends StatelessWidget {
  const _LdTabBarScrollArea({
    required this.controller,
    required this.fadeExtent,
    required this.child,
  });

  final ScrollController controller;
  final double fadeExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LdScrollEdgeFade(
      axis: Axis.horizontal,
      fadeColor: context.surfaceColor,
      fadeExtent: fadeExtent,
      controller: controller,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}

class _LdTabNavigationItem extends StatelessWidget {
  const _LdTabNavigationItem({
    required this.tab,
    required this.active,
    required this.compact,
    required this.width,
    required this.onPressed,
  });

  final LdNavigationTab tab;
  final bool active;
  final bool compact;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LdTouchableSurface(
        active: active,
        noFocusOnTap: true,
        onPressed: onPressed,
        builder: (context, status, _) => _buildSurface(context, status),
      ),
    );
  }

  Widget _buildSurface(BuildContext context, LdTouchableStatus status) {
    final theme = LdTheme.of(context);
    final colors = switch (active) {
      true => ghostColor(theme.primary, theme, status),
      false => neutralGhostColor(theme, status),
    };

    return Container(
      height: !compact ? theme.controlHeight(LdSize.m) : null,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: _tabBarItemRadius(context, theme),
      ),
      child: switch (compact) {
        true => _buildCompactContent(theme, colors),
        false => _buildExpandedContent(theme, colors),
      },
    );
  }

  Widget _buildIcon(LdTheme theme, LdColorBundle colors) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconTheme(
          data: IconThemeData(
            color: colors.icon,
            size: theme.labelSize(LdSize.l),
          ),
          child: tab.icon,
        ),
        if (tab.badge != null && compact)
          Positioned(
            top: switch (tab.badge!.value) {
              null => -3,
              _ => -10,
            },
            right: switch (tab.badge!.value) {
              null => -3,
              int value => switch (value) {
                  < 100 => -10,
                  _ => -15,
                },
            },
            child: _buildBadge(theme, colors),
          ),
      ],
    );
  }

  Widget _buildBadge(LdTheme theme, LdColorBundle colors) {
    final shape = switch (tab.badge!.value) {
      null => BoxShape.circle,
      < 10 => BoxShape.circle,
      _ => BoxShape.rectangle,
    };
    final borderRadius = switch (shape) {
      BoxShape.circle => null,
      BoxShape.rectangle => theme.radius(LdSize.s),
    };
    return Container(
      decoration: BoxDecoration(
        color: tab.badge!.color.center(theme.isDark),
        borderRadius: borderRadius,
        shape: shape,
      ),
      padding: EdgeInsets.all(switch (shape) {
        BoxShape.circle => 3,
        BoxShape.rectangle => 2,
      }),
      child: (tab.badge!.value != null)
          ? LdText.lxs(
              tab.badge!.value.toString(),
              color: tab.badge!.color.contrastingText(
                tab.badge!.color.center(theme.isDark),
              ),
            )
          : null,
    );
  }

  Widget _buildCompactContent(LdTheme theme, LdColorBundle colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(theme, colors),
        ldSpacerXS,
        LdText.ls(
          tab.label,
          color: colors.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).padXS();
  }

  Widget _buildExpandedContent(LdTheme theme, LdColorBundle colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(theme, colors),
        Flexible(
          child: LdText.l(
            tab.label,
            color: colors.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (tab.badge != null && !compact) _buildBadge(theme, colors),
      ],
    ).spaceXS();
  }
}

class _LdTabNavigationIndicator extends StatelessWidget {
  const _LdTabNavigationIndicator({
    required this.tabWidth,
    required this.position,
    required this.springOverridden,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final double tabWidth;
  final double position;
  final bool springOverridden;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return LdSpring(
      springConstant: 20,
      dampingCoefficient: 20,
      mass: 5,
      overriden: springOverridden,
      position: position,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragCancel: onDragCancel,
        onHorizontalDragEnd: onDragEnd,
        // IgnorePointer lets taps reach the tab under the indicator.
        // translucent keeps this detector in the hit-test path so horizontal
        // drags still move it (deferToChild would drop events because the
        // child ignores pointers).
        child: IgnorePointer(
          child: LdTouchableSurface(
            onPressed: () {},
            trackPan: true,
            noFocusOnTap: true,
            builder: (context, status, _) => LdTouchableTouchFeedback(
              scaleFactor: 100,
              status: status,
              child: Container(
                width: tabWidth,
                constraints: BoxConstraints(
                  minHeight: theme.controlHeight(LdSize.m),
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(26),
                  borderRadius: _tabBarItemRadius(context, theme),
                ),
              ),
            ),
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
    );
  }
}
