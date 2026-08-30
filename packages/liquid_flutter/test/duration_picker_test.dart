import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  testWidgets('renders the initial duration properly', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          label: 'Select Duration',
          value: const LdDuration(hours: 1, minutes: 30),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Select Duration'), findsOneWidget);
    expect(find.text('1h 30m'), findsOneWidget);
  });

  testWidgets('trigger height matches compact control height', (tester) async {
    const size = LdSize.m;
    final theme = LdTheme();

    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          size: size,
          value: const LdDuration(hours: 1, minutes: 30),
          onChanged: (_) {},
        ),
        theme: theme,
      ),
    );

    final triggerSize = tester.getSize(
      find.descendant(
        of: find.byKey(const Key('duration_picker_button')),
        matching: find.byType(Container),
      ),
    );

    expect(triggerSize.height, theme.controlHeight(size));
  });

  testWidgets('opens duration picker when button is pressed', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          label: 'Select Duration',
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(LdTouchableSurface));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('duration_picker_sheet')), findsOneWidget);
    expect(find.text('HOURS'), findsWidgets);
    expect(find.text('MINUTES'), findsWidgets);
  });

  testWidgets('updates selected duration from text fields', (tester) async {
    LdDuration? selected;

    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          label: 'Select Duration',
          value: const LdDuration(hours: 1, minutes: 30),
          onChanged: (duration) {
            selected = duration;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('duration_picker_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(LdInput, 'h'), '2');
    await tester.enterText(find.widgetWithText(LdInput, 'm'), '45');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(selected?.hours, 2);
    expect(selected?.minutes, 45);
  });

  testWidgets('snaps minutes to the configured step', (tester) async {
    LdDuration? selected;

    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          label: 'Select Duration',
          value: const LdDuration(hours: 1, minutes: 30),
          config: const LdDurationConfig(minuteStep: 15),
          onChanged: (duration) {
            selected = duration;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('duration_picker_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(LdInput, 'm'), '20');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(selected?.minutes, 15);
  });

  testWidgets('handles disabled state', (tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        LdDurationPicker(
          label: 'Select Duration',
          disabled: true,
          onChanged: (_) {},
        ),
      ),
    );

    final button = tester.widget<LdTouchableSurface>(
      find.byKey(const Key('duration_picker_button')),
    );
    expect(button.disabled, isTrue);

    await tester.tap(find.byKey(const Key('duration_picker_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('duration_picker_sheet')), findsNothing);
  });
}
