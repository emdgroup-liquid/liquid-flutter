import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'utils.dart';

class _SampleStringItem with Identifiable<String> {
  final String value;
  _SampleStringItem(this.value);

  @override
  get id => value;
}

void main() {
  group('LdSelectableList', () {
    late Set<String> selected;
    final items = [_SampleStringItem('A'), _SampleStringItem('B'), _SampleStringItem('C'), _SampleStringItem('D')];

    Widget buildTestWidget({
      bool multiSelect = false,
      bool disableDragGestures = false,
    }) {
      final paginator = LdPaginator<_SampleStringItem, String>.fromList(items);

      final theme = LdTheme();
      theme.platform = LdPlatform.macos;
      return LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          localizationsDelegates: const [
            LiquidLocalizations.delegate,
          ],
          home: Scaffold(
            body: LdListConfigProvider<_SampleStringItem, String>(
              config: LdListConfig<_SampleStringItem, String>(
                paginator: paginator,
                itemBuilder: (context, item, index) {
                  return LdListItem(
                    title: Text(item.value.value),
                  );
                },
              ),
              child: LdSelectableList<_SampleStringItem, String>(
                paginator: paginator,
                multiSelect: multiSelect,
                disableDragGestures: disableDragGestures,
                onSelectionChange: (s) {
                  printOnFailure("onSelectionChange: $s");
                  selected = Set.from(s);
                },
                child: LdList<_SampleStringItem, String>(),
              ),
            ),
          ),
        ),
      );
    }

    setUp(() {
      selected = {};
      _ParentSyncedSelectableList.lastReportedSelection = {};
    });

    testWidgets('selects an item on tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text("A"));
      await tester.pumpAndSettle();

      expect(selected.contains('A'), isTrue);
    });

    testWidgets('selects multiple items with drag rectangle', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();

      final first = find.text('A');
      final firstCenter = tester.getCenter(first);
      final last = find.text('C');
      final lastCenter = tester.getCenter(last);

      printOnFailure("first: $first");
      printOnFailure("last: $last");

      // Perform pan gesture from A to C
      await performPanGesture(
        tester,
        startPosition: firstCenter,
        endPosition: lastCenter + const Offset(10, 0),
      );

      // Should select A, B, C
      expect(selected.containsAll(['A', 'B', 'C']), isTrue);
    });

    testWidgets('does not marquee-select when disableDragGestures is true', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true, disableDragGestures: true));
      await tester.pumpAndSettle();

      final firstCenter = tester.getCenter(find.text('A'));
      final lastCenter = tester.getCenter(find.text('C'));

      await performPanGesture(
        tester,
        startPosition: firstCenter,
        endPosition: lastCenter + const Offset(10, 0),
      );

      expect(selected, isEmpty);
    });

    testWidgets('selects range with shift+click', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();
      // Tap first item
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Hold shift and tap last item
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      // Should select A, B, C
      expect(selected.containsAll(['A', 'B', 'C']), isTrue);
    });

    testWidgets('toggles selection with ctrl+click', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Hold ctrl and tap second item
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      // Should select A and B
      expect(selected.containsAll(['A', 'B']), isTrue);

      // Hold ctrl and tap A again to deselect
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      // Should only have B selected
      expect(selected.contains('B'), isTrue);
      expect(selected.contains('A'), isFalse);
    });

    testWidgets('parent selection sync does not notify onSelectionChange', (tester) async {
      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: const Scaffold(
              body: _ParentSyncedSelectableList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_ParentSyncedSelectableList.lastReportedSelection, isEmpty);

      await tester.tap(find.text('Clear parent'));
      await tester.pump();

      expect(_ParentSyncedSelectableList.lastReportedSelection, isEmpty);
    });

    testWidgets('keeps scroll position when parent echoes selection change', (tester) async {
      const itemHeight = 56.0;
      final items = List.generate(50, (index) => _SampleStringItem('item-$index'));
      final paginator = LdPaginator<_SampleStringItem, String>.fromList(items);

      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: Scaffold(
              body: _ScrollParentSyncedSelectableList(paginator: paginator),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
      final controller = scrollable.controller!;
      controller.jumpTo(itemHeight * 20);
      await tester.pumpAndSettle();

      final scrollOffsetBefore = controller.offset;
      expect(scrollOffsetBefore, greaterThan(itemHeight * 10));

      await tester.tap(find.text('item-25'));
      await tester.pumpAndSettle();

      expect(_ScrollParentSyncedSelectableList.lastReportedSelection, {'item-25'});
      expect(controller.offset, closeTo(scrollOffsetBefore, 1.0));
    });

    testWidgets('auto-scrolls while dragging selection rect to viewport edge', (tester) async {
      const itemHeight = 56.0;
      final scrollableItems = List.generate(50, (index) => _SampleStringItem('item-$index'));
      final paginator = LdPaginator<_SampleStringItem, String>.fromList(scrollableItems);

      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: LdListConfigProvider<_SampleStringItem, String>(
                  config: LdListConfig<_SampleStringItem, String>(
                    paginator: paginator,
                    itemBuilder: (context, item, index) {
                      return SizedBox(
                        height: itemHeight,
                        child: LdListItem(title: Text(item.value.value)),
                      );
                    },
                  ),
                  child: LdSelectableList<_SampleStringItem, String>(
                    paginator: paginator,
                    multiSelect: true,
                    onSelectionChange: (selection) {
                      selected = Set.from(selection);
                    },
                    child: LdList<_SampleStringItem, String>(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final start = tester.getCenter(find.text('item-0'));
      final scrollableFinder = find.descendant(
        of: find.byType(LdSelectableList<_SampleStringItem, String>),
        matching: find.byType(Scrollable),
      );
      final scrollableRect = tester.getRect(scrollableFinder);
      final controller = tester.widget<Scrollable>(scrollableFinder).controller!;
      final bottomEdge = Offset(scrollableRect.center.dx, scrollableRect.bottom + 5);

      final gesture = await tester.startGesture(start, kind: PointerDeviceKind.mouse);
      await tester.pump();

      const steps = 20;
      for (var i = 1; i <= steps; i++) {
        final position = Offset.lerp(start, bottomEdge, i / steps)!;
        await gesture.moveTo(position);
        await tester.pump(const Duration(milliseconds: 50));
      }

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(controller.offset, greaterThan(0));

      await gesture.up();
      await tester.pumpAndSettle();

      final selectedIndices = selected.map((id) => int.parse(id.replaceFirst('item-', ''))).toList();
      expect(selected.contains('item-0'), isTrue);
      expect(selectedIndices.any((index) => index > 7), isTrue);
    });
  });
}

class _ScrollParentSyncedSelectableList extends StatefulWidget {
  const _ScrollParentSyncedSelectableList({required this.paginator});

  final LdPaginator<_SampleStringItem, String> paginator;

  static Set<String> lastReportedSelection = {};

  @override
  State<_ScrollParentSyncedSelectableList> createState() => _ScrollParentSyncedSelectableListState();
}

class _ScrollParentSyncedSelectableListState extends State<_ScrollParentSyncedSelectableList> {
  static const _initialSelection = {'item-0'};

  @override
  Widget build(BuildContext context) {
    return LdListConfigProvider<_SampleStringItem, String>(
      config: LdListConfig<_SampleStringItem, String>(
        paginator: widget.paginator,
        itemBuilder: (context, item, index) {
          return SizedBox(
            height: 56,
            child: LdListItem(title: Text(item.value.value)),
          );
        },
      ),
      child: LdSelectableList<_SampleStringItem, String>(
        paginator: widget.paginator,
        initialSelectedItems: _initialSelection,
        showSelectionControls: true,
        onSelectionChange: (selection) {
          _ScrollParentSyncedSelectableList.lastReportedSelection = Set.from(selection);
        },
        child: LdList<_SampleStringItem, String>(),
      ),
    );
  }
}

class _ParentSyncedSelectableList extends StatefulWidget {
  const _ParentSyncedSelectableList();

  static Set<String> lastReportedSelection = {};

  @override
  State<_ParentSyncedSelectableList> createState() => _ParentSyncedSelectableListState();
}

class _ParentSyncedSelectableListState extends State<_ParentSyncedSelectableList> {
  Set<String> _externalSelection = {'A'};
  late final LdPaginator<_SampleStringItem, String> _paginator;

  @override
  void initState() {
    super.initState();
    _paginator = LdPaginator<_SampleStringItem, String>.fromList([
      _SampleStringItem('A'),
      _SampleStringItem('B'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LdButton(
          onPressed: () => setState(() => _externalSelection = {}),
          child: const Text('Clear parent'),
        ),
        Expanded(
          child: LdListConfigProvider<_SampleStringItem, String>(
            config: LdListConfig<_SampleStringItem, String>(
              paginator: _paginator,
              itemBuilder: (context, item, index) {
                return LdListItem(title: Text(item.value.value));
              },
            ),
            child: LdSelectableList<_SampleStringItem, String>(
              paginator: _paginator,
              initialSelectedItems: _externalSelection,
              multiSelect: true,
              onSelectionChange: (selection) {
                _ParentSyncedSelectableList.lastReportedSelection = Set.from(selection);
              },
              child: LdList<_SampleStringItem, String>(),
            ),
          ),
        ),
      ],
    );
  }
}
