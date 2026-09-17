import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'utils.dart';

/// Asserts that [LdButton] (text and icon-only) and [LdInput] share the same
/// painted height for each [LdSize]. Inputs are measured without a label so
/// this matches inline form rows (compose bars, input + trailing button).
double _height(WidgetTester tester, Finder finder) {
  return tester.getSize(finder).height;
}

/// Height of the trigger frame ([LdFieldFrame]) of an input-like control,
/// i.e. the actual painted control without its (optional) label.
double _frameHeight(WidgetTester tester, Key key) {
  return _height(
    tester,
    find.descendant(
      of: find.byKey(key),
      matching: find.byType(LdFieldFrame),
    ),
  );
}

Future<({
  double textButton,
  double iconButton,
  double input,
})> _measureSizes(
  WidgetTester tester,
  LdSize size,
) async {
  await tester.pumpWidget(
    withLiquidTheme(
      Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LdButton(
              key: const Key('text_button'),
              onPressed: () {},
              size: size,
              child: const Text('Button'),
            ),
            LdButton(
              key: const Key('icon_button'),
              onPressed: () {},
              size: size,
              child: const Icon(LucideIcons.send),
            ),
            LdInput(
              key: const Key('input'),
              hint: 'Input',
              size: size,
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();

  return (
    textButton: _height(tester, find.byKey(const Key('text_button'))),
    iconButton: _height(tester, find.byKey(const Key('icon_button'))),
    input: _height(tester, find.byKey(const Key('input'))),
  );
}

/// Measures the trigger frames of every input-like selection control at [size],
/// alongside a plain [LdInput] whose height serves as the baseline.
Future<({
  double input,
  double select,
  double choose,
  double date,
  double time,
  double duration,
  double recurrence,
})> _measureInputLikeHeights(WidgetTester tester, LdSize size) async {
  await tester.pumpWidget(
    withLiquidTheme(
      Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LdInput(
              key: const Key('input'),
              hint: 'Input',
              size: size,
            ),
            LdSelect<String>(
              key: const Key('select'),
              size: size,
              items: const [
                LdSelectItem(child: Text('A'), value: 'a'),
                LdSelectItem(child: Text('B'), value: 'b'),
              ],
            ),
            LdChoose.fromSelectItems<int>(
              key: const Key('choose'),
              size: size,
              items: const [
                LdSelectItem(child: Text('A'), value: 1),
                LdSelectItem(child: Text('B'), value: 2),
              ],
              onChanged: (_) {},
              placeholder: const Text('Choose'),
            ),
            LdDatePicker(key: const Key('date'), size: size, onChanged: (_) {}),
            LdTimePicker(key: const Key('time'), size: size, onChanged: (_) {}),
            LdDurationPicker(key: const Key('duration'), size: size, onChanged: (_) {}),
            LdRecurrencePicker(key: const Key('recurrence'), size: size, onChanged: (_) {}),
          ],
        ),
      ),
    ),
  );
  await tester.pump();

  return (
    input: _height(tester, find.byKey(const Key('input'))),
    select: _frameHeight(tester, const Key('select')),
    choose: _frameHeight(tester, const Key('choose')),
    date: _frameHeight(tester, const Key('date')),
    time: _frameHeight(tester, const Key('time')),
    duration: _frameHeight(tester, const Key('duration')),
    recurrence: _frameHeight(tester, const Key('recurrence')),
  );
}

void main() {
  group('control height alignment', () {
    for (final size in LdSize.values) {
      testWidgets('text button, icon button, and input match at $size', (tester) async {
        final sizes = await _measureSizes(tester, size);

        expect(
          sizes.textButton,
          moreOrLessEquals(sizes.input, epsilon: 0.5),
          reason: 'text button vs input at $size',
        );
        expect(
          sizes.iconButton,
          moreOrLessEquals(sizes.input, epsilon: 0.5),
          reason: 'icon button vs input at $size',
        );
        expect(
          sizes.textButton,
          moreOrLessEquals(sizes.iconButton, epsilon: 0.5),
          reason: 'text button vs icon button at $size',
        );
      });
    }

    testWidgets('outline button matches input at default size', (tester) async {
      await tester.pumpWidget(
        withLiquidTheme(
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LdButton.outline(
                  key: const Key('outline_button'),
                  onPressed: () {},
                  child: const Text('Button'),
                ),
                LdInput(
                  key: const Key('input'),
                  hint: 'Input',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final outlineHeight = _height(tester, find.byKey(const Key('outline_button')));
      final inputHeight = _height(tester, find.byKey(const Key('input')));

      expect(
        outlineHeight,
        moreOrLessEquals(inputHeight, epsilon: 0.5),
        reason: 'outline button includes border like input',
      );
    });
  });

  group('input-like trigger uniformity', () {
    for (final size in LdSize.values) {
      final theme = LdTheme();
      testWidgets('all selection triggers match controlHeight at $size', (tester) async {
        final heights = await _measureInputLikeHeights(tester, size);
        final expected = theme.controlHeight(size);

        expect(
          heights.select,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'select at $size',
        );
        expect(
          heights.choose,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'choose at $size',
        );
        expect(
          heights.date,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'date picker at $size',
        );
        expect(
          heights.time,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'time picker at $size',
        );
        expect(
          heights.duration,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'duration picker at $size',
        );
        expect(
          heights.recurrence,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'recurrence picker at $size',
        );
      });

      testWidgets('selection triggers match input height at $size', (tester) async {
        final heights = await _measureInputLikeHeights(tester, size);
        final inputHeight = heights.input;

        for (final (name, h) in [
          ('select', heights.select),
          ('choose', heights.choose),
          ('date', heights.date),
          ('time', heights.time),
          ('duration', heights.duration),
          ('recurrence', heights.recurrence),
        ]) {
          expect(
            h,
            moreOrLessEquals(inputHeight, epsilon: 0.5),
            reason: '$name vs input at $size',
          );
        }
      });
    }
  });
}
