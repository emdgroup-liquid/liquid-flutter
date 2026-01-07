import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

/// Vague surface mode - subtle background with colored text and border
LdColorBundle vagueColor(
  LdColor color,
  LdTheme theme,
  LdTouchableStatus status,
) {
  if (status.disabled) {
    final disabledColor = color.disabled(theme.isDark);
    if (status.active) {
      final foreground = disabledColor.active(theme.isDark);
      return LdColorBundle(
        surface: Colors.transparent,
        text: disabledColor.contrastingText(foreground),
        border: Colors.transparent,
        icon: disabledColor.contrastingText(foreground),
      );
    } else {
      final foreground = disabledColor.idle(theme.isDark);
      return LdColorBundle(
        surface: foreground.withAlpha(26),
        text: disabledColor.contrastingText(foreground.withAlpha(26), background: theme.background),
        border: foreground,
        icon: foreground.withAlpha(153),
      );
    }
  }

  if (status.active) {
    return LdColorBundle(
      surface: color.idle(theme.isDark).withAlpha(51),
      text: color.moveRelative(
        color.active(theme.isDark),
        theme.isDark ? -2 : 2,
      ),
      border: color.active(theme.isDark),
    );
  }

  if (status.hovering) {
    return LdColorBundle(
      surface: color.hover(theme.isDark).withAlpha(51),
      text: color.moveRelative(
        color.hover(theme.isDark),
        theme.isDark ? -2 : 2,
      ),
      border: color.hover(theme.isDark),
    );
  }

  if (status.focus) {
    return LdColorBundle(
      surface: color.focus(theme.isDark).withAlpha(51),
      text: color.focus(theme.isDark),
      border: color.focus(theme.isDark),
    );
  }

  final surface = color.idle(theme.isDark).withAlpha(26);
  return LdColorBundle(
    surface: surface,
    text: color.contrastingText(
      surface,
      background: theme.background,
      isDark: theme.isDark,
    ),
    border: color.idle(theme.isDark),
  );
}
