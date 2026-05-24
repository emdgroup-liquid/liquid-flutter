import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WindowsWindowControls extends StatelessWidget {
  const WindowsWindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LdButton.vague(
          size: LdSize.s,
          child: const Icon(LucideIcons.minus),
          onPressed: () {
            LdAppBarWidget.callbacks?.onMinimize?.call();
          },
        ),
        LdButton.vague(
          size: LdSize.s,
          child: const Icon(LucideIcons.square),
          onPressed: () {
            LdAppBarWidget.callbacks?.onMaximize?.call();
          },
        ),
        LdButton.vague(
          size: LdSize.s,
          child: const Icon(LucideIcons.x),
          onPressed: () {
            LdAppBarWidget.callbacks?.onClose?.call();
          },
        ),
      ],
    );
  }
}
