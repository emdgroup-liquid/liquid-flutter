import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppBarDemo extends StatelessWidget {
  const AppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/interaction/appbar.dart",
      title: "LdAppBar",
      apiComponents: const ["LdAppBar"],
      demo: ComponentWell(
        onSurface: false,
        description: const LdTextP(
          "The LdAppBar component is a customizable app bar for navigation and actions, supporting theming and platform adaptation.",
        ),
        child: LdAutoSpace(
          children: [
            LdAppBar(
              implyLeading: false,
              title: const Text("Default AppBar"),
            ),
            LdAppBar(
              implyLeading: false,
              title: const Text("AppBar with Actions"),
              trailing: Row(
                children: [
                  LdButtonGhost(
                    child: const Icon(LucideIcons.search),
                    onPressed: () {},
                  ),
                  LdContextMenu(
                    menuBuilder: (context, onDismiss) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                      LdButtonGhost(
                        width: 300,
                        onPressed: () {
                          onDismiss();
                        },
                        child: const Text("Item 1"),
                      ),
                    ]),
                    builder: (context, isOpen, open) => LdButtonGhost(
                      child: const Icon(LucideIcons.ellipsisVertical),
                      onPressed: () {
                        open();
                      },
                    ),
                  ),
                ],
              ),
            ),
            LdAppBar(
              title: const Text("AppBar with Leading"),
            ),
          ],
        ),
      ),
    );
  }
}
