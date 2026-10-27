import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Resolved fill and surface state for one app bar frame.
///
/// [baseColor] is the configured or auto-alternating theme color.
/// [showsFill] is whether that color is painted (vs transparent at scroll top).
/// [childIsSurface] is the [LdSurfaceInfo] descendants of the bar content should see.
class LdAppBarAppearance {
  const LdAppBarAppearance({
    required this.baseColor,
    required this.showsFill,
    required this.childIsSurface,
  });

  final Color baseColor;
  final bool showsFill;
  final bool childIsSurface;

  Color get paintedColor => showsFill ? baseColor : baseColor.withAlpha(0);
}

class LdAppBarDecorationBuilder {
  final Color? backgroundColor;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBorderMode borderMode;
  final LdAppBarBackgroundMode backgroundMode;
  final LdAppBarScrollBehavior scrollBehavior;

  const LdAppBarDecorationBuilder({
    required this.backgroundColor,
    required this.shadowMode,
    required this.borderMode,
    required this.backgroundMode,
    required this.scrollBehavior,
  });

  bool shouldShowShadow(BuildContext context, bool isScrolledUnder, bool isInBottomSlot) {
    final theme = LdTheme.of(context);
    return switch (shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => switch (scrollBehavior.willHideAppBar(context)) {
          true => switch (theme.platform.isDesktop) {
              false => isScrolledUnder || isInBottomSlot,
              true => true,
            },
          false => true,
        }
    };
  }

  bool shouldShowBorder(BuildContext context, bool isScrolledUnder, bool isInBottomSlot) {
    final theme = LdTheme.of(context);
    return switch (borderMode) {
      LdAppBarBorderMode.visible => true,
      LdAppBarBorderMode.whenScrolled => isScrolledUnder,
      LdAppBarBorderMode.hidden => false,
      LdAppBarBorderMode.adaptive => switch (scrollBehavior.willHideAppBar(context)) {
          true => switch (theme.platform.isDesktop) {
              false => isScrolledUnder || isInBottomSlot,
              true => true,
            },
          false => true,
        }
    };
  }

  bool shouldShowBackground(
    BuildContext context,
    bool isScrolledUnder, {
    bool isInBottomSlot = false,
  }) {
    final theme = LdTheme.of(context);
    return switch (backgroundMode) {
      LdAppBarBackgroundMode.hidden => false,
      LdAppBarBackgroundMode.visible => true,
      LdAppBarBackgroundMode.whenScrolled => isScrolledUnder,
      LdAppBarBackgroundMode.adaptive => switch (scrollBehavior.willHideAppBar(context)) {
          true => switch (theme.platform.isDesktop) {
              false => isScrolledUnder || isInBottomSlot,
              true => true,
            },
          // If the app bar will not hide we always show the background.
          false => true,
        },
    };
  }

  Color? buildScrimColor(BuildContext context, bool isScrolledUnder, LdAppBarPosition position) {
    final appearance = resolveAppearance(
      context,
      isScrolledUnder: isScrolledUnder,
      position: position,
    );

    return appearance.showsFill ? appearance.baseColor : null;
  }

  /// Resolves fill color, opacity, and child [LdSurfaceInfo] in one place.
  LdAppBarAppearance resolveAppearance(
    BuildContext context, {
    required bool isScrolledUnder,
    required LdAppBarPosition position,
  }) {
    final theme = LdTheme.of(context);
    final baseColor = backgroundColor ?? theme.surface;
    final showsFill = shouldShowBackground(
      context,
      isScrolledUnder,
      isInBottomSlot: position == LdAppBarPosition.bottom,
    );
    final childIsSurface = switch (backgroundColor) {
      null => showsFill ? true : false,
      _ => false,
    };

    return LdAppBarAppearance(
      baseColor: baseColor,
      showsFill: showsFill,
      childIsSurface: childIsSurface,
    );
  }

  BoxDecoration buildOutsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required LdAppBarPosition position,
  }) {
    final appearance = resolveAppearance(
      context,
      isScrolledUnder: isScrolledUnder,
      position: position,
    );

    final isInBottomSlot = position == LdAppBarPosition.bottom;

    return BoxDecoration(
      color: !isAttached ? null : appearance.paintedColor,
      boxShadow: [
        if (isAttached)
          ldShadowSticky.copyWith(
              color:
                  ldShadowSticky.color.withAlpha(shouldShowShadow(context, isScrolledUnder, isInBottomSlot) ? 50 : 0)),
      ],
      border: isAttached
          ? Border(
              bottom: switch (position) {
                LdAppBarPosition.top => BorderSide(
                    color: LdTheme.of(context)
                        .border
                        .withAlpha(shouldShowBorder(context, isScrolledUnder, isInBottomSlot) ? 255 : 0),
                    width: LdTheme.of(context).borderWidth,
                  ),
                LdAppBarPosition.bottom => BorderSide.none,
              },
              top: switch (position) {
                LdAppBarPosition.bottom => BorderSide(
                    color: LdTheme.of(context)
                        .border
                        .withAlpha(shouldShowBorder(context, isScrolledUnder, isInBottomSlot) ? 255 : 0),
                    width: LdTheme.of(context).borderWidth,
                  ),
                LdAppBarPosition.top => BorderSide.none,
              },
            )
          : null,
    );
  }

  BoxDecoration buildInsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required LdAppBarPosition position,
  }) {
    if (isAttached) {
      return const BoxDecoration();
    }

    final appearance = resolveAppearance(
      context,
      isScrolledUnder: isScrolledUnder,
      position: position,
    );

    final isInBottomSlot = position == LdAppBarPosition.bottom;
    return BoxDecoration(
      borderRadius: context.adaptiveRadius.childRadius.max,
      color: appearance.paintedColor,
      boxShadow: [
        ldShadowSticky.copyWith(
          color: ldShadowSticky.color.withAlpha(shouldShowShadow(context, isScrolledUnder, isInBottomSlot) ? 50 : 0),
        ),
      ],
      border: Border.all(
        color: LdTheme.of(context)
            .floatingBorder
            .withAlpha(shouldShowBorder(context, isScrolledUnder, isInBottomSlot) ? 255 : 0),
        width: LdTheme.of(context).borderWidth,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}

extension AtLeastBorderRadius on BorderRadius {
  BorderRadius atLeast(BorderRadius other) {
    return BorderRadius.only(
      topLeft: topLeft.atLeast(other.topLeft),
      topRight: topRight.atLeast(other.topRight),
      bottomLeft: bottomLeft.atLeast(other.bottomLeft),
      bottomRight: bottomRight.atLeast(other.bottomRight),
    );
  }
}

extension AtLeast on Radius {
  Radius atLeast(Radius other) {
    assert(x == y, "Radius must be circular");
    assert(other.x == other.y, "Other radius must be circular");
    return Radius.circular(max(x, other.x));
  }
}

extension TrimToAppBarPosition on EdgeInsets {
  EdgeInsets trimToAppBarPosition(LdAppBarPosition position) {
    return copyWith(
      top: position == LdAppBarPosition.top ? top : 0,
      bottom: position == LdAppBarPosition.bottom ? bottom : 0,
    );
  }

  EdgeInsets positionOnly(LdAppBarPosition position) {
    return copyWith(
      top: position == LdAppBarPosition.top ? top : 0,
      bottom: position == LdAppBarPosition.bottom ? bottom : 0,
      left: 0,
      right: 0,
    );
  }
}

class AppbarOutsideContainer extends StatelessWidget {
  final Widget child;
  final LdAppBarFrameMetrics metrics;
  final LdAppBarBorderMode borderMode;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBackgroundMode backgroundMode;
  final Color? backgroundColor;

  const AppbarOutsideContainer({
    super.key,
    required this.child,
    required this.borderMode,
    required this.shadowMode,
    required this.backgroundMode,
    required this.backgroundColor,
    required this.metrics,
  });

  bool get showsFill => switch (metrics.isAttached) {
        false => false,
        true => switch (backgroundMode) {
            LdAppBarBackgroundMode.hidden => false,
            LdAppBarBackgroundMode.visible => true,
            LdAppBarBackgroundMode.whenScrolled => metrics.isScrolledUnder,
            LdAppBarBackgroundMode.adaptive => (metrics.willHide && metrics.isScrolledUnder) || !metrics.willHide,
          }
      };

  bool _showShadow() {
    return switch (shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => metrics.isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => (metrics.willHide && metrics.isScrolledUnder) || !metrics.willHide,
    };
  }

  bool _showBorder() {
    return switch (metrics.isAttached) {
      true => switch (borderMode) {
          LdAppBarBorderMode.visible => true,
          LdAppBarBorderMode.whenScrolled => metrics.isScrolledUnder,
          LdAppBarBorderMode.hidden => false,
          LdAppBarBorderMode.adaptive => showsFill
        },
      false => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final color = backgroundColor ?? theme.surface;
    final borderColor = theme.floatingBorder.withAlpha(_showBorder() ? 255 : 0);

    return Container(
      padding: metrics.outerMargin,
      decoration: BoxDecoration(
          boxShadow: [
            if (!metrics.isAttached)
              ldShadowSticky.copyWith(
                color: ldShadowSticky.color.withAlpha(_showShadow() ? 20 : 0),
              )
          ],
          color: (backgroundColor ?? theme.surface).withAlpha(showsFill ? 255 : 0),
          border: Border(
            bottom: switch (metrics.position) {
              LdAppBarPosition.top => BorderSide(
                  color: borderColor,
                  width: theme.borderWidth,
                ),
              _ => BorderSide.none,
            },
            top: switch (metrics.position) {
              LdAppBarPosition.bottom => BorderSide(
                  color: borderColor,
                  width: theme.borderWidth,
                ),
              _ => BorderSide.none,
            },
          )),
      child: Provider.value(
        value: LdSurfaceInfo(
          isSurface: showsFill && color == theme.surface,
        ),
        child: Provider.value(
          value: context.adaptiveRadius.shrinkByInsets(metrics.outerMargin).collapseToSide(metrics.position),
          child: child,
        ),
      ),
    );
  }
}

class AppbarInsideContainer extends StatelessWidget {
  final Widget child;
  final LdAppBarFrameMetrics metrics;

  final LdAppBarBorderMode borderMode;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBackgroundMode backgroundMode;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const AppbarInsideContainer({
    super.key,
    required this.child,
    required this.metrics,
    required this.borderMode,
    required this.shadowMode,
    required this.backgroundMode,
    required this.backgroundColor,
    this.padding,
  });

  bool get showsFill => switch (metrics.isAttached) {
        true => false,
        false => switch (backgroundMode) {
            LdAppBarBackgroundMode.hidden => false,
            LdAppBarBackgroundMode.visible => true,
            LdAppBarBackgroundMode.whenScrolled => metrics.isScrolledUnder,
            LdAppBarBackgroundMode.adaptive => (metrics.willHide && metrics.isScrolledUnder) || !metrics.willHide,
          }
      };

  bool _showBorder() {
    return switch (metrics.isAttached) {
      true => false,
      false => switch (borderMode) {
          LdAppBarBorderMode.visible => true,
          LdAppBarBorderMode.whenScrolled => metrics.isScrolledUnder,
          LdAppBarBorderMode.hidden => false,
          LdAppBarBorderMode.adaptive => showsFill,
        },
    };
  }

  bool _showShadow() {
    return switch (shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => metrics.isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => showsFill,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final color = backgroundColor ?? theme.surface;
    final borderColor = theme.floatingBorder.withAlpha(_showBorder() ? 255 : 0);
    final shadowColor = ldShadowSticky.color.withAlpha(_showShadow() ? 20 : 0);
    final padding = this.padding ?? theme.pad(size: LdSize.s);

    final ownRadius = context.adaptiveRadius.childRadius.max.atLeast(
      theme.radius(LdSize.m),
    );

    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(showsFill ? 255 : 0),
        boxShadow: [
          if (!metrics.isAttached)
            ldShadowSticky.copyWith(
              color: shadowColor,
            )
        ],
        borderRadius: ownRadius,
        border: Border.all(
          color: borderColor,
          width: theme.borderWidth,
        ),
      ),
      padding: padding,
      child: Provider.value(
        value: LdSurfaceInfo(
            isSurface: switch (showsFill) {
          true => color == theme.surface,
          false => context.isSurface,
        }),
        child: Provider.value(
          value: LdAdaptiveRadius(
            ownRadius: ownRadius,
            insets: padding,
          ).collapseToSide(metrics.position),
          child: child,
        ),
      ),
    );
  }
}
