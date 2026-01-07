import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdLoader Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdLoader", {
      "LdLoader": (tester, place) async {
        await place(const LdLoader());
        return null;
      },
      "LdLoader - Neutral": (tester, place) async {
        await place(const LdLoader(
          neutral: true,
        ));
        return null;
      },
      "LdLoader - Small": (tester, place) async {
        await place(const LdLoader(
          size: 12,
        ));
        return null;
      },
      "LdLoader - Medium": (tester, place) async {
        await place(const LdLoader(
          size: 24,
        ));
        return null;
      },
      "LdLoader - Large": (tester, place) async {
        await place(const LdLoader(
          size: 48,
        ));
        return null;
      },
    });
  });
}
