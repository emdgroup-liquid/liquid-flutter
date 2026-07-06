import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget _wrap(Widget child) {
  return LdThemeProvider(
    theme: LdTheme(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

/// Returns the list of [LdSpacer] widgets found inside an [LdAutoSpace].
Iterable<LdSpacer> _spacers(WidgetTester tester) =>
    tester.widgetList<LdSpacer>(find.byType(LdSpacer));

void main() {
  group('LdAutoSpace – spacer insertion', () {
    testWidgets('inserts no spacers for a single child', (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [LdText('Only child')],
      )));
      await tester.pumpAndSettle();
      expect(_spacers(tester), isEmpty);
    });

    testWidgets('LdText headline → LdText body inserts LdSize.l × 2 spacers',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdText('Headline', type: LdTextType.headline),
          LdText('Body text'),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 2);
      expect(spacers.every((s) => s.size == LdSize.l), isTrue);
    });

    testWidgets(
        'LdText headline → LdText label inserts LdSize.xs × 1 spacer',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdText('Headline', type: LdTextType.headline),
          LdText('Label', type: LdTextType.label),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.xs);
    });

    testWidgets(
        'LdText paragraph → LdText headline inserts LdSize.l × 3 spacers',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdText('Paragraph', type: LdTextType.paragraph),
          LdText('Next headline', type: LdTextType.headline),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 3);
      expect(spacers.every((s) => s.size == LdSize.l), isTrue);
    });

    testWidgets(
        'LdText paragraph → LdText paragraph inserts LdSize.m × 1 spacer',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdText('Para 1', type: LdTextType.paragraph),
          LdText('Para 2', type: LdTextType.paragraph),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.m);
    });

    testWidgets('LdText → non-text inserts LdSize.m × 1 spacer',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdText('Some text'),
          LdButton(child: const Text('Click'), onPressed: () {}),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.m);
    });

    testWidgets('non-text → LdText headline inserts LdSize.l × 2 spacers',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdButton(child: const Text('Click'), onPressed: () {}),
          LdText('Headline', type: LdTextType.headline),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 2);
      expect(spacers.every((s) => s.size == LdSize.l), isTrue);
    });

    testWidgets('LdButton → LdButton inserts LdSize.s × 1 spacer',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdButton(child: const Text('A'), onPressed: () {}),
          LdButton(child: const Text('B'), onPressed: () {}),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.s);
    });

    testWidgets('LdCard → LdCard inserts LdSize.l × 2 spacers',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdCard(child: const Text('Card 1')),
          LdCard(child: const Text('Card 2')),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 2);
      expect(spacers.every((s) => s.size == LdSize.l), isTrue);
    });

    testWidgets('LdDivider → anything inserts LdSize.l × 2 spacers',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          const LdDivider(),
          LdText('After divider'),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 2);
      expect(spacers.every((s) => s.size == LdSize.l), isTrue);
    });

    testWidgets(
        'existing LdSpacer child suppresses additional spacer insertion',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          const LdSpacer(size: LdSize.m),
          LdText('After spacer'),
        ],
      )));
      await tester.pumpAndSettle();

      // Only the explicit LdSpacer should be present; none auto-inserted.
      expect(_spacers(tester).length, 1);
    });

    testWidgets('default spacing applied for unmatched widget pairs',
        (tester) async {
      await tester.pumpWidget(_wrap(LdAutoSpace(
        defaultSpacing: LdSize.l,
        children: [
          const SizedBox(height: 10),
          const SizedBox(height: 10),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.l);
    });

    testWidgets('LdMute wrapper is unwrapped before spacing is computed',
        (tester) async {
      // LdMute(LdText(headline)) → LdText(label) should give headline→label rule
      await tester.pumpWidget(_wrap(LdAutoSpace(
        children: [
          LdMute(child: LdText('Headline', type: LdTextType.headline)),
          LdText('Label', type: LdTextType.label),
        ],
      )));
      await tester.pumpAndSettle();

      final spacers = _spacers(tester).toList();
      expect(spacers.length, 1);
      expect(spacers.first.size, LdSize.xs);
    });
  });
}
