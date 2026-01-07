import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';

/// Allows you to horizontally center your content on a larger screen by padding it on the sides
class LdContainer extends StatelessWidget {
  final Widget child;

  final EdgeInsets? padding;
  final double? maxWidth;

  const LdContainer({
    required this.child,
    this.maxWidth,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Default padding is the balanced L

    final theme = LdTheme.of(context, listen: true);

    final maxWidth = this.maxWidth ?? theme.sizingConfig.containerMaxWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        var finalPadding = padding ?? (theme.pad(size: LdSize.l) * 1);

        // If the screen is larger than the max width, center the content
        if (constraints.maxWidth > maxWidth) {
          finalPadding = EdgeInsets.symmetric(
            horizontal: max((constraints.maxWidth - maxWidth) / 2, finalPadding.horizontal),
            vertical: finalPadding.vertical,
          );
        }
        return Padding(
          padding: finalPadding,
          child: SizedBox(
            width: constraints.maxWidth,
            child: child,
          ),
        );
      },
    );
  }
}
