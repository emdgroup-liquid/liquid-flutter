import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A title for a section in the drawer
class LdSectionHeader extends StatelessWidget {
  final String text;

  const LdSectionHeader(this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LdTextL(
      text.toUpperCase(),
      size: LdSize.s,
      color: LdTheme.of(context, listen: true).textMuted,
    );
  }
}
