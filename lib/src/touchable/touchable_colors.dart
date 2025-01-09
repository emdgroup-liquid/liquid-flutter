import 'package:flutter/material.dart';

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
}
