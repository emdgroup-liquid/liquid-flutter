import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'tag.variants.g.dart';

// a small tag with colored background and text
@Variants([
  Variant('success', defaults: {'color': 'LdTheme.of(context).success'}),
  Variant('warning', defaults: {'color': 'LdTheme.of(context).warning'}),
  Variant('error', defaults: {'color': 'LdTheme.of(context).error'}),
])
class _LdTagWidget extends StatelessWidget {
  final Widget child;

  final Function? onDismiss;
  final LdSize size;

  final LdColor? color;
  const _LdTagWidget({
    required this.child,
    this.color,
    this.onDismiss,
    this.size = LdSize.m,
  });

  double _padding(LdTheme theme) {
    return theme.paddingSize(size: size);
  }

  double _fontSize(LdTheme theme) {
    return theme.labelSize(size);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final color = this.color ?? theme.palette.primary;

    final onSurface = LdSurfaceInfo.of(context, listen: true).isSurface;

    final background = (!onSurface
            ? color.center(theme.isDark)
            : color.moveRelative(color.center(theme.isDark), theme.isDark ? -2 : 2))
        .withAlpha(theme.isDark ? 50 : 100);

    final text = color.moveRelative(
      color.center(theme.isDark),
      onSurface ? (theme.isDark ? -4 : 4) : (theme.isDark ? -3 : 4),
    );

    final fontSize = _fontSize(theme);

    return Container(
      padding: EdgeInsets.all(_padding(theme) / 2),
      key: const ValueKey("tagBox"),
      decoration: BoxDecoration(
        borderRadius: theme.radius(LdSize.s),
        border: Border.all(
          color: background,
          width: 1,
        ),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                color: text,
                size: fontSize,
              ),
              child: DefaultTextStyle(
                  style: TextStyle(
                    height: 1,
                    color: text,
                    overflow: TextOverflow.ellipsis,
                    package: theme.fontFamilyPackage,
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                  child: child),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: () => onDismiss?.call(),
              child: Icon(
                Icons.clear,
                color: text,
                size: fontSize,
              ),
            ),
        ],
      ).spaceS(),
    );
  }
}
