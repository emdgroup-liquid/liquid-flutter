import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeDemosSection extends StatelessWidget {
  const HomeDemosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        const LdDivider(),
        ldSpacerL,
        LdText.hs('Demos'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LdButton(
              mode: LdButtonMode.outline,
              trailing: const Icon(LucideIcons.arrowRight),
              onPressed: () {
                context.push('/chemical');
              },
              child: const Text('Chemical Inventory'),
            ),
            LdButton(
              mode: LdButtonMode.outline,
              trailing: const Icon(LucideIcons.arrowRight),
              onPressed: () {
                context.go('/task-demo');
              },
              child: const Text('Task Demo'),
            ),
            LdButton(
              mode: LdButtonMode.outline,
              trailing: const Icon(LucideIcons.arrowRight),
              onPressed: () {
                context.go('/components/bento-gallery');
              },
              child: const Text('Widget Gallery'),
            ),
          ],
        ),
        const LdDivider(),
      ],
    );
  }
}
