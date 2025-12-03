import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppBarApi extends StatelessWidget {
  const AppBarApi({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/interaction/appbar.dart",
      title: "LdAppBar",
      apiComponents: const ["LdAppBar"],
      demo: ComponentWell(
        onSurface: false,
        description: LdText.p(
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
                  LdButton.ghost(
                    child: const Icon(LucideIcons.search),
                    onPressed: () {},
                  ),
                  LdContextMenu(
                    menuBuilder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
                      LdButton.ghost(
                        width: 300,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Item 1"),
                      ),
                    ]),
                    builder: (context, isOpen, open, child) => LdButton.ghost(
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
            LdAppBar(
              implyLeading: false,
              title: const Text("Always Visible Shadow & Border"),
              shadowMode: LdAppBarShadowMode.visible,
              borderMode: LdAppBarBorderMode.visible,
            ),
            LdAppBar(
              implyLeading: false,
              title: const Text("Hidden Shadow & Border"),
              shadowMode: LdAppBarShadowMode.hidden,
              borderMode: LdAppBarBorderMode.hidden,
            ),
          ],
        ),
      ),
    );
  }
}
