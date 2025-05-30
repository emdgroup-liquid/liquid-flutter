import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Divides some content with a horizontal
class LdDivider extends StatelessWidget {
  final double? height;
  final bool insetForLeading;
  const LdDivider({
    this.height,
    this.insetForLeading = false,
    super.key,
  });

  @override
  build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    final divider = Container(
      height: height ?? theme.borderWidth,
      decoration: BoxDecoration(
          color: theme.border,
          borderRadius:
              height == null ? null : BorderRadius.circular(height! / 2)),
    );
    if (insetForLeading) {
      return Padding(
        padding: EdgeInsets.only(left: theme.paddingSize(size: LdSize.m) * 5),
        child: divider,
      );
    }
    return divider;
  }
}
