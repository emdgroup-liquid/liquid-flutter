import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("LdCheckbox Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdCheckbox", {
      "LdCheckbox": (tester, place) async {
        await place(const LdCheckbox(
          checked: false,
        ));
      },
      "LdCheckbox Checked": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
        ));
      },
      "LdCheckbox Checked with label": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          label: "Hello",
        ));
      },
      "LdCheckbox Checked with label and color": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          label: "Hello",
          color: shadAmber,
        ));
      },
      "LdCheckbox disabled": (tester, place) async {
        await place(const LdCheckbox(
          checked: false,
          disabled: true,
        ));
      },
      "LdCheckbox disabled Checked": (tester, place) async {
        await place(const LdCheckbox(
          checked: true,
          disabled: true,
        ));
      },
    });
  });
}
