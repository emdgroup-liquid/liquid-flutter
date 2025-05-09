import 'dart:ui';

import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

class LdInputColorBundle {
  final Color backgroundIdle;
  final Color backgroundHover;
  final Color backgroundFocus;
  final Color backgroundDisabled;

  final Color borderIdle;
  final Color borderHover;
  final Color borderFocus;
  final Color borderDisabled;

  final Color textIdle;
  final Color textHover;
  final Color textFocus;
  final Color textDisabled;

  final Color placeholderIdle;
  final Color placeholderHover;
  final Color placeholderFocus;
  final Color placeholderDisabled;

  final Color iconIdle;
  final Color iconHover;
  final Color iconFocus;
  final Color iconDisabled;

  const LdInputColorBundle({
    required this.backgroundIdle,
    required this.backgroundHover,
    required this.backgroundFocus,
    required this.backgroundDisabled,
    required this.borderIdle,
    required this.borderHover,
    required this.borderFocus,
    required this.borderDisabled,
    required this.textIdle,
    required this.textHover,
    required this.textFocus,
    required this.textDisabled,
    required this.placeholderIdle,
    required this.placeholderHover,
    required this.placeholderFocus,
    required this.placeholderDisabled,
    required this.iconIdle,
    required this.iconHover,
    required this.iconFocus,
    required this.iconDisabled,
  });

  factory LdInputColorBundle.fromTheme(
    LdTheme theme, {
    bool onSurface = false,
    bool isValid = true,
  }) {
    final surface = theme.palette.surface;

    final border = theme.border;
    final borderInvalid = theme.palette.error;

    return LdInputColorBundle(
      backgroundIdle: surface,
      backgroundHover: surface,
      backgroundFocus: surface,
      backgroundDisabled:
          theme.isDark ? theme.neutralShade(2) : theme.neutralShade(1),
      borderIdle: isValid ? border : borderInvalid.fromCenter(1, theme.isDark),
      borderHover: isValid
          ? theme.palette.neutral.relative(theme.isDark, 3)
          : borderInvalid.fromCenter(2, theme.isDark),
      borderFocus: isValid
          ? theme.palette.primary.relative(theme.isDark, 4)
          : borderInvalid.fromCenter(-1, theme.isDark),
      borderDisabled: theme.palette.border,
      textIdle: theme.palette.text,
      textHover: theme.palette.text,
      textFocus: theme.palette.text,
      textDisabled: theme.textMuted,
      placeholderIdle: theme.palette.textMuted,
      placeholderHover: theme.palette.textMuted,
      placeholderFocus: theme.palette.textMuted,
      placeholderDisabled: theme.palette.neutral.relative(theme.isDark, 5),
      iconIdle: theme.palette.primary.fromCenter(1, theme.isDark),
      iconHover: theme.palette.primary.fromCenter(2, theme.isDark),
      iconFocus: theme.palette.primary.fromCenter(-1, theme.isDark),
      iconDisabled: theme.palette.primary.fromCenter(1, theme.isDark),
    );
  }

  LdColorBundle fromTouchableStatus(LdTouchableStatus status) {
    if (status.disabled) {
      return LdColorBundle(
        surface: backgroundDisabled,
        text: textDisabled,
        border: borderDisabled,
        icon: iconDisabled,
        placeholder: placeholderDisabled,
      );
    }
    if (status.active || status.focus) {
      return LdColorBundle(
        surface: backgroundFocus,
        text: textFocus,
        border: borderFocus,
        icon: iconFocus,
        placeholder: placeholderFocus,
      );
    }
    if (status.hovering) {
      return LdColorBundle(
        surface: backgroundHover,
        text: textHover,
        border: borderHover,
        icon: iconHover,
        placeholder: placeholderHover,
      );
    }
    return LdColorBundle(
      surface: backgroundIdle,
      text: textIdle,
      border: borderIdle,
      icon: iconIdle,
      placeholder: placeholderIdle,
    );
  }
}
