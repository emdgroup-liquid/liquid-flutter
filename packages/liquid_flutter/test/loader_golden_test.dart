import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("LdLoader Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdLoader", {
      "LdLoader": (tester, place) async {
        await place(const LdLoader());
      },
      "LdLoader - Neutral": (tester, place) async {
        await place(const LdLoader(
          neutral: true,
        ));
      },
      "LdLoader - Small": (tester, place) async {
        await place(const LdLoader(
          size: 12,
        ));
      },
      "LdLoader - Medium": (tester, place) async {
        await place(const LdLoader(
          size: 24,
        ));
      },
      "LdLoader - Large": (tester, place) async {
        await place(const LdLoader(
          size: 48,
        ));
      },
    });
  });
}
