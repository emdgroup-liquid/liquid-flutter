import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
            builder: (context, remainingItemCount) => SizedBox(
              width: 32,
              height: 32,
              child: Center(child: Text('+$remainingItemCount')),
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

/// Simulates [LdContextMenu] placing a trigger in the overflow row without being
/// an [LdOverflowAdaptiveChild] itself.
class _OverflowActionWrapper extends StatelessWidget {
  const _OverflowActionWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

void main() {
  group('LdOverflowAdaptiveChild', () {
    testWidgets('uses expanded variant when space allows', (tester) async {
      const expandedKey = Key('expanded');
      const compactKey = Key('compact');

      await tester.pumpWidget(
        _overflowHarness(
          width: 260,
          children: [
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: expandedKey,
                width: 120,
                height: 32,
                child: Center(child: Text('Expanded label')),
              ),
              compact: const SizedBox(
                key: compactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.save),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 32,
              child: Center(child: Text('Other')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_hasLayoutSize(find.byKey(expandedKey), tester), isTrue);
      expect(_hasLayoutSize(find.byKey(compactKey), tester), isFalse);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('+0'), findsNothing);
    });

    testWidgets('uses compact variant when preferred size overflows', (tester) async {
      const expandedKey = Key('expanded');
      const compactKey = Key('compact');

      await tester.pumpWidget(
        _overflowHarness(
          width: 120,
          children: [
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: expandedKey,
                width: 120,
                height: 32,
                child: Center(child: Text('Expanded label')),
              ),
              compact: const SizedBox(
                key: compactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.save),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 32,
              child: Center(child: Text('Other')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_hasLayoutSize(find.byKey(expandedKey), tester), isFalse);
      expect(_hasLayoutSize(find.byKey(compactKey), tester), isTrue);
      expect(find.byIcon(LucideIcons.save), findsOneWidget);
    });

    testWidgets('shows overflow menu when flex title and fixed actions exceed width', (tester) async {
      await tester.pumpWidget(
        _overflowHarness(
          width: 280,
          children: [
            const LdFlexibleChild(
              child: Text('Tasks'),
            ),
            const SizedBox(
              width: 120,
              height: 32,
              child: Center(child: Text('Search')),
            ),
            const SizedBox(
              width: 90,
              height: 32,
              child: Center(child: Text('Refresh')),
            ),
            const SizedBox(
              width: 90,
              height: 32,
              child: Center(child: Text('New Task')),
            ),
            const SizedBox(
              width: 90,
              height: 32,
              child: Center(child: Text('Select')),
            ),
            const SizedBox(
              width: 90,
              height: 32,
              child: Center(child: Text('Filter')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsOneWidget);
      expect(find.text('Filter'), findsNothing);

      final row = tester.renderObject<RenderBox>(find.byType(LdOverflowView));
      for (final label in ['Tasks', 'Search', 'Refresh', 'New Task', 'Select']) {
        final finder = find.text(label);
        if (!_hasLayoutSize(finder, tester)) {
          continue;
        }
        final box = tester.renderObject<RenderBox>(finder);
        final bottomRight = box.localToGlobal(box.size.bottomRight(Offset.zero));
        final rowBottomRight = row.localToGlobal(row.size.bottomRight(Offset.zero));
        expect(
          bottomRight.dx,
          lessThanOrEqualTo(rowBottomRight.dx + 0.5),
          reason: '$label should not clip past the overflow row',
        );
      }
    });

    testWidgets('does not show overflow menu for flex-only title with wide intrinsic width', (tester) async {
      await tester.pumpWidget(
        _overflowHarness(
          width: 320,
          children: [
            LdFlexibleChild(
              child: LdAutoSpace(
                children: [
                  const LdInput(hint: 'Test...'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 200, child: LdText.h('5-4')),
                        SizedBox(width: 200, child: LdText.h('5-4')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsNothing);
      expect(find.byIcon(LucideIcons.ellipsisVertical), findsNothing);

      final flexChild = tester.renderObject<RenderBox>(
        find.descendant(
          of: find.byType(LdOverflowView),
          matching: find.byType(LdFlexibleChild),
        ),
      );
      final overflowView = tester.renderObject<RenderBox>(find.byType(LdOverflowView));
      expect(
        flexChild.localToGlobal(Offset.zero).dx,
        greaterThanOrEqualTo(overflowView.localToGlobal(Offset.zero).dx - 0.5),
      );
    });

    testWidgets('shows overflow menu when flex title min width exceeds row', (tester) async {
      await tester.pumpWidget(
        _overflowHarness(
          width: 320,
          children: [
            LdFlexibleChild(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Very Long Page Title That Should Not Hide Actions'),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 32,
              child: Center(child: Text('Filter')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsOneWidget);
      expect(find.text('Filter'), findsNothing);

      final titleBox = tester.renderObject<RenderBox>(
        find.text('Very Long Page Title That Should Not Hide Actions'),
      );
      final overflowView = tester.renderObject<RenderBox>(find.byType(LdOverflowView));
      final indicatorBox = tester.renderObject<RenderBox>(find.textContaining('+'));
      expect(titleBox.size.width, lessThan(overflowView.size.width));
      expect(
        titleBox.localToGlobal(titleBox.size.centerRight(Offset.zero)).dx,
        closeTo(indicatorBox.localToGlobal(Offset.zero).dx - 8, 1),
      );
    });

    testWidgets('flex child keeps min width before adaptive children compact', (tester) async {
      await tester.pumpWidget(
        _overflowHarness(
          width: 220,
          children: [
            const LdFlexibleChild(
              child: Text('Page Title'),
            ),
            LdAppBarAction(
              leading: const Icon(LucideIcons.listFilter),
              onPressed: () {},
              child: const Text('Filter items'),
            ),
            LdAppBarAction(
              leading: const Icon(LucideIcons.save),
              onPressed: () {},
              child: const Text('Save all changes'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.renderObject<RenderBox>(find.text('Page Title')).size.width, greaterThan(48));
      expect(find.text('Filter items'), findsNothing);
      expect(find.text('Save all changes'), findsNothing);
    });

    testWidgets('compacts when adaptive child is nested in a wrapper', (tester) async {
      const expandedKey = Key('wrapped-expanded');
      const compactKey = Key('wrapped-compact');

      await tester.pumpWidget(
        _overflowHarness(
          width: 80,
          children: [
            _OverflowActionWrapper(
              child: LdOverflowAdaptiveChild(
                expanded: const SizedBox(
                  key: expandedKey,
                  width: 120,
                  height: 32,
                  child: Center(child: Text('Theme')),
                ),
                compact: const SizedBox(
                  key: compactKey,
                  width: 32,
                  height: 32,
                  child: Icon(LucideIcons.paintBucket),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_hasLayoutSize(find.byKey(expandedKey), tester), isFalse);
      expect(_hasLayoutSize(find.byKey(compactKey), tester), isTrue);
    });

    testWidgets('compacts adaptive children progressively from the trailing edge', (tester) async {
      const firstExpandedKey = Key('first-expanded');
      const firstCompactKey = Key('first-compact');
      const secondExpandedKey = Key('second-expanded');
      const secondCompactKey = Key('second-compact');

      await tester.pumpWidget(
        _overflowHarness(
          width: 175,
          children: [
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: firstExpandedKey,
                width: 100,
                height: 32,
                child: Center(child: Text('First expanded')),
              ),
              compact: const SizedBox(
                key: firstCompactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.save),
              ),
            ),
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: secondExpandedKey,
                width: 100,
                height: 32,
                child: Center(child: Text('Second expanded')),
              ),
              compact: const SizedBox(
                key: secondCompactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.trash),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_hasLayoutSize(find.byKey(firstExpandedKey), tester), isTrue);
      expect(_hasLayoutSize(find.byKey(secondExpandedKey), tester), isFalse);
      expect(_hasLayoutSize(find.byKey(secondCompactKey), tester), isTrue);
      expect(_hasLayoutSize(find.byKey(firstCompactKey), tester), isFalse);
    });

    testWidgets('compacts all adaptive children when space is very tight', (tester) async {
      const firstExpandedKey = Key('first-expanded');
      const firstCompactKey = Key('first-compact');
      const secondExpandedKey = Key('second-expanded');
      const secondCompactKey = Key('second-compact');

      await tester.pumpWidget(
        _overflowHarness(
          width: 110,
          children: [
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: firstExpandedKey,
                width: 100,
                height: 32,
                child: Center(child: Text('First expanded')),
              ),
              compact: const SizedBox(
                key: firstCompactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.save),
              ),
            ),
            LdOverflowAdaptiveChild(
              expanded: const SizedBox(
                key: secondExpandedKey,
                width: 100,
                height: 32,
                child: Center(child: Text('Second expanded')),
              ),
              compact: const SizedBox(
                key: secondCompactKey,
                width: 32,
                height: 32,
                child: Icon(LucideIcons.trash),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_hasLayoutSize(find.byKey(firstExpandedKey), tester), isFalse);
      expect(_hasLayoutSize(find.byKey(secondExpandedKey), tester), isFalse);
      expect(_hasLayoutSize(find.byKey(firstCompactKey), tester), isTrue);
      expect(_hasLayoutSize(find.byKey(secondCompactKey), tester), isTrue);
    });
  });
}
