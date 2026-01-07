import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Current active colors
class LdColorBundle {
  final Color surface;
  final Color border;
  final Color text;
  final Color placeholder;
  late Color icon;
  LdColorBundle(
      {required this.surface,
      required this.text,
      required this.border,
      this.placeholder = Colors.transparent,
      Color? icon}) {
    this.icon = icon ?? text;
  }

  factory LdColorBundle.autoText({
    required LdTheme theme,
    required Color surface,
    required Color border,
    LdColor? textColor,
    LdColor? iconColor,
    Color placeholder = Colors.transparent,
  }) {
    return LdColorBundle(
      surface: surface,
      text: (textColor ?? theme.palette.neutral).contrastingText(surface),
      border: border,
      icon: (iconColor ?? theme.palette.neutral).contrastingText(surface),
      placeholder: placeholder,
    );
  }
}
