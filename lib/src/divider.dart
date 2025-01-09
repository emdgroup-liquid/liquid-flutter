import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Divides some content with a horizontal
class LdDivider extends StatelessWidget {
  final double? height;
  const LdDivider({
    this.height,
    super.key,
  });

  @override
  build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    return Container(
      height: height ?? theme.borderWidth,
      decoration: BoxDecoration(
          color: theme.border,
          borderRadius:
              height == null ? null : BorderRadius.circular(height! / 2)),
    );
  }
}
