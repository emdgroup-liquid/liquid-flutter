import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdDrawer", (WidgetTester tester) async {
    await multiGolden(tester, "LdDrawer", {
      "LdDrawer": (tester, place) async {
        await place(
          const LdAutoSpace(children: [
            LdDrawerHeader(title: Text("Header ")),
            LdDrawerItemSection(
                active: true,
                leading: Icon(Icons.circle),
                child: Text("Item 1")),
            LdDrawerItemSection(
              leading: Icon(Icons.circle),
              child: Text("Item 3"),
              initiallyExpanded: true,
              children: [
                LdDrawerItemSection(child: Text("Item 3.1")),
                LdDrawerItemSection(child: Text("Item 3.2")),
                LdDrawerItemSection(
                  child: Text("Item 3.3"),
                  trailing: Icon(Icons.arrow_right),
                )
              ],
            )
          ]),
        );
        return null;
      },
    });
  });
}
