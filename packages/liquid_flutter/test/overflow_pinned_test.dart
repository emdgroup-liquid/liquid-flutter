import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';

Widget _overflowHarness({
  required double width,
  required List<Widget> children,
}) {
  return MaterialApp(
    home: ldFrame(
      size: LdThemeSize.m,
      child: Center(
        child: SizedBox(
          width: width,
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

bool _hasLayoutSize(Finder finder, WidgetTester tester) {
  final elements = finder.evaluate();
  if (elements.isEmpty) {
    return false;
  }
  return tester.renderObject<RenderBox>(finder).hasSize;
}

void main() {
  group('LdOverflowPinnedChild', () {
    testWidgets('keeps trailing pinned child visible when overflowable sibling overflows', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 150,
          children: [
            const LdFlexibleChild(
              child: SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Title'),
                ),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 32,
              child: Center(child: Text('Overflowable')),
            ),
            LdOverflowPinnedChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Pinned')),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pinned'), findsOneWidget);
      expect(_hasLayoutSize(find.text('Pinned'), tester), isTrue);
      expect(find.text('Overflowable'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('keeps pinned child visible when it precedes overflowable sibling', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 150,
          children: [
            const LdFlexibleChild(
              child: SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Title'),
                ),
              ),
            ),
            LdOverflowPinnedChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Pinned')),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 32,
              child: Center(child: Text('Overflowable')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pinned'), findsOneWidget);
      expect(_hasLayoutSize(find.text('Pinned'), tester), isTrue);
      expect(find.text('Overflowable'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('reports off-stage indices when pinned child is between overflowable siblings', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          home: ldFrame(
            size: LdThemeSize.m,
            child: Center(
              child: SizedBox(
                width: 120,
                child: LdOverflowView(
                  builder: (context, overflowedChildIndices) => SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(child: Text(overflowedChildIndices.join(','))),
                  ),
                  spacing: 8,
                  children: [
                    const LdFlexibleChild(
                      child: SizedBox(
                        height: 32,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Title'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 90,
                      height: 32,
                      child: Center(child: Text('Before')),
                    ),
                    LdOverflowPinnedChild(
                      child: SizedBox(
                        width: 90,
                        height: 32,
                        child: Center(child: Text('Pinned')),
                      ),
                    ),
                    const SizedBox(
                      width: 90,
                      height: 32,
                      child: Center(child: Text('After')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
      expect(find.text('After'), findsNothing);

      final indicatorTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(LdOverflowView),
              matching: find.byWidgetPredicate(
                (widget) => widget is Text && widget.data != null && widget.data!.contains(','),
              ),
            ),
          )
          .map((text) => text.data!)
          .toList();
      expect(indicatorTexts, ['1,3']);
    });
  });
}
