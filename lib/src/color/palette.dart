import 'dart:ui';

import 'package:liquid_flutter/liquid_flutter.dart';

/// Describes how to build a pallete of colors for a theme.
class LdPalette {
  bool isDark;

  final LdColor primary;
  final LdColor secondary;

  final LdColor success;
  final LdColor warning;
  final LdColor error;
  final LdColor neutral;

  late final Color background;
  late final Color surface;
  late final Color border;
  late final Color stroke;
  late final Color text;
  late final Color textMuted;

  LdPalette({
    required this.isDark,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    this.neutral = shadZinc,
  }) {
    background = neutral.relative(isDark, isDark ? 0 : 1);
    surface = neutral.relative(isDark, isDark ? 1 : 0);
    border = neutral.relative(isDark, 3);
    stroke = neutral.relative(isDark, 3);
    text = neutral.relative(!isDark, 2);
    textMuted = neutral.relative(!isDark, 5);
  }
}

final shadDefault = LdPalette(
  isDark: false,
  primary: shadSky,
  secondary: shadSky,
  success: shadGreen,
  warning: shadAmber,
  error: shadRed,
);

final shadDefaultDark = LdPalette(
  isDark: true,
  primary: shadSky,
  secondary: shadSky,
  success: shadGreen,
  warning: shadAmber,
  error: shadRed,
);
