import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _harness({
  required ValueNotifier<double> width,
  required List<Widget> children,
}) {
  return MaterialApp(
    home: ldFrame(
      size: LdThemeSize.m,
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: width,
          builder: (context, value, child) => SizedBox(width: value, child: child),
          child: LdOverflowView(
            builder: (context, overflowedChildIndices) => SizedBox(
              width: 32,
              height: 32,
              child: Center(child: Text('+${overflowedChildIndices.length}')),
            ),
            spacing: 8,
            children: children,
          ),
        ),
      ),
    ),
  );
}

// Positioned children are left out of intrinsic measuring, so nothing caches a
// size on the text and a rebuild marks it for layout directly, the same way a
// label inside an LdButton does.
Widget _label(ValueNotifier<int> tick, String prefix) => Stack(
      children: [
        const SizedBox(width: 100, height: 32),
        Positioned(
          left: 0,
          top: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: tick,
            builder: (context, value, child) => Text('$prefix $value'),
          ),
        ),
      ],
    );

Future<void> _rebuildTwice(WidgetTester tester, ValueNotifier<int> tick) async {
  tick.value = 1;
  await tester.pump();
  tick.value = 2;
  await tester.pump();
}

void main() {
  group('hidden children keep getting laid out', () {
    testWidgets('adaptive: rebuilding the skipped expanded variant', (tester) async {
      final tick = ValueNotifier<int>(0);
      final width = ValueNotifier<double>(260);
      await tester.pumpWidget(_harness(
        width: width,
        children: [
          LdOverflowAdaptiveChild(
            expanded: Padding(padding: const EdgeInsets.all(8), child: _label(tick, 'expanded')),
            compact: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.save)),
          ),
          const SizedBox(width: 80, height: 32, child: Text('Other')),
        ],
      ));
      width.value = 150;
      await tester.pump();
      await _rebuildTwice(tester, tick);
      expect(tester.takeException(), isNull);
    });

    testWidgets('overflow view: rebuilding an overflowed child', (tester) async {
      final tick = ValueNotifier<int>(0);
      final width = ValueNotifier<double>(400);
      await tester.pumpWidget(_harness(
        width: width,
        children: [
          for (var i = 0; i < 3; i++) Padding(padding: const EdgeInsets.all(8), child: _label(tick, 'child $i')),
        ],
      ));
      width.value = 150;
      await tester.pump();
      await _rebuildTwice(tester, tick);
      expect(tester.takeException(), isNull);
    });
  });
}
