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
}
