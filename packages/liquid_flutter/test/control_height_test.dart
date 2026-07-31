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
}
