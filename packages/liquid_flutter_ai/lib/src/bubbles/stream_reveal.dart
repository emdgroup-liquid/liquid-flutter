import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/edge_fade.dart';

/// Soft leading-edge fade for growing agent content (streaming).
///
/// Layout-only: [AnimatedSize] follows whatever [child] lays out (markdown,
/// cards, custom blocks). A bottom gradient softens the newest edge while
/// [active] is true — no text parsing.
class LdStreamReveal extends StatelessWidget {
  final Widget child;

  /// When true, paints the bottom fade. Size animation always runs so growth
  /// stays smooth across stream chunks.
  final bool active;

  /// Height of the bottom fade band.
  final double fadeExtent;

  final Duration duration;
  final Curve curve;

  /// Opaque end of the fade. Defaults to [LdTheme.background].
  final Color? fadeColor;

  const LdStreamReveal({
    super.key,
    required this.child,
    this.active = true,
    this.fadeExtent = 12,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
    this.fadeColor,
  });

  @override
  Widget build(BuildContext context) {
    final animate = !ldDisableAnimations;

    if (!animate) {
      return child;
    }

    return LdEdgeFade(
      fadeTop: false,
      fadeBottom: active,
      fadeExtent: fadeExtent,
      fadeColor: fadeColor,
      child: AnimatedSize(
        duration: duration,
        curve: curve,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: AnimatedPadding(
          duration: duration,
          curve: curve,
          padding: EdgeInsets.only(bottom: active ? fadeExtent : 0),
          child: child,
        ),
      ),
    );
  }
}
