import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAvatar extends StatelessWidget {
  final Widget child;

  final LdColor? color;

  const LdAvatar({super.key, required this.child, this.color});

  @override
  build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final foreground = color ?? theme.primary;

    final textIconColor = foreground.contrastingText(
      foreground.idle(theme.isDark),
    );

    return Container(
      height: theme.paddingSize() * 3,
      width: theme.paddingSize() * 3,
      decoration: BoxDecoration(
        color: foreground.idle(theme.isDark),
        borderRadius: theme.radius(LdSize.s),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: textIconColor,
            size: theme.paragraphSize(null) * 1.2,
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
