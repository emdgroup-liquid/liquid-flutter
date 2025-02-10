import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  testWidgets('renders the initial time properly', (WidgetTester tester) async {
    const initialTime = TimeOfDay(hour: 14, minute: 30);

    await tester.pumpWidget(
      withLiquidTheme(
        LdTimePicker(
          label: 'Select Time',
          value: initialTime,
          onChanged: (_) {},
        ),
      ),
    );

    // Check if the label is displayed
    expect(find.text('Select Time'), findsOneWidget);

    // Check if the initial time is displayed
    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('opens time picker when button is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdTimePicker(
          label: 'Select Time',
          onChanged: (_) {},
        ),
      ),
    );

    // Open the time picker
    await tester.tap(find.byType(LdButton));
    await tester.pumpAndSettle();

    // Check if the time picker sheet is opened
    expect(find.byKey(const Key('time_picker_sheet')), findsOneWidget);
  });

  testWidgets('updates selected time correctly', (WidgetTester tester) async {
    TimeOfDay? selectedTime;

    await tester.pumpWidget(
      withLiquidTheme(
        LdTimePicker(
          label: 'Select Time',
          value: const TimeOfDay(hour: 14, minute: 30),
          onChanged: (time) {
            selectedTime = time;
          },
        ),
      ),
    );

    // Open the time picker
    await tester.tap(find.byKey(const Key('time_picker_button')));
    await tester.pumpAndSettle();

    // Enter time manually using text inputs
    await tester.enterText(find.widgetWithText(LdInput, 'HH'), '15');
    await tester.enterText(find.widgetWithText(LdInput, 'MM'), '45');

    // Close the time picker by pressing Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify if the selected time has been updated
    expect(selectedTime?.hour, 15);
    expect(selectedTime?.minute, 45);
  });

  testWidgets('respects minute precision setting', (WidgetTester tester) async {
    TimeOfDay? selectedTime;

    await tester.pumpWidget(
      withLiquidTheme(
        LdTimePicker(
          label: 'Select Time',
          value: const TimeOfDay(hour: 14, minute: 30),
          minutePrecision: 30,
          onChanged: (time) {
            selectedTime = time;
          },
        ),
      ),
    );

    // Open the time picker
    await tester.tap(find.byKey(const Key('time_picker_button')));
    await tester.pumpAndSettle();

    // Enter time manually
    await tester.enterText(find.widgetWithText(LdInput, 'HH'), '15');
    await tester.enterText(find.widgetWithText(LdInput, 'MM'), '20');

    // Close the time picker
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify time is rounded to nearest 30 minutes
    expect(selectedTime?.hour, 15);
    expect(selectedTime?.minute, 30);
  });

  testWidgets('handles disabled state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdTimePicker(
          label: 'Select Time',
          disabled: true,
          onChanged: (_) {},
        ),
      ),
    );

    // Verify the button is disabled
    final button = tester.widget<LdButton>(
      find.byKey(const Key('time_picker_button')),
    );
    expect(button.disabled, isTrue);

    // Try to tap the button
    await tester.tap(find.byKey(const Key('time_picker_button')));
    await tester.pumpAndSettle();

    // Verify the picker didn't open
    expect(find.byKey(const Key('time_picker_sheet')), findsNothing);
  });
}
