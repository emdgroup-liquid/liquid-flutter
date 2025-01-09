import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdCard Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdCard", {
      "LdCard": (tester, place) async {
        await place(const LdCard(
          header: Text("Header"),
          child: Text("Hello"),
          footer: Text("Footer"),
        ));
        return null;
      },
      "LdCard on surface": (tester, place) async {
        await place(LdAutoBackground(
          child: const LdCard(
            header: Text("Header"),
            child: Text("Hello"),
            footer: Text("Footer"),
          ).padL(),
        ));
        return null;
      },
    });
  });
}
