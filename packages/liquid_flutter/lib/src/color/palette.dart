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
  late final Color floatingBorder;
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
    Color? background,
    Color? surface,
    Color? border,
    Color? stroke,
    Color? text,
    Color? textMuted,
    Color? floatingBorder,
  }) {
    this.background = background ?? neutral.relative(isDark, isDark ? 0 : 1);
    this.surface = surface ?? neutral.relative(isDark, isDark ? 1 : 0);
    this.border = border ?? neutral.relative(isDark, 3);
    this.stroke = stroke ?? neutral.relative(isDark, 3);
    this.text = text ?? neutral.relative(!isDark, 2);
    this.textMuted = textMuted ?? neutral.relative(!isDark, 5);
    this.floatingBorder = floatingBorder ?? neutral.relative(isDark, 4);
  }
}

final highContrast = LdPalette(
  isDark: false,
  primary: zincReduced,
  secondary: zincReduced,
  success: zincReduced,
  warning: zincReduced,
  error: zincReduced,
  neutral: zincReduced,
  background: zincReduced.shades[0],
  surface: zincReduced.shades[1],
  border: zincReduced.shades[4],
  stroke: zincReduced.shades[4],
  text: zincReduced.shades[5],
  textMuted: zincReduced.shades[4],
);

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
