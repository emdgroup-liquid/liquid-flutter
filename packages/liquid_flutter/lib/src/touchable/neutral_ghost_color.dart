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
      surface: switch (status.onSurface) {
        true => theme.neutralShade(3),
        false => theme.neutralShade(3),
      },
      textColor: palette.primary,
      iconColor: palette.primary,
      border: border,
    );
  }

  if (status.active) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: switch (status.onSurface) {
        true => theme.neutralShade(theme.isDark ? -1 : 3),
        false => theme.neutralShade(2),
      },
      border: border,
      iconColor: palette.primary,
    );
  }

  if (status.hovering) {
    return LdColorBundle.autoText(
      theme: theme,
      surface: switch (status.onSurface) {
        true => theme.neutralShade(2),
        false => theme.neutralShade(2),
      },
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
