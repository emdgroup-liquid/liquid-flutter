import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAvatar extends StatelessWidget {
  final Widget child;

  final LdColor? color;

  final bool circular;

  final LdSize size;

  const LdAvatar({
    super.key,
    required this.child,
    this.color,
    this.circular = false,
    this.size = LdSize.m,
  });

  @override
  build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final foreground = color ?? theme.primary;

    final fillColor = foreground.idle(theme.isDark).withAlpha(26);

    final textIconColor = foreground.idle(theme.isDark);

    return Container(
      height: theme.paddingSize(size: size) * 3,
      width: theme.paddingSize(size: size) * 3,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: circular ? null : theme.radius(LdSize.m),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: textIconColor,
            size: theme.paragraphSize(size) * 1.2,
          ),
          child: DefaultTextStyle(
            child: child,
            maxLines: 1,
            style: ldBuildTextStyle(
              theme,
              LdTextType.label,
              LdSize.l,
              color: textIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
