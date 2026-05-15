import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

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

  bool shouldShowShadow(BuildContext context, bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    return switch (shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder,
          true => true,
        },
    };
  }

  bool shouldShowBorder(BuildContext context, bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    return switch (borderMode) {
      LdAppBarBorderMode.visible => true,
      LdAppBarBorderMode.whenScrolled => isScrolledUnder,
      LdAppBarBorderMode.hidden => false,
      LdAppBarBorderMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder,
          true => true,
        },
    };
  }

  int fillOpacity(bool isScrolledUnder, bool isInBottomSlot) {
    int opacity = 0;

    if (isScrolledUnder || isInBottomSlot) {
      opacity = 255;
    }

    return opacity;
  }

  Color fillColor(BuildContext context, bool isScrolledUnder, {bool isInBottomSlot = false}) {
    final theme = LdTheme.of(context);
    final parentIsSurface = context.read<LdSurfaceInfo?>()?.isSurface ?? false;
    final autoSurfaceColor = parentIsSurface ? LdTheme.of(context).background : LdTheme.of(context).surface;
    final color = backgroundColor ?? autoSurfaceColor;

    return switch (backgroundMode) {
      LdAppBarBackgroundMode.hidden => Colors.transparent,
      LdAppBarBackgroundMode.visible => color,
      LdAppBarBackgroundMode.whenScrolled => Color.alphaBlend(
          color.withAlpha(fillOpacity(isScrolledUnder, isInBottomSlot)),
          autoSurfaceColor,
        ),
      LdAppBarBackgroundMode.adaptive => switch (theme.platform.isDesktop) {
          false => Color.alphaBlend(
              color.withAlpha(fillOpacity(isScrolledUnder, isInBottomSlot)),
              LdTheme.of(context).background,
            ),
          true => color,
        },
    };
  }

  double borderRadius(BuildContext context) {
    final theme = LdTheme.of(context);
    final radius = theme.radiusSize(LdSize.m);
    return radius;
  }

  BoxDecoration buildOutsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required LdAppBarPosition position,
  }) {
    return BoxDecoration(
      color:
          isAttached ? fillColor(context, isScrolledUnder, isInBottomSlot: position == LdAppBarPosition.bottom) : null,
      gradient: !isAttached
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
      boxShadow: [
        if (isAttached)
          ldShadowSticky.copyWith(
            color: shouldShowShadow(context, isScrolledUnder)
                ? ldShadowSticky.color.withAlpha(isScrolledUnder ? 50 : 0)
                : Colors.transparent,
          ),
      ],
      border: isAttached
          ? Border(
              bottom: switch (position) {
                LdAppBarPosition.top => BorderSide(
                    color: shouldShowBorder(context, isScrolledUnder) ? LdTheme.of(context).border : Colors.transparent,
                    width: LdTheme.of(context).borderWidth,
                  ),
                LdAppBarPosition.bottom => BorderSide.none,
              },
              top: switch (position) {
                LdAppBarPosition.bottom => BorderSide(
                    color: shouldShowBorder(context, isScrolledUnder) ? LdTheme.of(context).border : Colors.transparent,
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

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius(context)),
      color: fillColor(context, isScrolledUnder, isInBottomSlot: position == LdAppBarPosition.bottom),
      boxShadow: [
        ldShadowSticky.copyWith(
          color: shouldShowShadow(context, isScrolledUnder) ? ldShadowSticky.color : Colors.transparent,
        ),
      ],
      border: Border.all(
        color: LdTheme.of(context).floatingBorder,
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
}
