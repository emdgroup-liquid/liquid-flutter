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

    Widget buildTestWidget({bool multiSelect = false}) {
      final paginator = LdPaginator<_SampleStringItem, String>.fromList(items);

      LdList<_SampleStringItem, String> listBuilder(
        BuildContext context,
        ScrollController controller,
        LdListItemBuilder<_SampleStringItem> itemBuilder,
      ) {
        return LdList<_SampleStringItem, String>(
          paginator: paginator,
          itemBuilder: itemBuilder,
        );
      }

      final theme = LdTheme();
      theme.platform = LdPlatform.macos;
      return LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          localizationsDelegates: const [
            LiquidLocalizations.delegate,
          ],
          home: Scaffold(
            body: LdSelectableList<_SampleStringItem, String>(
              itemBuilder: (context, item, index) {
                return LdListItem(
                  title: Text(item.value?.value ?? ''),
                );
              },
              listBuilder: (context, itemBuilder) => listBuilder(context, ScrollController(), itemBuilder),
              paginator: paginator,
              multiSelect: multiSelect,
              onSelectionChange: (s) {
                printOnFailure("onSelectionChange: $s");
                selected = Set.from(s);
              },
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
  });
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
          child: LdSelectableList<_SampleStringItem, String>(
            paginator: _paginator,
            initialSelectedItems: _externalSelection,
            multiSelect: true,
            onSelectionChange: (selection) {
              _ParentSyncedSelectableList.lastReportedSelection = Set.from(selection);
            },
            itemBuilder: (context, item, index) {
              return LdListItem(title: Text(item.value?.value ?? ''));
            },
          ),
        ),
      ],
    );
  }
}
