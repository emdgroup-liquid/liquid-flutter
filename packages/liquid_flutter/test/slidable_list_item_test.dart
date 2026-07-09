import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: Scaffold(
      body: LdThemeProvider(
        child: SizedBox(
          width: 400,
          child: child,
        ),
      ),
    ),
  );
}

LdSlidableListItem _buildSlidable({
  required String title,
  VoidCallback? onArchive,
  VoidCallback? onDelete,
  LdSlideActionDismissBehavior deleteDismiss = LdSlideActionDismissBehavior.snapBack,
  double threshold = 1.0,
}) {
  return LdSlidableListItem(
    endActionPane: LdSlideActionPane(
      threshold: threshold,
      actions: [
        LdSlideAction(
          icon: LucideIcons.archive,
          label: 'Archive',
          onTriggered: (_) => onArchive?.call(),
        ),
        LdSlideAction(
          icon: LucideIcons.trash2,
          label: 'Delete',
          onTriggered: (_) => onDelete?.call(),
          dismissBehavior: deleteDismiss,
        ),
      ],
    ),
    child: LdListItem(
      title: Text(title),
    ),
  );
}

Future<void> _tapArchiveInRow(WidgetTester tester, String rowTitle) async {
  final target = find.descendant(
    of: find.ancestor(
      of: find.text(rowTitle),
      matching: find.byType(LdSlidableListItem),
    ),
    matching: find.byKey(const ValueKey('ld-slide-target-Archive-0')),
  );
  await tester.tap(target);
}

Future<void> _pumpSpring(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));
}

void main() {
  group('LdSlidableListItem', () {
    // Disable animations so the peek timer does not leak into unrelated tests.
    setUp(() => ldDisableAnimations = true);
    tearDown(() => ldDisableAnimations = false);

    testWidgets('partial drag does not trigger actions', (tester) async {
      var archiveCalled = false;
      var deleteCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            onArchive: () => archiveCalled = true,
            onDelete: () => deleteCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-30, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(archiveCalled, isFalse);
      expect(deleteCalled, isFalse);
    });

    testWidgets('swipe past archive width triggers archive not delete', (tester) async {
      var archiveCalled = false;
      var deleteCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            onArchive: () => archiveCalled = true,
            onDelete: () => deleteCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-100, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(archiveCalled, isTrue);
      expect(deleteCalled, isFalse);
    });

    testWidgets('full swipe into archive triggers snapBack action', (tester) async {
      var archiveCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            onArchive: () => archiveCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-75, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(archiveCalled, isTrue);
    });

    testWidgets('full swipe into delete triggers delete not archive', (tester) async {
      var archiveCalled = false;
      var deleteCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            onArchive: () => archiveCalled = true,
            onDelete: () => deleteCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-145, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(archiveCalled, isFalse);
      expect(deleteCalled, isTrue);
    });

    testWidgets('full swipe into delete triggers delete action', (tester) async {
      var deleteCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            onDelete: () => deleteCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-145, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(deleteCalled, isTrue);
    });

    testWidgets('tap revealed archive triggers action', (tester) async {
      var archiveCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            threshold: 1.0,
            onArchive: () => archiveCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-58, 0));
      await _pumpSpring(tester);

      await _tapArchiveInRow(tester, 'Item');
      await _pumpSpring(tester);

      expect(archiveCalled, isTrue);
    });

    testWidgets('dismiss delete triggers callback after collapse', (tester) async {
      ldDisableAnimations = false;
      var deleteCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            deleteDismiss: LdSlideActionDismissBehavior.dismiss,
            onDelete: () => deleteCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-145, 0));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(deleteCalled, isTrue);
    });

    testWidgets('swipe back closes open row without triggering action', (tester) async {
      var archiveCalled = false;

      await tester.pumpWidget(
        _wrap(
          _buildSlidable(
            title: 'Item',
            threshold: 1.0,
            onArchive: () => archiveCalled = true,
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-58, 0));
      await _pumpSpring(tester);

      expect(
        find.byKey(const ValueKey('ld-slide-target-Archive-0')),
        findsOneWidget,
      );

      final rowCenter = tester.getCenter(find.byType(LdSlidableListItem));
      await tester.dragFrom(rowCenter, const Offset(80, 0));
      await _pumpSpring(tester);

      expect(
        find.byKey(const ValueKey('ld-slide-target-Archive-0')),
        findsNothing,
      );
      expect(archiveCalled, isFalse);
    });

    testWidgets('scroll closes open slidable row', (tester) async {
      var archiveCalled = false;

      await tester.pumpWidget(
        _wrap(
          LdSlidableGroup(
            child: _buildSlidable(
              title: 'Item',
              threshold: 1.0,
              onArchive: () => archiveCalled = true,
            ),
          ),
        ),
      );

      await tester.drag(find.text('Item'), const Offset(-58, 0));
      await _pumpSpring(tester);

      expect(
        find.byKey(const ValueKey('ld-slide-target-Archive-0')),
        findsOneWidget,
      );

      archiveCalled = false;
      await _tapArchiveInRow(tester, 'Item');
      await _pumpSpring(tester);
      expect(archiveCalled, isTrue);

      archiveCalled = false;
      final groupContext = tester.element(find.byType(LdSlidableGroup));
      ScrollStartNotification(
        context: groupContext,
        metrics: FixedScrollMetrics(
          maxScrollExtent: 0,
          minScrollExtent: 0,
          pixels: 0,
          viewportDimension: 200,
          devicePixelRatio: 1,
          axisDirection: AxisDirection.down,
        ),
      ).dispatch(groupContext);
      await _pumpSpring(tester);

      expect(
        find.byKey(const ValueKey('ld-slide-target-Archive-0')),
        findsNothing,
      );
      expect(archiveCalled, isFalse);
    });

    testWidgets('dismissing first item in list does not cascade to next item', (tester) async {
      // Regression: without keys, Flutter reuses the _LdSlidableListItemState of
      // the dismissed slot for the item that slides up into its place.  That
      // recycled state carried _isDismissing = true, which immediately triggered
      // an LdReveal collapse on the innocent neighbour.
      ldDisableAnimations = false;
      final items = ['First', 'Second', 'Third'];
      var deletedTitle = '';

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return LdSlidableGroup(
                child: Column(
                  children: [
                    for (final title in items)
                      LdSlidableListItem(
                        endActionPane: LdSlideActionPane(
                          actions: [
                            LdSlideAction(
                              icon: LucideIcons.trash2,
                              label: 'Delete',
                              onTriggered: (_) => setState(() {
                                deletedTitle = title;
                                items.remove(title);
                              }),
                              dismissBehavior: LdSlideActionDismissBehavior.dismiss,
                            ),
                          ],
                        ),
                        child: LdListItem(title: Text(title)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Swipe 'First' all the way to trigger dismiss
      await tester.drag(find.text('First'), const Offset(-145, 0));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(deletedTitle, equals('First'));
      // 'Second' and 'Third' must still be visible
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('opening second row closes first row', (tester) async {
      var secondArchived = false;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 300,
            child: LdSlidableGroup(
              child: Column(
                children: [
                  _buildSlidable(
                    title: 'First',
                    threshold: 1.0,
                    onArchive: () {},
                  ),
                  _buildSlidable(
                    title: 'Second',
                    threshold: 1.0,
                    onArchive: () => secondArchived = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.text('First'), const Offset(-58, 0));
      await _pumpSpring(tester);

      await tester.drag(find.text('Second'), const Offset(-58, 0));
      await _pumpSpring(tester);

      secondArchived = false;

      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('First'),
            matching: find.byType(LdSlidableListItem),
          ),
          matching: find.byKey(const ValueKey('ld-slide-target-Archive-0')),
        ),
        findsNothing,
      );

      await _tapArchiveInRow(tester, 'Second');
      await _pumpSpring(tester);
      expect(secondArchived, isTrue);
    });
  });

  group('LdSlidableListItem – peek hint', () {
    setUp(() => ldDisableAnimations = false);
    tearDown(() => ldDisableAnimations = true);

    // Helper: finds the action tap-target key for a given action label index
    // inside a specific row identified by [rowTitle].
    Finder actionTarget(String rowTitle, String actionLabel, int index) {
      return find.descendant(
        of: find.ancestor(
          of: find.text(rowTitle),
          matching: find.byType(LdSlidableListItem),
        ).first,
        matching: find.byKey(ValueKey('ld-slide-target-$actionLabel-$index')),
      );
    }

    testWidgets('standalone item briefly peeks then snaps back', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildSlidable(title: 'Item'),
        ),
      );
      // Flush initial frames / addPostFrameCallback.
      await tester.pump();
      await tester.pump();

      // Before delay: no action targets visible.
      expect(find.byKey(const ValueKey('ld-slide-target-Archive-0')), findsNothing);

      // Advance past the 1500 ms peek delay then flush the setState.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      // Peek should be active — end-pane action target is visible.
      expect(find.byKey(const ValueKey('ld-slide-target-Archive-0')), findsOneWidget);

      // Advance through the 1500 ms peek-open window then let the spring settle.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Row should have snapped back to rest.
      expect(find.byKey(const ValueKey('ld-slide-target-Archive-0')), findsNothing);
    });

    testWidgets('only first item in group peeks', (tester) async {
      Widget trackedItem(String title) {
        return LdSlidableListItem(
          endActionPane: LdSlideActionPane(
            actions: [
              LdSlideAction(
                icon: LucideIcons.archive,
                label: 'Archive',
                onTriggered: (_) {},
              ),
            ],
          ),
          child: LdListItem(title: Text(title)),
        );
      }

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 300,
            child: LdSlidableGroup(
              child: Column(
                children: [
                  trackedItem('First'),
                  trackedItem('Second'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Advance past the 1500 ms peek delay then flush setState.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      // Only 'First' should have an action target visible.
      expect(actionTarget('First', 'Archive', 0), findsOneWidget);
      expect(actionTarget('Second', 'Archive', 0), findsNothing);

      // Let animation settle.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(actionTarget('First', 'Archive', 0), findsNothing);
      expect(actionTarget('Second', 'Archive', 0), findsNothing);
    });

    testWidgets('peek is suppressed when initialPeek is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          LdSlidableListItem(
            initialPeek: false,
            endActionPane: LdSlideActionPane(
              actions: [
                LdSlideAction(
                  icon: LucideIcons.archive,
                  label: 'Archive',
                  onTriggered: (_) {},
                ),
              ],
            ),
            child: LdListItem(title: const Text('Item')),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 300));

      // No action targets should ever appear.
      expect(find.byKey(const ValueKey('ld-slide-target-Archive-0')), findsNothing);
    });
  });
}
