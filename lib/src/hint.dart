import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdHintType {
  info,
  warning,
  success,
  error,
  canceled,
  loading,
  pending,
  ongoing,
}

/// A colored badge with an icon and a text
class LdHint extends StatelessWidget {
  final Widget? child;
  final LdHintType type;
  final LdSize size;

  const LdHint({
    this.child,
    required this.type,
    this.size = LdSize.m,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Container(
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
      child: IntrinsicWidth(
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          LdIndicator(
            type: switch (type) {
              LdHintType.error => LdIndicatorType.error,
              LdHintType.info => LdIndicatorType.info,
              LdHintType.success => LdIndicatorType.success,
              LdHintType.warning => LdIndicatorType.warning,
              LdHintType.canceled => LdIndicatorType.canceled,
              LdHintType.loading => LdIndicatorType.loading,
              LdHintType.pending => LdIndicatorType.pending,
              LdHintType.ongoing => LdIndicatorType.ongoing,
            },
          ),
          if (child != null) ...[
            ldSpacerS,
            Expanded(
              child: DefaultTextStyle(
                child: child!,
                style: ldBuildTextStyle(theme, LdTextType.label, LdSize.m),
              ),
            ),
          ]
        ]),
      ),
    );
  }
}

/// Draws an i in emd shapes
class LdInfoIcon extends StatelessWidget {
  const LdInfoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const RotatedBox(quarterTurns: 2, child: LdExclamationIcon());
  }
}

/// An exclamation icon in emd shapes
class LdExclamationIcon extends StatelessWidget {
  const LdExclamationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;

    var size = style.fontSize ?? 14.0;

    return SizedBox(
      height: size,
      width: size,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size * 0.15),
                  bottomLeft: Radius.circular(size * 0.15),
                )),
            height: size * 0.60,
            width: size * 0.25,
          ),
          SizedBox(height: size * 0.12),
          Container(
            decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.circular(size * 0.15)),
            height: size * 0.25,
            width: size * 0.25,
          )
        ],
      ),
    );
  }
}

/// A cross icon.
class LdCrossIcon extends StatelessWidget {
  const LdCrossIcon({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;

    var size = style.fontSize ?? 14.0;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: -0.25 * pi,
              child: Container(
                decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: BorderRadius.circular(size * 0.2)),
                height: size * 1,
                width: size * 0.2,
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: 0.25 * pi,
              child: Container(
                decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: BorderRadius.circular(size * 0.2)),
                height: size * 1,
                width: size * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
