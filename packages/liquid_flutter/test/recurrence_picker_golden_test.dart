import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

void main() {
  testGoldens('LdRecurrencePicker', (WidgetTester tester) async {
    await multiGolden(
      tester,
      'LdRecurrencePicker',
      {
        'Idle': (tester, place) async {
          await place(
            LdRecurrencePicker(
              label: 'Recurrence',
              start: DateTime(2024, 1, 15),
              value: RecurrenceRule(
                frequency: Frequency.weekly,
                byWeekDays: [ByWeekDayEntry(DateTime.monday)],
              ),
              onChanged: (_) {},
            ),
          );
        },
        'Disabled': (tester, place) async {
          await place(
            LdRecurrencePicker(
              label: 'Recurrence',
              start: DateTime(2024, 1, 15),
              value: RecurrenceRule(
                frequency: Frequency.weekly,
                byWeekDays: [ByWeekDayEntry(DateTime.monday)],
              ),
              onChanged: (_) {},
              disabled: true,
            ),
          );
        },
        'Open': (tester, place) async {
          await place(
            LdRecurrencePicker(
              label: 'Recurrence',
              start: DateTime(2024, 1, 15, 9),
              value: RecurrenceRule(
                frequency: Frequency.weekly,
                byWeekDays: [ByWeekDayEntry(DateTime.monday)],
              ),
              onChanged: (_) {},
            ),
          );

          await tester.tap(find.byKey(const Key('recurrence_picker_button')));
          await tester.pumpAndSettle();
        },
      },
      frameScenarios: const [LdFrameOptions(width: 800, height: 1100)],
      widgetTreeOptionsOverrides: {
        'Open': WidgetTreeOptions(
          findWidget: (tester, _) => find.byKey(const Key('recurrence_picker_sheet')),
        ),
      },
    );
  });
}
