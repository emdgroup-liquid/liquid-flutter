import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DividerDemo extends StatelessWidget {
  const DividerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/layout/divider.dart",
      title: "LdDivider",
      demo: LdAutoSpace(
        children: [
          LdTextP(
              "The LdDivider component provides a simple horizontal line to visually separate content sections. "
              "It helps create clear visual hierarchy and improve readability by organizing content into distinct groups."),
          LdTextP(
              "Dividers can be customized with different heights and can be inset to align with content that has leading elements."),
          ComponentWell(
            title: const LdTextHs("Standard divider"),
            child: Column(
              children: [
                LdDivider(),
                ldSpacerM,
                LdText(
                  "You have my undivided attention",
                ),
                ldSpacerM,
                LdDivider(),
              ],
            ),
          ),
          ComponentWell(
            title: const LdTextHs("Inset for leading"),
            description: const LdTextP(
              "The insetForLeading property can be used to inset the divider to align with content that has leading elements.",
            ),
            child: Column(
              children: [
                LdListItem(
                  disabled: true,
                  leading: LdAvatar(
                    child: const Icon(LucideIcons.circle),
                  ),
                  title: const Text("You have my undivided attention"),
                ),
                LdDivider(insetForLeading: true),
                LdListItem(
                  disabled: true,
                  leading: LdAvatar(
                    child: const Icon(LucideIcons.circle),
                  ),
                  title: const Text("You have my undivided attention"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
