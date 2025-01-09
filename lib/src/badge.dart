import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A rounded fully opaque label with a background [color].
/// Can be used to display a small amount of information.
///
class LdBadge extends StatelessWidget {
  final Widget child;
  final LdColor? color;

  final bool symmetric;
  final int? maxLines;
  final LdSize size;

  const LdBadge({
    required this.child,
    this.color,
    this.size = LdSize.m,
    this.symmetric = false,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final contentSize = theme.labelSize(size);

    EdgeInsets padding = EdgeInsets.symmetric(
        vertical: contentSize / 3, horizontal: contentSize / 2);

    if (symmetric) {
      padding = EdgeInsets.all(contentSize / 3);
    }

    final usedColor = color ?? theme.palette.primary;

    final background = usedColor.center(theme.isDark);
    final textColor = usedColor.contrastingText(background);

    return Container(
      key: const ValueKey("badgeContainer"),
      constraints: BoxConstraints(
        minWidth: contentSize * 1.2,
        minHeight: contentSize * 1.2,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(contentSize),
      ),
      child: DefaultTextStyle(
        textAlign: TextAlign.center,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: contentSize * 0.8,
          color: textColor,
          package: theme.fontFamilyPackage,
          fontFamily: theme.fontFamily,
          height: maxLines == 1 ? 1 : 1.2,
          fontWeight: FontWeight.bold,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: textColor,
            size: contentSize,
          ),
          child: child,
        ),
      ),
    );
  }
}
