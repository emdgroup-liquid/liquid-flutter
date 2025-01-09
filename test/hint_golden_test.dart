import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdHint Golden", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdHint",
      Map.fromEntries(
        LdHintType.values.map(
          (e) => MapEntry(
            e.toString(),
            (tester, place) async {
              await place(LdHint(
                type: e,
                child: Text(e.toString()),
              ));
              return null;
            },
          ),
        ),
      ),
    );
  });
}
