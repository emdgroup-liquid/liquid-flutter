import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart'; // Adjust if needed

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

      return LdThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: LdSelectableList<_SampleStringItem, String>(
              itemBuilder: (context, item, index) {
                return LdListItem(
                  title: Text(item.value?.value ?? ''),
                );
              },
              listBuilder: listBuilder,
              paginator: paginator,
              multiSelect: multiSelect,
              onSelectionChange: (s) {
                selected = Set.from(s);
              },
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

      await tester.tap(find.text("A"));
      await tester.pumpAndSettle();

      expect(selected.contains('A'), isTrue);
    });

    testWidgets('selects multiple items with drag rectangle', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final first = tester.getCenter(find.text('A'));

      final last = tester.getCenter(find.text('C'));

      // Start drag gesture (simulate drag rectangle)
      await tester.dragFrom(
        first,
        Offset(last.dx - first.dx + 10, last.dy - first.dy),
        kind: PointerDeviceKind.mouse,
        touchSlopX: 2,
        touchSlopY: 2,
      );

      await tester.pumpAndSettle();

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
  });
}
