import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdBottomBar extends StatelessWidget {
  final Widget child;

  const LdBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LdTheme.of(context).surface,
        border: Border(
          top: BorderSide(
            color: LdTheme.of(context).border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: LdTheme.of(context).pad(size: LdSize.s),
        child: child,
      ),
    );
  }
}
