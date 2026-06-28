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

  const LdAppBarDecorationBuilder({
    this.backgroundColor,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
  });

  bool shouldShowShadow(BuildContext context, bool isScrolledUnder, bool isInBottomSlot) {
    final theme = LdTheme.of(context);
    return switch (shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder || isInBottomSlot,
          true => true,
        },
    };
  }

  bool shouldShowBorder(BuildContext context, bool isScrolledUnder, bool isInBottomSlot) {
    final theme = LdTheme.of(context);
    return switch (borderMode) {
      LdAppBarBorderMode.visible => true,
      LdAppBarBorderMode.whenScrolled => isScrolledUnder,
      LdAppBarBorderMode.hidden => false,
      LdAppBarBorderMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder || isInBottomSlot,
          true => true,
        },
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
      LdAppBarBackgroundMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder || isInBottomSlot,
          true => true,
        },
    };
  }

  /// Resolves fill color, opacity, and child [LdSurfaceInfo] in one place.
  LdAppBarAppearance resolveAppearance(
    BuildContext context, {
    required bool isScrolledUnder,
    required LdAppBarPosition position,
  }) {
    final theme = LdTheme.of(context);
    final parentIsSurface = context.read<LdSurfaceInfo>().isSurface;
    final baseColor = backgroundColor ?? theme.surface;
    final showsFill = shouldShowBackground(
      context,
      isScrolledUnder,
      isInBottomSlot: position == LdAppBarPosition.bottom,
    );
    final childIsSurface = switch (backgroundColor) {
      null => showsFill ? !parentIsSurface : parentIsSurface,
      _ => false,
    };

    return LdAppBarAppearance(
      baseColor: baseColor,
      showsFill: showsFill,
      childIsSurface: childIsSurface,
    );
  }

  double borderRadius(BuildContext context) {
    final theme = LdTheme.of(context);
    final radius = theme.radiusSize(LdSize.l);
    return radius;
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
      borderRadius: BorderRadius.circular(borderRadius(context)),
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
