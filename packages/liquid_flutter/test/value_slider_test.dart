import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  group('LdSlider', () {
    testWidgets('drag right → onChanged called with increasing values',
        (WidgetTester tester) async {
      double currentValue = 0.0;
      final List<double> emittedValues = [];

      await tester.pumpWidget(
        withLiquidTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SizedBox(
                  width: 300,
                  child: LdSlider(
                    value: currentValue,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) {
                      emittedValues.add(v);
                      setState(() => currentValue = v);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LdSlider), findsOneWidget);

      // Drag from the left toward the right
      final sliderFinder = find.byType(LdSlider);
      final sliderRect = tester.getRect(sliderFinder);
      final startOffset = Offset(sliderRect.left + 20, sliderRect.center.dy);
      final endOffset = Offset(sliderRect.right - 20, sliderRect.center.dy);

      await performPanGesture(
        tester,
        startPosition: startOffset,
        endPosition: endOffset,
        steps: 20,
      );

      expect(emittedValues.isNotEmpty, true,
          reason: 'onChanged should have been called during drag');
      // Values should generally increase (allowing for minor floating-point variation)
      expect(emittedValues.last, greaterThan(emittedValues.first));
    });

    testWidgets('step=1.0 → only integer values emitted',
        (WidgetTester tester) async {
      double currentValue = 0.0;
      final List<double> emittedValues = [];

      await tester.pumpWidget(
        withLiquidTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SizedBox(
                  width: 300,
                  child: LdSlider(
                    value: currentValue,
                    min: 0.0,
                    max: 10.0,
                    step: 1.0,
                    onChanged: (v) {
                      emittedValues.add(v);
                      setState(() => currentValue = v);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final sliderFinder = find.byType(LdSlider);
      final sliderRect = tester.getRect(sliderFinder);
      final startOffset = Offset(sliderRect.left + 10, sliderRect.center.dy);
      final endOffset = Offset(sliderRect.right - 10, sliderRect.center.dy);

      await performPanGesture(
        tester,
        startPosition: startOffset,
        endPosition: endOffset,
        steps: 30,
      );

      expect(emittedValues.isNotEmpty, true);
      for (final v in emittedValues) {
        expect(v, equals(v.roundToDouble()),
            reason: 'Expected integer value, got $v');
      }
    });

    testWidgets('disabled: true → no onChanged calls on drag',
        (WidgetTester tester) async {
      double currentValue = 0.5;
      final List<double> emittedValues = [];

      await tester.pumpWidget(
        withLiquidTheme(
          Center(
            child: SizedBox(
              width: 300,
              child: LdSlider(
                value: currentValue,
                min: 0.0,
                max: 1.0,
                disabled: true,
                onChanged: (v) => emittedValues.add(v),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final sliderFinder = find.byType(LdSlider);
      final sliderRect = tester.getRect(sliderFinder);
      final startOffset = Offset(sliderRect.left + 20, sliderRect.center.dy);
      final endOffset = Offset(sliderRect.right - 20, sliderRect.center.dy);

      await performPanGesture(
        tester,
        startPosition: startOffset,
        endPosition: endOffset,
        steps: 20,
      );

      expect(emittedValues, isEmpty,
          reason: 'onChanged must not be called when slider is disabled');
    });

    testWidgets('programmatic value > max → display clamped, onChanged not called',
        (WidgetTester tester) async {
      final List<double> emittedValues = [];

      await tester.pumpWidget(
        withLiquidTheme(
          Center(
            child: SizedBox(
              width: 300,
              child: LdSlider(
                value: 5.0, // exceeds max of 1.0
                min: 0.0,
                max: 1.0,
                onChanged: (v) => emittedValues.add(v),
              ),
            ),
          ),
        ),
      );

      // Widget should build without throwing
      await tester.pumpAndSettle();
      expect(find.byType(LdSlider), findsOneWidget);
      // onChanged must not have been called during build/clamp
      expect(emittedValues, isEmpty,
          reason:
              'onChanged must not be called for programmatic out-of-range clamping');
    });
  });
}
