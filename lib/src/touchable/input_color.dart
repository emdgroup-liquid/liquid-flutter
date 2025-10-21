import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

/// Input surface mode - specialized for input fields with validation states
LdColorBundle inputColor(
  LdTheme theme,
  LdTouchableStatus status, {
  bool isValid = true,
  bool onSurface = false,
}) {
  final surface = onSurface ? theme.background : theme.palette.surface;
  final border = theme.border;
  final borderInvalid = theme.palette.error;

  if (status.disabled) {
    return LdColorBundle(
      surface: theme.isDark ? theme.neutralShade(2) : theme.neutralShade(1),
      text: theme.textMuted,
      border: theme.palette.border,
      icon: theme.palette.neutral.fromCenter(-1, theme.isDark),
      placeholder: theme.palette.neutral.relative(theme.isDark, 5),
    );
  }

  if (status.active || status.focus) {
    return LdColorBundle(
      surface: surface,
      text: theme.palette.text,
      border: isValid ? theme.palette.primary.relative(theme.isDark, 4) : borderInvalid.fromCenter(-1, theme.isDark),
      icon: theme.palette.neutral.fromCenter(-2, theme.isDark),
      placeholder: theme.palette.textMuted,
    );
  }

  if (status.hovering) {
    return LdColorBundle(
      surface: theme.palette.neutral.relative(theme.isDark, theme.isDark ? 2 : 1),
      text: theme.palette.text,
      border: isValid ? theme.palette.neutral.relative(theme.isDark, 3) : borderInvalid.fromCenter(2, theme.isDark),
      icon: theme.palette.neutral.fromCenter(-1, theme.isDark),
      placeholder: theme.palette.textMuted,
    );
  }

  return LdColorBundle(
    surface: surface,
    text: theme.palette.text,
    border: isValid ? border : borderInvalid.fromCenter(1, theme.isDark),
    icon: theme.palette.neutral.fromCenter(-1, theme.isDark),
    placeholder: theme.palette.textMuted,
  );
}
