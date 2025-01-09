import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';

/// Allows you to horizontally center your content on a larger screen by padding it on the sides
class LdContainer extends StatelessWidget {
  final Widget child;

  final EdgeInsets? padding;
  final double maxWidth;

  const LdContainer({
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final theme = LdTheme.of(context, listen: true);

    // Default padding is the balanced L

    var finalPadding = padding ?? (theme.pad(size: LdSize.l) * 1);

    // If the screen is larger than the max width, center the content
    if (size.width > maxWidth) {
      finalPadding = EdgeInsets.symmetric(
          horizontal: max((size.width - maxWidth) / 2, finalPadding.horizontal),
          vertical: finalPadding.vertical);
    }

    return Padding(
      padding: finalPadding,
      child: child,
    );
  }
}
