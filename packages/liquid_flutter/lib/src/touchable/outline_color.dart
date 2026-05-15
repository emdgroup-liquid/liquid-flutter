import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

/// Outline surface mode - transparent background with colored text and border
LdColorBundle outlineColor(
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
      return LdColorBundle(
        surface: Colors.transparent,
        text: theme.textMuted,
        border: theme.border,
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

  return LdColorBundle(
    surface: status.onSurface ? theme.background : theme.surface,
    text: theme.text,
    border: theme.border,
  );
}
