import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Soft edge fades over [child] (top and/or bottom).
///
/// Overlay only — does not change layout size. Used by reasoning tickers and
/// optionally by [LdStreamReveal].
class LdEdgeFade extends StatelessWidget {
  final Widget child;
  final bool fadeTop;
  final bool fadeBottom;
  final double fadeExtent;
  final Color? fadeColor;

  const LdEdgeFade({
    super.key,
    required this.child,
    this.fadeTop = false,
    this.fadeBottom = true,
    this.fadeExtent = 24,
    this.fadeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final color = fadeColor ?? theme.background;

    if (!fadeTop && !fadeBottom) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        child,
        if (fadeTop)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: fadeExtent,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (fadeBottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: fadeExtent,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0),
                      color,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
