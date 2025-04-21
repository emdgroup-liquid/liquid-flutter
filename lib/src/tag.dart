import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

// a small tag with colored background and text
class LdTag extends StatelessWidget {
  final Widget child;

  final Function? onDismiss;
  final LdSize size;

  final LdColor? color;
  const LdTag({Key? key, required this.child, this.color, this.onDismiss, this.size = LdSize.m}) : super(key: key);

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
      key: const ValueKey("tagBox"),
      child: Padding(
        padding: EdgeInsets.all(_padding(theme) / 2),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDismiss != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.clear,
                    color: text,
                    size: fontSize,
                  ),
                ),
              Expanded(
                child: DefaultTextStyle(
                    child: child,
                    style: TextStyle(
                      height: 1,
                      color: text,
                      overflow: TextOverflow.ellipsis,
                      package: theme.fontFamilyPackage,
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    )),
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: theme.radius(LdSize.s),
        border: Border.all(
          color: background,
          width: 1,
        ),
        color: background,
      ),
    );
  }
}
