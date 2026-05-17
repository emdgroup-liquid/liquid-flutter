import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/widget_tree_test.dart';

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
        },
        "Disabled": (tester, place) async {
          await place(LdDatePicker(
            label: 'Select Date',
            value: DateTime(2023, 12, 9),
            onChanged: (_) {},
            disabled: true,
          ));
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
        },
      },
      frameScenarios: const [LdFrameOptions(width: 800, height: 800)],
      widgetTreeOptionsOverrides: {
        // The date picker sheet is rendered in a Navigator overlay, outside
        // the LdDatePicker widget subtree. Root the golden at the sheet itself
        // so the opened dialog is captured rather than the background picker.
        "Open": WidgetTreeOptions(
          findWidget: (tester, _) =>
              find.byKey(const Key('date_picker_sheet')),
        ),
      },
    );
  });
}
