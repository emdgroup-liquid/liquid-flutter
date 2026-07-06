import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Solid surface mode - filled background with contrasting text
LdColorBundle solidColor(
  LdColor color,
  LdTheme theme,
  LdTouchableStatus status,
) {
  if (status.disabled) {
    final disabledColor = color.disabled(theme.isDark);
    if (status.active) {
      return LdColorBundle(
        surface: disabledColor.active(theme.isDark),
        text: disabledColor
            .contrastingText(
              disabledColor.active(theme.isDark),
              background: theme.background,
              isDark: theme.isDark,
            )
            .withAlpha(disabledAlpha),
        border: Colors.transparent,
      );
    }
    return LdColorBundle(
      surface: disabledColor.idle(theme.isDark),
      text: disabledColor.contrastingText(
        background: theme.background,
        disabledColor.idle(theme.isDark),
      ),
      border: Colors.transparent,
    );
  }

  if (status.active) {
    return LdColorBundle(
      surface: color.active(theme.isDark),
      text: color.contrastingText(
        color.active(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  if (status.focus) {
    return LdColorBundle(
      surface: color.focus(theme.isDark),
      text: color.contrastingText(
        color.focus(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  if (status.hovering) {
    return LdColorBundle(
      surface: color.hover(theme.isDark),
      text: color.contrastingText(
        color.hover(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  final surface = color.idle(theme.isDark);
  return LdColorBundle(
    surface: surface,
    text: color.contrastingText(
      surface,
      isDark: theme.isDark,
    ),
    border: Colors.transparent,
  );
}
