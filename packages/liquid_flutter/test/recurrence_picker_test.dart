import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  testWidgets('renders placeholder when empty', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrencePicker(
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Select recurrence'), findsOneWidget);
  });

  testWidgets('trigger height matches compact control height', (tester) async {
    const size = LdSize.m;
    final theme = LdTheme();

    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrencePicker(
          size: size,
          onChanged: (_) {},
        ),
        theme: theme,
      ),
    );

    final triggerSize = tester.getSize(
      find.descendant(
        of: find.byKey(const Key('recurrence_picker_button')),
        matching: find.byType(Container),
      ),
    );

    expect(triggerSize.height, theme.controlHeight(size));
  });

  testWidgets('opens recurrence sheet when pressed', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrencePicker(
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_picker_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrence_picker_sheet')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_weekday_1')), findsOneWidget);
  });

  testWidgets('confirms a weekly rule', (tester) async {
    RecurrenceRule? selected;

    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrencePicker(
          start: DateTime(2024, 1, 15),
          onChanged: (rule) => selected = rule,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_picker_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('done')));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.frequency, Frequency.weekly);
  });

  testWidgets('hides weekday chips for daily frequency', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.daily),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('recurrence_weekday_1')), findsNothing);
  });

  testWidgets('shows unsupported hint', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            bySeconds: const [0],
          ),
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      find.text('This rule has parts this picker cannot edit. Saving will drop those parts.'),
      findsOneWidget,
    );
  });

  testWidgets('shows last occurrence and view all when count is set', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            count: 5,
          ),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Last (5th)'), findsOneWidget);
    expect(find.text('View all occurrences'), findsOneWidget);
    expect(find.text('1 day'), findsWidgets);
    expect(find.textContaining('Mon'), findsWidgets);
  });

  testWidgets('shows interval count in the occurrence delta', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.minutely,
            interval: 3,
          ),
          start: DateTime(2024, 1, 15, 9),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('3 minutes'), findsWidgets);
  });

  testWidgets('shows actual day gaps for weekly by-day rules', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.weekly,
            interval: 3,
            byWeekDays: [
              ByWeekDayEntry(DateTime.monday),
              ByWeekDayEntry(DateTime.tuesday),
              ByWeekDayEntry(DateTime.wednesday),
            ],
          ),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('1 day'), findsWidgets);
    expect(find.text('3 weeks'), findsNothing);
  });

  testWidgets('hides view all when the rule never ends', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.daily),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Last occurrence'), findsNothing);
    expect(find.byKey(const Key('recurrence_view_all')), findsNothing);
  });

  testWidgets('opens all occurrences in a nested modal', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            count: 5,
          ),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_view_all')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrence_all_occurrences_sheet')), findsOneWidget);
    expect(find.text('All occurrences'), findsOneWidget);
  });

  testWidgets('shows truncation hint when the series exceeds the cap', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            until: DateTime.utc(2030, 1, 1),
          ),
          start: DateTime(2024, 1, 15),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_view_all')));
    await tester.pumpAndSettle();

    expect(
      find.text('Showing the first 500 occurrences'),
      findsOneWidget,
    );
  });

  testWidgets('hides disallowed frequencies', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.weekly),
          config: const LdRecurrenceConfig(
            frequencies: [Frequency.daily, Frequency.weekly],
          ),
          onChanged: (_) {},
        ),
      ),
    );

    final select = tester.widget<LdSelect<Frequency>>(find.byKey(const Key('recurrence_frequency')));
    expect(
      select.items.map((item) => item.value),
      [Frequency.daily, Frequency.weekly],
    );
  });

  testWidgets('hides ending when end modes are empty', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.weekly),
          config: const LdRecurrenceConfig.withoutEnding(),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('recurrence_end_never')), findsNothing);
    expect(find.byKey(const Key('recurrence_end_until')), findsNothing);
    expect(find.byKey(const Key('recurrence_end_count')), findsNothing);
  });

  testWidgets('hides until when only count ending is enabled', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.daily, count: 5),
          config: const LdRecurrenceConfig(
            endModes: {LdRecurrenceEndMode.count},
          ),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('recurrence_end_never')), findsNothing);
    expect(find.byKey(const Key('recurrence_end_until')), findsNothing);
    expect(find.byKey(const Key('recurrence_count')), findsOneWidget);
  });

  testWidgets('hides preview when configured to', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.daily),
          start: DateTime(2024, 1, 15),
          config: const LdRecurrenceConfig(showPreview: false),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Next occurrences'), findsNothing);
  });

  testWidgets('shows hour and minute chips for daily by-hours', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            byHours: const [13, 17],
            byMinutes: const [0],
          ),
          start: DateTime(2024, 1, 15, 9),
          config: const LdRecurrenceConfig(
            timesMode: LdRecurrenceTimesMode.linear,
            showPreview: false,
            endModes: {},
          ),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('AT'), findsOneWidget);
    expect(find.byKey(const Key('recurrence_hours')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_minutes')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_hour_13')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_hour_17')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_minute_0')), findsOneWidget);
    expect(
      tester.widget<LdButton>(find.byKey(const Key('recurrence_hour_13'))).active,
      isTrue,
    );
    expect(
      tester.widget<LdButton>(find.byKey(const Key('recurrence_hour_17'))).active,
      isTrue,
    );
  });

  testWidgets('hides times for hourly frequency', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.hourly),
          start: DateTime(2024, 1, 15, 9),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('recurrence_hours')), findsNothing);
    expect(find.text('AT'), findsNothing);
  });

  testWidgets('hides times when configured to', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(frequency: Frequency.daily),
          start: DateTime(2024, 1, 15, 9),
          config: const LdRecurrenceConfig(showTimes: false),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('recurrence_hours')), findsNothing);
  });

  testWidgets('single mode replaces the selected hour', (tester) async {
    var rule = RecurrenceRule(
      frequency: Frequency.daily,
      byHours: const [13],
      byMinutes: const [0],
    );

    await tester.pumpWidget(
      withLiquidTheme(
        StatefulBuilder(
          builder: (context, setState) {
            return LdRecurrenceForm(
              value: rule,
              start: DateTime(2024, 1, 15, 9),
              config: const LdRecurrenceConfig(
                timesMode: LdRecurrenceTimesMode.single,
                showPreview: false,
                endModes: {},
              ),
              onChanged: (next) => setState(() => rule = next),
            );
          },
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('recurrence_hour_17')));
    await tester.tap(find.byKey(const Key('recurrence_hour_17')));
    await tester.pumpAndSettle();

    expect(rule.byHours, [17]);
    expect(rule.byMinutes, [0]);
    expect(
      tester.widget<LdButton>(find.byKey(const Key('recurrence_hour_13'))).active,
      isFalse,
    );
    expect(
      tester.widget<LdButton>(find.byKey(const Key('recurrence_hour_17'))).active,
      isTrue,
    );
  });

  testWidgets('matrix mode shows cartesian hint when both axes are multi', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceForm(
          value: RecurrenceRule(
            frequency: Frequency.daily,
            byHours: const [13, 17],
            byMinutes: const [0, 30],
          ),
          start: DateTime(2024, 1, 15, 9),
          config: const LdRecurrenceConfig(
            timesMode: LdRecurrenceTimesMode.matrix,
            showPreview: false,
            endModes: {},
          ),
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      find.text('Every selected hour combines with every selected minute.'),
      findsOneWidget,
    );
  });
}
