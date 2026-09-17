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
  group('LdOverflowAlwaysChild', () {
    testWidgets('shows indicator and hides child even with plenty of room', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 500,
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
            LdOverflowAlwaysChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Always')),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Always'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('keeps overflowable siblings on stage when space allows', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 500,
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
            LdOverflowAlwaysChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Always')),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overflowable'), findsOneWidget);
      expect(_hasLayoutSize(find.text('Overflowable'), tester), isTrue);
      expect(find.text('Always'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('moves overflowable siblings to overflow first when tight', (tester) async {
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
            LdOverflowAlwaysChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Always')),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overflowable'), findsNothing);
      expect(find.text('Always'), findsNothing);
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('reports off-stage indices when always child is between siblings', (tester) async {
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
                    LdOverflowAlwaysChild(
                      child: SizedBox(
                        width: 90,
                        height: 32,
                        child: Center(child: Text('Always')),
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

      expect(find.text('Always'), findsNothing);
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
      expect(indicatorTexts, ['1,2,3']);
    });

    testWidgets('child stays in overflow menu after opening it', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 500,
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
            LdOverflowAlwaysChild(
              child: SizedBox(
                width: 80,
                height: 32,
                child: Center(child: Text('Always')),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final indicatorTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(LdOverflowView),
              matching: find.byWidgetPredicate(
                (widget) => widget is Text && widget.data != null && widget.data!.startsWith('+'),
              ),
            ),
          )
          .map((text) => text.data!)
          .toList();
      expect(indicatorTexts, ['+1']);
    });
  });
}