import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("LdDrawer", (WidgetTester tester) async {
    await multiGolden(tester, "LdDrawer", {
      "LdDrawer": (tester, place) async {
        await place(
          const LdAutoSpace(children: [
            LdDrawerItemSection(active: true, leading: Icon(LucideIcons.circle), child: Text("Item 1")),
            LdDrawerItemSection(
              leading: Icon(LucideIcons.circle),
              child: Text("Item 3"),
              initiallyExpanded: true,
              children: [
                LdDrawerItemSection(child: Text("Item 3.1")),
                LdDrawerItemSection(child: Text("Item 3.2")),
                LdDrawerItemSection(
                  trailing: Icon(LucideIcons.arrowRight),
                  child: Text("Item 3.3"),
                )
              ],
            )
          ]),
        );
      },
    });
  });
}
