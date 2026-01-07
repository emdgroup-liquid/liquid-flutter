import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class RadiusAwarePadding extends StatelessWidget {
  final LdSize fallbackSize;
  final LdSize innerRadiusSize;
  final EdgeInsets? minPadding;

  final BoxDecoration? decoration;
  final Widget child;

  const RadiusAwarePadding({
    super.key,
    required this.fallbackSize,
    this.innerRadiusSize = LdSize.s,
    required this.child,
    this.decoration,
    this.minPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    final innerRadius = theme.radiusSize(innerRadiusSize);

    // Use fixed radius matching app bar (LdSize.m)
    final radius = theme.radiusSize(LdSize.m);

    final paddingAmount = max(0.0, radius - innerRadius);

    EdgeInsets padding;
    if (paddingAmount == 0) {
      padding = minPadding ?? theme.pad(size: fallbackSize);
    } else {
      padding = EdgeInsets.all(paddingAmount);
    }

    return Container(
      padding: padding,
      decoration: decoration?.copyWith(
            borderRadius: BorderRadius.circular(radius),
          ) ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
      child: child,
    );
  }
}
