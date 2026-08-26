import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

void main() {
  testGoldens('LdDurationPicker', (tester) async {
    await multiGolden(
      tester,
      'LdDurationPicker',
      {
        'Idle': (tester, place) async {
          await place(LdDurationPicker(
            label: 'Select Duration',
            value: const LdDuration(hours: 1, minutes: 30),
            onChanged: (_) {},
          ));
        },
        'Disabled': (tester, place) async {
          await place(LdDurationPicker(
            label: 'Select Duration',
            value: const LdDuration(hours: 1, minutes: 30),
            onChanged: (_) {},
            disabled: true,
          ));
        },
        'Open': (tester, place) async {
          await place(LdDurationPicker(
            label: 'Select Duration',
            value: const LdDuration(hours: 1, minutes: 30),
            onChanged: (_) {},
          ));

          await tester.tap(
            find.byKey(const Key('duration_picker_button')),
          );
          await tester.pumpAndSettle();
        },
        'OpenCalendar': (tester, place) async {
          await place(LdDurationPicker(
            label: 'Select Duration',
            value: const LdDuration(years: 1, months: 3),
            config: const LdDurationConfig.calendar(),
            onChanged: (_) {},
          ));

          await tester.tap(
            find.byKey(const Key('duration_picker_button')),
          );
          await tester.pumpAndSettle();
        },
      },
      frameScenarios: const [LdFrameOptions(width: 900, height: 900)],
      widgetTreeOptionsOverrides: {
        'Open': WidgetTreeOptions(
          findWidget: (tester, _) => find.byKey(const Key('duration_picker_sheet')),
        ),
        'OpenCalendar': WidgetTreeOptions(
          findWidget: (tester, _) => find.byKey(const Key('duration_picker_sheet')),
        ),
      },
    );
  });
}
