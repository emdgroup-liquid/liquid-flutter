import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ColorSelctor extends StatelessWidget {
  final LdColor active;
  final Map<String, LdColor> colors;
  final void Function(LdColor) onChanged;
  const ColorSelctor({
    super.key,
    required this.active,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.entries
          .map(
            (e) => Container(
              decoration: BoxDecoration(
                boxShadow: [if (e.value == active) ldShadowSticky],
              ),
              child: Tooltip(
                message: e.key,
                child: LdButton(
                  color: e.value,
                  active: e.value == active,
                  child: e.value == active ? const Icon(LucideIcons.check) : const Icon(LucideIcons.circle),
                  onPressed: () => onChanged(e.value),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
