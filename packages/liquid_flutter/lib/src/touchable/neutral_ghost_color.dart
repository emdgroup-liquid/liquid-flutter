import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

LdColorBundle neutralGhostColor(LdTheme theme, LdTouchableStatus status) {
  final isOdd = status.isOdd;
  final palette = theme.palette;
  final neutral = theme.palette.neutral;
  Color border = Colors.transparent;

  if (status.disabled) {
    return LdColorBundle(
      surface: theme.neutralShade(isOdd ? 2 : 1).withAlpha(23),
      text: theme.neutralShade(5),
      border: border,
      icon: palette.background.withAlpha(disabledAlpha),
    );
  }

  if (status.focus || status.pressed) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: isOdd ? theme.neutralShade(4) : theme.neutralShade(4),
      textColor: palette.primary,
      iconColor: palette.primary,
      border: border,
    );
  }

  if (status.active) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: Color.alphaBlend(theme.primaryColor.withAlpha(20),
          neutral.relative(theme.isDark, (isOdd ? 3 : 2) + (status.onSurface ? 0 : 1))),
      border: border,
      iconColor: palette.primary,
    );
  }

  if (status.pressed) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: neutral.relative(theme.isDark, (isOdd ? 3 : 2) + (status.onSurface ? 0 : 1)),
      border: border,
      iconColor: palette.primary,
    );
  }

  if (status.hovering) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: neutral.relative(theme.isDark, (isOdd ? 3 : 2) + (status.onSurface ? 0 : 1)),
      border: border,
      iconColor: palette.primary,
    );
  }

  return LdColorBundle(
    surface: isOdd ? theme.neutralShade(2).withAlpha(100) : theme.neutralShade(1).withAlpha(0),
    text: theme.isDark ? theme.text : palette.primary.center(theme.isDark),
    border: border,
    icon: palette.primary.center(theme.isDark),
  );
}
