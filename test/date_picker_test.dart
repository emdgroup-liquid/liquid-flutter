import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  testWidgets('renders the initial date properly', (WidgetTester tester) async {
    final initialDate = DateTime(2023, 1, 1);

    await tester.pumpWidget(
      withLiquidTheme(
        LdDatePicker(
          label: 'Select Date',
          value: initialDate,
          onChanged: (_) {},
        ),
      ),
    );

    // Check if the label is displayed
    expect(find.text('Select Date'), findsOneWidget);

    // Check if the initial date is displayed
    expect(find.text('1/1/2023'), findsOneWidget);
  });

  testWidgets('opens date picker when button is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdDatePicker(
          label: 'Select Date',
          onChanged: (_) {},
        ),
      ),
    );

    // Open the date picker
    await tester.tap(find.byType(LdButton));
    await tester.pumpAndSettle();

    // Check if the date picker sheet is opened
    expect(find.byKey(const Key('date_picker_sheet')), findsOneWidget);
  });

  testWidgets('updates selected date correctly', (WidgetTester tester) async {
    DateTime? selectedDate;

    await tester.pumpWidget(
      withLiquidTheme(
        LdDatePicker(
          label: 'Select Date',
          value: DateTime(2023, 1, 1),
          onChanged: (date) {
            selectedDate = date;
          },
        ),
      ),
    );

    // Open the date picker
    await tester.tap(find.byKey(const Key('date_picker_button')));
    await tester.pumpAndSettle();

    // Select a date (e.g., 15th of the month)
    await tester.tap(find.byKey(const Key('day_2023_1_15')));
    await tester.pumpAndSettle();

    // Close the date picker by pressing Done
    await tester.tap(find.byKey(const Key('done')));
    await tester.pumpAndSettle();

    // Verify if the selected date has been updated
    expect(selectedDate, DateTime(2023, 1, 15));
  });

  testWidgets('disables dates outside the min and max range',
      (WidgetTester tester) async {
    final minDate = DateTime(2023, 10, 15);
    final maxDate = DateTime(2023, 10, 22);

    await tester.pumpWidget(
      withLiquidTheme(
        LdDatePicker(
          label: 'Select Date',
          value: DateTime(2023, 10, 17),
          minDate: minDate,
          maxDate: maxDate,
          onChanged: (_) {},
        ),
      ),
    );

    // Open the date picker
    await tester.tap(find.byType(LdButton));
    await tester.pumpAndSettle();

    // Verify that dates outside the range are disabled
    expect(
      tester
          .widget<LdButton>(
            find.byKey(const Key('day_2023_10_31')),
          )
          .disabled,
      isTrue,
    );
    expect(
      tester
          .widget<LdButton>(
            find.byKey(const Key('day_2023_10_15')),
          )
          .disabled,
      isFalse,
    );
  });

  testWidgets(
      'shows Today, +7d, +30d, and +90d buttons and updates date correctly',
      (WidgetTester tester) async {
    DateTime? selectedDate;

    final initialDate = DateTime.now();

    await tester.pumpWidget(
      withLiquidTheme(
        LdDatePicker(
          label: 'Select Date',
          value: initialDate,
          onChanged: (date) {
            selectedDate = date;
          },
        ),
      ),
    );

    // Open the date picker
    await tester.tap(find.byKey(const Key('date_picker_button')));
    await tester.pumpAndSettle();

    // Verify presence of shortcut buttons
    expect(find.byKey(const Key('today')), findsOneWidget);
    expect(find.byKey(const Key('in7d')), findsOneWidget);
    expect(find.byKey(const Key('in30d')), findsOneWidget);
    expect(find.byKey(const Key('in90d')), findsOneWidget);

    // Tap on "+7d" and verify the selected date
    await tester.tap(find.byKey(const Key('in7d')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('done')));
    expect(selectedDate, initialDate.add(const Duration(days: 7)));
  });
}
