import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DrawerDemo extends StatelessWidget {
  const DrawerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        apiComponents: const ["LdDrawerItemSection", "LdSectionHeader"],
        title: "Drawer",
        demo: ComponentWell(
          child: Center(
            child: Container(
              width: 300,
              padding: LdTheme.of(context).pad(size: LdSize.l),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: LdTheme.of(context).border),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                LdDrawerHeader(title: Text("Header ")),
                ldSpacerS,
                LdSectionHeader("Section 1"),
                ldSpacerS,
                LdDrawerItemSection(active: true, leading: Icon(LucideIcons.circle), child: Text("Item 1")),
                ldSpacerS,
                LdDrawerItemSection(leading: Icon(LucideIcons.circle), child: Text("Item 2")),
                ldSpacerS,
                LdDrawerItemSection(
                  leading: Icon(LucideIcons.circle),
                  child: Text("Item 3"),
                  children: [
                    LdDrawerItemSection(child: Text("Item 3.1")),
                    ldSpacerS,
                    LdDrawerItemSection(child: Text("Item 3.2")),
                    ldSpacerS,
                    LdDrawerItemSection(
                      trailing: Icon(LucideIcons.arrowRight),
                      child: Text("Item 3.3"),
                    )
                  ],
                )
              ]),
            ),
          ),
        ));
  }
}
