import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BreadcrumbDemo extends StatelessWidget {
  const BreadcrumbDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdBreadcrumb",
      demo: ComponentWell(
        child: Column(
          children: [
            LdBreadcrumb.fromStrings(const ["Hello", "World", "Cookie", "Menu"]),
            ldSpacerM,
            const LdBreadcrumb(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(LucideIcons.square), ldSpacerXS, Text("Components")],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(LucideIcons.square), ldSpacerXS, Text("Breadcrumb")],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
