import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

/// Builds an [LdChoose] backed by a static item list and wired to
/// [LdChooseLinkedListTrigger].
Widget _buildChoose({
  required Set<String> value,
  required void Function(Set<String>) onChanged,
  void Function(BuildContext, LdSelectItem<String>)? onItemPressed,
  bool allowEmpty = true,
  bool multiple = true,
}) {
  final items = [
    const LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
    const LdSelectItem(value: 'b', child: Text('Banana bread'), searchString: 'Banana bread'),
    const LdSelectItem(value: 'c', child: Text('Cherry pie'), searchString: 'Cherry pie'),
  ];

  return LdChoose.fromSelectItems<String>(
    items: items,
    multiple: multiple,
    allowEmpty: allowEmpty,
    label: 'Pies',
    placeholder: const Text('No pies linked'),
    value: value,
    onChanged: onChanged,
    triggerBuilder: (context, config) => LdChooseLinkedListTrigger(
      config: config,
      addLabel: 'Link a pie',
      removeLabel: 'Unlink',
      onItemPressed: onItemPressed,
    ),
  );
}

/// Pump long enough for spring / dismiss animations to complete.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LdChooseLinkedListTrigger', () {
    testWidgets('shows hint and Add row when nothing is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {},
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No pies linked'), findsOneWidget);
      expect(find.text('Link a pie'), findsOneWidget);
      // No item rows rendered.
      expect(find.text('Apple pie'), findsNothing);
    });

    testWidgets('renders selected items as list rows and hides hint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {'a', 'b'},
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apple pie'), findsOneWidget);
      expect(find.text('Banana bread'), findsOneWidget);
      // Hint is hidden when items are selected.
      expect(find.text('No pies linked'), findsNothing);
      // Add row still present.
      expect(find.text('Link a pie'), findsOneWidget);
    });

    testWidgets('onItemPressed is called when a row is tapped', (tester) async {
      LdSelectItem<String>? tappedItem;

      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {'a', 'b'},
            onChanged: (_) {},
            onItemPressed: (_, item) => tappedItem = item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple pie'));
      await tester.pumpAndSettle();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.id, equals('a'));
    });

    testWidgets('chevron trailing icon shown when onItemPressed is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {'a'},
            onChanged: (_) {},
            onItemPressed: (_, __) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);
    });

    testWidgets('no chevron when onItemPressed is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {'a'},
            onChanged: (_) {},
            onItemPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);
    });

    testWidgets('swipe-to-remove calls onRemoveItem via onChanged', (tester) async {
      Set<String> currentValue = {'a', 'b'};

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return _buildChoose(
                value: currentValue,
                allowEmpty: true,
                onChanged: (ids) => setState(() => currentValue = ids),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Full swipe left on Apple pie row to trigger the Unlink action (72 px pane).
      // The default LdSlideActionPane threshold is 1.5×, so the drag must
      // exceed 72 × 1.5 = 108 px for auto-trigger on release.
      await tester.drag(find.text('Apple pie'), const Offset(-150, 0));
      await _settle(tester);

      expect(currentValue.contains('a'), isFalse);
      expect(currentValue.contains('b'), isTrue);
    });

    testWidgets('last-item protection: no swipe action when allowEmpty is false', (tester) async {
      Set<String> currentValue = {'a'};
      var removeCalled = false;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return _buildChoose(
                value: currentValue,
                allowEmpty: false,
                onChanged: (ids) {
                  removeCalled = true;
                  setState(() => currentValue = ids);
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Attempt swipe on the single item — should be a no-op.
      await tester.drag(find.text('Apple pie'), const Offset(-100, 0));
      await _settle(tester);

      // onChanged must NOT have been called — item still present.
      expect(removeCalled, isFalse);
      expect(currentValue, equals({'a'}));
    });

    testWidgets('Add row tap calls config.onTap (opens picker)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildChoose(
            value: {},
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Link a pie'));
      await tester.pumpAndSettle();

      // Picker page/modal should open — verify by finding the Done button.
      expect(find.byKey(const Key('ldChoose_done')), findsOneWidget);
    });
  });
}
