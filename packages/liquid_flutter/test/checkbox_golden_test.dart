import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdCheckbox Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdCheckbox", {
      "LdCheckbox": (tester, place) async {
        await place(const LdCheckbox(
          checked: false,
        ));
        return null;
      },
      "LdCheckbox Checked": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
        ));
        return null;
      },
      "LdCheckbox Checked with label": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          label: "Hello",
        ));
        return null;
      },
      "LdCheckbox Checked with label and color": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          label: "Hello",
          color: shadAmber,
        ));
        return null;
      },
      "LdCheckbox disabled": (tester, place) async {
        await place(const LdCheckbox(
          checked: false,
          disabled: true,
        ));
        return null;
      },
      "LdCheckbox disabled Checked": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          disabled: true,
        ));
        return null;
      },
    });
  });
}
