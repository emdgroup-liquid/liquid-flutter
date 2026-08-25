import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  testWidgets('renders placeholder when empty', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceMultiPicker(
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Select recurrences'), findsOneWidget);
  });

  testWidgets('summarizes multiple rules by count', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceMultiPicker(
          value: [
            RecurrenceRule(frequency: Frequency.daily, count: 3),
            RecurrenceRule(frequency: Frequency.weekly, count: 4),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('2 rules'), findsOneWidget);
  });

  testWidgets('opens list modal and adds a rule', (tester) async {
    var rules = <RecurrenceRule>[];

    await tester.pumpWidget(
      withLiquidTheme(
        StatefulBuilder(
          builder: (context, setState) {
            return LdRecurrenceMultiPicker(
              value: rules,
              start: DateTime(2024, 1, 15),
              config: const LdRecurrenceConfig(
                showPreview: false,
                endModes: {},
              ),
              onChanged: (next) => setState(() => rules = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_multi_picker_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrence_multi_picker_sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recurrence_multi_add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recurrence_picker_sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('done')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrence_multi_rule_0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recurrence_multi_done')));
    await tester.pumpAndSettle();

    expect(rules, hasLength(1));
  });

  testWidgets('removes a rule from the list modal', (tester) async {
    var rules = [
      RecurrenceRule(frequency: Frequency.daily, count: 2),
      RecurrenceRule(frequency: Frequency.weekly, count: 2),
    ];

    await tester.pumpWidget(
      withLiquidTheme(
        StatefulBuilder(
          builder: (context, setState) {
            return LdRecurrenceMultiPicker(
              value: rules,
              start: DateTime(2024, 1, 15),
              config: const LdRecurrenceConfig(
                showPreview: false,
                endModes: {},
              ),
              onChanged: (next) => setState(() => rules = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_multi_picker_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recurrence_multi_remove_0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrence_multi_rule_0')), findsOneWidget);
    expect(find.byKey(const Key('recurrence_multi_rule_1')), findsNothing);

    await tester.tap(find.byKey(const Key('recurrence_multi_done')));
    await tester.pumpAndSettle();

    expect(rules, hasLength(1));
    expect(rules.single.frequency, Frequency.weekly);
  });

  testWidgets('shows merged preview for multiple finite rules', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdRecurrenceMultiPicker(
          value: [
            RecurrenceRule(
              frequency: Frequency.daily,
              byHours: const [9],
              byMinutes: const [0],
              count: 3,
            ),
            RecurrenceRule(
              frequency: Frequency.daily,
              byHours: const [17],
              byMinutes: const [0],
              count: 3,
            ),
          ],
          start: DateTime(2024, 1, 15, 9),
          config: const LdRecurrenceConfig(endModes: {}),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('recurrence_multi_picker_button')));
    await tester.pumpAndSettle();

    expect(find.text('NEXT OCCURRENCES'), findsOneWidget);
    expect(find.byKey(const Key('recurrence_multi_view_all')), findsOneWidget);
  });
}
