import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

void main() {
  testGoldens("LdTimePicker", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdTimePicker",
      {
        "Idle": (tester, place) async {
          await place(LdTimePicker(
            label: 'Select Time',
            value: const TimeOfDay(hour: 14, minute: 30),
            onChanged: (_) {},
          ));
        },
        "Disabled": (tester, place) async {
          await place(LdTimePicker(
            label: 'Select Time',
            value: const TimeOfDay(hour: 14, minute: 30),
            onChanged: (_) {},
            disabled: true,
          ));
        },
        "Open": (tester, place) async {
          await place(LdTimePicker(
            label: 'Select Time',
            value: const TimeOfDay(hour: 14, minute: 30),
            onChanged: (_) {},
          ));

          await tester.tap(
            find.byKey(const Key("time_picker_button")),
          );

          await tester.pumpAndSettle();
        },
      },
      frameScenarios: const [LdFrameOptions(width: 900, height: 900)],
    );
  });
}
