import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdDatePicker", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdDatePicker",
      {
        "Idle": (tester, place) async {
          await place(LdDatePicker(
            label: 'Select Date',
            value: DateTime(2023, 12, 9),
            onChanged: (_) {},
          ));
          return null;
        },
        "Disabled": (tester, place) async {
          await place(LdDatePicker(
            label: 'Select Date',
            value: DateTime(2023, 12, 9),
            onChanged: (_) {},
            disabled: true,
          ));
          return null;
        },
        "Open": (tester, place) async {
          await place(LdDatePicker(
            label: 'Select Date',
            value: DateTime(2023, 12, 9),
            onChanged: (_) {},
          ));

          await tester.tap(
            find.byKey(const Key("date_picker_button")),
          );

          await tester.pumpAndSettle();

          // Swipe up to extend the sheet
          await tester.drag(
            find.text("Wed"),
            const Offset(0, -1000),
          );
          await tester.pumpAndSettle();

          return null;
        },
      },
      width: 900,
      height: 900,
    );
  });
}
