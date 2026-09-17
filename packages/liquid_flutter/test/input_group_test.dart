import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

BorderRadius _radiusOf(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(find.byKey(key));
  return (container.decoration! as BoxDecoration).borderRadius! as BorderRadius;
}

Border _borderOf(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(find.byKey(key));
  return (container.decoration! as BoxDecoration).border! as Border;
}

Future<void> _pumpGroup(WidgetTester tester, Widget group) async {
  await tester.pumpWidget(withLiquidTheme(group));
  await tester.pump();
}

/// Height of the [LdFieldFrame] of an input-like member of the group —
/// the actual painted control box.
double _frameHeight(WidgetTester tester, Key key) {
  return tester
      .getSize(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(LdFieldFrame),
        ),
      )
      .height;
}

void _noopCheck(bool _) {}

Future<({double button, double input, double addon})> _memberHeights(
  WidgetTester tester,
  LdSize size,
) async {
  await _pumpGroup(
    tester,
    LdInputGroup(
      size: size,
      children: [
        LdButton.outline(
          key: const Key('button'),
          onPressed: () {},
          child: const Text('Go'),
        ),
        LdInput(key: const Key('input'), hint: 'Input'),
        LdInputGroupText(
          const Text('@'),
          key: Key('addon_$size'),
        ),
      ],
    ),
  );
  return (
    button: tester.getSize(find.byKey(const Key('button'))).height,
    input: tester.getSize(find.byKey(const Key('input'))).height,
    addon: tester
        .getSize(find.byKey(Key('addon_$size')))
        .height,
  );
}

void main() {
  group('LdControlGroupScope surface logic', () {
    final theme = LdTheme();

    test('first member rounds outer start corners only', () {
      final first = const LdControlGroupScope(index: 0, count: 2, size: LdSize.m);
      final r = first.radiusFor(theme, TextDirection.ltr);
      expect(r.topLeft, isNot(equals(Radius.zero)));
      expect(r.topRight, Radius.zero);

      // Mirrored for RTL.
      final rtl = first.radiusFor(theme, TextDirection.rtl);
      expect(rtl.topLeft, Radius.zero);
      expect(rtl.topRight, isNot(equals(Radius.zero)));
    });

    test('last member rounds outer end corners only', () {
      final last = const LdControlGroupScope(index: 1, count: 2, size: LdSize.m);
      final r = last.radiusFor(theme, TextDirection.ltr);
      expect(r.topLeft, Radius.zero);
      expect(r.topRight, isNot(equals(Radius.zero)));

      final rtl = last.radiusFor(theme, TextDirection.rtl);
      expect(rtl.topLeft, isNot(equals(Radius.zero)));
      expect(rtl.topRight, Radius.zero);
    });

    test('middle and inner members have flat corners', () {
      final middle = const LdControlGroupScope(index: 1, count: 3, size: LdSize.m);
      final r = middle.radiusFor(theme, TextDirection.ltr);
      expect(r.topLeft, Radius.zero);
      expect(r.topRight, Radius.zero);
      expect(r.bottomLeft, Radius.zero);
      expect(r.bottomRight, Radius.zero);
    });

    test('single member keeps its full radius', () {
      final single = const LdControlGroupScope(index: 0, count: 1, size: LdSize.m);
      final r = single.radiusFor(theme, TextDirection.ltr);
      expect(r.topLeft, isNot(equals(Radius.zero)));
      expect(r.topRight, isNot(equals(Radius.zero)));
      expect(r.bottomLeft, isNot(equals(Radius.zero)));
      expect(r.bottomRight, isNot(equals(Radius.zero)));
    });

    test('explicit radius always wins', () {
      const scope = LdControlGroupScope(index: 0, count: 3, size: LdSize.m);
      const explicit = BorderRadius.all(Radius.circular(42));
      expect(scope.radiusFor(theme, TextDirection.ltr, explicit: explicit), explicit);
    });

    test('seam edges halve the border so neighbours sum to a full line', () {
      final w = theme.borderWidth;
      expect(w, greaterThan(0));

      final first = const LdControlGroupScope(index: 0, count: 2, size: LdSize.m)
          .borderFor(theme, Colors.amber, TextDirection.ltr);
      expect(first.left.width, w);
      expect(first.right.width, w / 2);
      expect(first.top.width, w);

      final last = const LdControlGroupScope(index: 1, count: 2, size: LdSize.m)
          .borderFor(theme, Colors.amber, TextDirection.ltr);
      expect(last.left.width, w / 2);
      expect(last.right.width, w);

      // RTL mirrors start/end.
      final rtlFirst = const LdControlGroupScope(index: 0, count: 2, size: LdSize.m)
          .borderFor(theme, Colors.amber, TextDirection.rtl);
      expect(rtlFirst.left.width, w / 2);
      expect(rtlFirst.right.width, w);

      // The two halves at a seam add back up to a single full-width line.
      expect(first.right.width + last.left.width, w);
    });

    test('single member keeps a full border on every edge', () {
      final single = const LdControlGroupScope(index: 0, count: 1, size: LdSize.m)
          .borderFor(theme, Colors.amber, TextDirection.ltr);
      expect(single.left.width, theme.borderWidth);
      expect(single.right.width, theme.borderWidth);
      expect(single.top.width, theme.borderWidth);
      expect(single.bottom.width, theme.borderWidth);
    });
  });

  group('LdInputGroup widget', () {
    for (final size in LdSize.values) {
      testWidgets('members share controlHeight at $size', (tester) async {
        final heights = await _memberHeights(tester, size);
        final expected = LdTheme().controlHeight(size);
        expect(
          heights.button,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'button at $size',
        );
        expect(
          heights.input,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'input at $size',
        );
        expect(
          heights.addon,
          moreOrLessEquals(expected, epsilon: 0.5),
          reason: 'addon at $size',
        );
      });
    }

    testWidgets('input is flexible and grows, fixed members keep intrinsic width', (tester) async {
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdButton.outline(
              key: const Key('button'),
              onPressed: () {},
              child: const Text('Go'),
            ),
            LdInput(key: const Key('input'), hint: 'Input'),
          ],
        ),
      );
      final inputWidth = tester.getSize(find.byKey(const Key('input'))).width;
      final buttonWidth = tester.getSize(find.byKey(const Key('button'))).width;
      expect(inputWidth, greaterThan(buttonWidth));
    });

    testWidgets('drops labels of input members', (tester) async {
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdInput(key: const Key('input'), hint: 'Input', label: 'Email'),
            LdButton.outline(
              key: const Key('button'),
              onPressed: () {},
              child: const Text('Go'),
            ),
          ],
        ),
      );
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('suppressed labels become tooltips in a group', (tester) async {
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdInput(key: const Key('input'), hint: 'Input', label: 'Email'),
            LdSelect<String>(
              key: const Key('select'),
              label: 'Region',
              items: const [LdSelectItem(child: Text('EU'), value: 'EU')],
            ),
            LdCheckbox(key: const Key('check'), label: 'Accepted', onChanged: (_) {}),
          ],
        ),
      );

      // No visual label text is rendered.
      expect(find.text('Email'), findsNothing);
      expect(find.text('Region'), findsNothing);
      expect(find.text('Accepted'), findsNothing);

      // But each control carries the label as a tooltip message.
      String? tooltip(Key key) {
        final tooltips = tester.widgetList<Tooltip>(
          find.descendant(of: find.byKey(key), matching: find.byType(Tooltip)),
        );
        return tooltips.isEmpty ? null : tooltips.first.message;
      }

      expect(tooltip(const Key('input')), 'Email');
      expect(tooltip(const Key('select')), 'Region');
      expect(tooltip(const Key('check')), 'Accepted');
    });

    testWidgets('labels stay plain text when standalone', (tester) async {
      await tester.pumpWidget(
        withLiquidTheme(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LdInput(hint: 'Input', label: 'Email'),
              LdCheckbox(label: 'Accepted', onChanged: _noopCheck),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
    });

    testWidgets('empty group renders zero size', (tester) async {
      await _pumpGroup(
        tester,
        const LdInputGroup(children: []),
      );
      expect(tester.getSize(find.byType(LdInputGroup)).height, 0);
    });
  });

  group('LdInputGroup joined decoration', () {
    testWidgets('button renders half-width seam border at the inner edge', (tester) async {
      final w = LdTheme().borderWidth;
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdButton.outline(
              key: const Key('button'),
              onPressed: () {},
              child: const Text('Go'),
            ),
            LdInput(key: const Key('input'), hint: 'Input'),
          ],
        ),
      );
      final border = _borderOf(tester, const Key('ldButton_shape'));
      expect(border.left.width, w, reason: 'outer edge keeps full width');
      expect(border.right.width, w / 2, reason: 'seam edge halves the width');
    });

    testWidgets('middle member flattens its radius', (tester) async {
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdInputGroupText(const Text('pre'), key: const Key('addon')),
            LdInput(key: const Key('input'), hint: 'Input'),
            LdButton.outline(
              key: const Key('button'),
              onPressed: () {},
              child: const Text('Go'),
            ),
          ],
        ),
      );
      final r = _radiusOf(tester, const Key('ldInput_container'));
      expect(r.topLeft, Radius.zero);
      expect(r.topRight, Radius.zero);
    });

    testWidgets('mirrors radius for RTL layouts', (tester) async {
      await _pumpGroup(
        tester,
        Directionality(
          textDirection: TextDirection.rtl,
          child: LdInputGroup(
            children: [
              LdButton.outline(
                key: const Key('button'),
                onPressed: () {},
                child: const Text('Go'),
              ),
              LdInput(key: const Key('input'), hint: 'Input'),
            ],
          ),
        ),
      );
      final r = _radiusOf(tester, const Key('ldButton_shape'));
      expect(r.topLeft, Radius.zero, reason: 'first member in RTL sits on the right');
      expect(r.topRight, isNot(equals(Radius.zero)));
    });

    testWidgets('checkbox joins at controlHeight inside its slot', (tester) async {
      final theme = LdTheme();
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdCheckbox(key: const Key('check'), onChanged: (_) {}),
            LdInput(key: const Key('input'), hint: 'Input'),
          ],
        ),
      );
      final size = tester.getSize(find.byKey(const ValueKey('groupedFrame')));
      expect(size.width, moreOrLessEquals(theme.controlHeight(LdSize.m), epsilon: 0.5));
      expect(size.height, moreOrLessEquals(theme.controlHeight(LdSize.m), epsilon: 0.5));
    });

    testWidgets('checkbox slot still toggles', (tester) async {
      var checked = false;
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdCheckbox(
              key: const Key('check'),
              checked: checked,
              onChanged: (_) => checked = true,
            ),
            LdInput(key: const Key('input'), hint: 'Input'),
          ],
        ),
      );
      await tester.tap(find.byKey(const Key('check')));
      await tester.pump();
      expect(checked, isTrue);
    });

    testWidgets('unwraps LdReveal members', (tester) async {
      await _pumpGroup(
        tester,
        LdInputGroup(
          children: [
            LdInput(key: const Key('input'), hint: 'Input'),
            LdReveal(
              revealed: true,
              child: LdButton(
                key: const Key('button'),
                onPressed: () {},
                child: const Text('Go'),
              ),
            ),
          ],
        ),
      );
      final inputWidth = tester.getSize(find.byKey(const Key('input'))).width;
      final buttonWidth = tester.getSize(find.byKey(const Key('button'))).width;
      expect(inputWidth, greaterThan(buttonWidth));
    });

    testWidgets('mixed input-like members keep the group at controlHeight', (tester) async {
      final theme = LdTheme();
      const size = LdSize.m;
      await _pumpGroup(
        tester,
        LdInputGroup(
          size: size,
          children: [
            LdSelect<String>(
              key: const Key('select'),
              items: const [LdSelectItem(child: Text('A'), value: 'a')],
            ),
            LdChoose.fromSelectItems<int>(
              key: const Key('choose'),
              items: const [LdSelectItem(child: Text('A'), value: 1)],
              onChanged: (_) {},
            ),
            LdDatePicker(key: const Key('date'), onChanged: (_) {}),
            LdTimePicker(key: const Key('time'), onChanged: (_) {}),
            LdDurationPicker(key: const Key('duration'), onChanged: (_) {}),
            LdRecurrencePicker(key: const Key('recurrence'), onChanged: (_) {}),
            LdInput(key: const Key('input'), hint: 'Input'),
          ],
        ),
      );

      final groupHeight = tester.getSize(find.byType(LdInputGroup)).height;
      expect(
        groupHeight,
        moreOrLessEquals(theme.controlHeight(size), epsilon: 0.5),
        reason: 'whole group height',
      );

      for (final key in ['select', 'choose', 'date', 'time', 'duration', 'recurrence']) {
        expect(
          _frameHeight(tester, Key(key)),
          moreOrLessEquals(theme.controlHeight(size), epsilon: 0.5),
          reason: 'member $key in group',
        );
      }
      // LdInput builds its own shell rather than an LdFieldFrame; the outer
      // widget (label dropped inside the group) already equals controlHeight.
      expect(
        tester.getSize(find.byKey(const Key('input'))).height,
        moreOrLessEquals(theme.controlHeight(size), epsilon: 0.5),
        reason: 'input in group',
      );
    });
  });
}