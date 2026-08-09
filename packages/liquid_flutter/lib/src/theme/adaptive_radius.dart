import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdAdaptiveRadius {
  final BorderRadius ownRadius;
  final EdgeInsets insets;
  final bool isRoot;

  const LdAdaptiveRadius({
    required this.ownRadius,
    required this.insets,
    this.isRoot = false,
  });

  BorderRadius get childRadius => shrinkBy(insets);

  BorderRadius shrinkBy(EdgeInsets insets) {
    return BorderRadius.only(
      topLeft: Radius.circular(math.max(0, ownRadius.topLeft.x - math.max(insets.top, insets.left))),
      topRight: Radius.circular(math.max(0, ownRadius.topRight.x - math.max(insets.top, insets.right))),
      bottomLeft: Radius.circular(math.max(0, ownRadius.bottomLeft.x - math.max(insets.bottom, insets.left))),
      bottomRight: Radius.circular(math.max(0, ownRadius.bottomRight.x - math.max(insets.bottom, insets.right))),
    );
  }

  factory LdAdaptiveRadius.fromTheme(LdTheme theme, BuildContext context) {
    return LdAdaptiveRadius(
      ownRadius: BorderRadius.circular(theme.screenRadius),
      insets: MediaQuery.of(context).padding,
      isRoot: true,
    );
  }

  factory LdAdaptiveRadius.zero() {
    return const LdAdaptiveRadius(
      ownRadius: BorderRadius.zero,
      insets: EdgeInsets.zero,
    );
  }

  @override
  String toString() {
    return 'LdAdaptiveRadius(ownRadius: $ownRadius, insets: $insets, isRoot: $isRoot)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LdAdaptiveRadius) {
      return ownRadius == other.ownRadius && insets == other.insets && isRoot == other.isRoot;
    }
    return false;
  }

  @override
  int get hashCode => ownRadius.hashCode ^ insets.hashCode ^ isRoot.hashCode;
}

extension AdaptiveRadiusExtension on BuildContext {
  LdAdaptiveRadius get adaptiveRadius => watch<LdAdaptiveRadius?>() ?? LdAdaptiveRadius.zero();
}

extension AdjustToRadius on BorderRadius {
  EdgeInsets get adjustToRadius {
    return EdgeInsets.only(
      top: topLeft.x,
      bottom: bottomLeft.x,
      left: topLeft.x,
      right: topRight.x,
    );
  }

  BorderRadius get max {
    final maxRadius = math.max(
        math.max(
          topLeft.x,
          topRight.x,
        ),
        math.max(bottomLeft.x, bottomRight.x));
    return BorderRadius.circular(maxRadius);
  }
}
