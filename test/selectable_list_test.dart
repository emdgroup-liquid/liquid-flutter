import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart'; // Adjust if needed

void main() {
  group('LdSelectableList', () {
    late Set<String> selected;
    final items = ['A', 'B', 'C', 'D'];

    Widget buildTestWidget({bool multiSelect = false}) {
      final paginator = LdPaginator.fromList(items);

      Widget itemBuilder({
        required BuildContext context,
        required String item,
        required int index,
        required bool selected,
        required bool isMultiSelect,
        required void Function(bool selected) onSelectionChange,
        required VoidCallback onTap,
      }) {
        return ListTile(
          key: ValueKey(item),
          title: Text(item),
          selected: selected,
          onTap: onTap,
        );
      }

      LdList<String, void> listBuilder(
        BuildContext context,
        ScrollController controller,
        LdListItemBuilder<String> itemBuilder,
      ) {
        return LdList<String, void>(
          paginator: paginator,
          itemBuilder: itemBuilder,
        );
      }

      return LdThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: LdSelectableList<String, void>(
              itemBuilder: itemBuilder,
              listBuilder: listBuilder,
              paginator: paginator,
              multiSelect: multiSelect,
              onSelectionChange: (s) => selected = Set.from(s),
            ),
          ),
        ),
      );
    }

    setUp(() {
      selected = {};
    });

    testWidgets('selects an item on tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('A')));
      await tester.pumpAndSettle();
      expect(selected.contains('A'), isTrue);
    });

    testWidgets('selects multiple items with drag rectangle',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();
      // Find the position of the first and last item
      final first = tester.getCenter(find.byKey(const ValueKey('A')));
      final last = tester.getCenter(find.byKey(const ValueKey('C')));

      // Start drag gesture (simulate drag rectangle)
      await tester.dragFrom(
        first,
        last,
        kind: PointerDeviceKind.mouse,
      );

      await tester.pumpAndSettle();

      // Should select A, B, C
      expect(selected.containsAll(['A', 'B', 'C']), isTrue);
    });

    testWidgets('selects range with shift+click', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();
      // Tap first item
      await tester.tap(find.byKey(const ValueKey('A')));
      await tester.pumpAndSettle();

      // Hold shift and tap last item
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.byKey(const ValueKey('C')));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      // Should select A, B, C
      expect(selected.containsAll(['A', 'B', 'C']), isTrue);
    });

    testWidgets('toggles selection with ctrl+click',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(multiSelect: true));
      await tester.pumpAndSettle();
      // Tap first item
      await tester.tap(find.byKey(const ValueKey('A')));
      await tester.pumpAndSettle();

      // Hold ctrl and tap second item
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.byKey(const ValueKey('B')));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      // Should select A and B
      expect(selected.containsAll(['A', 'B']), isTrue);

      // Hold ctrl and tap A again to deselect
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.byKey(const ValueKey('A')));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      // Should only have B selected
      expect(selected.contains('B'), isTrue);
      expect(selected.contains('A'), isFalse);
    });
  });
}
