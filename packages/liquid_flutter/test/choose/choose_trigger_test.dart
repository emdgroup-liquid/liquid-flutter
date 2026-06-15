import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('trigger shows selected items from value', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              value: {'a'},
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
              ],
              onChanged: (_) {},
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apple pie'), findsOneWidget);
    expect(find.text('Choose a pie'), findsNothing);
  });

  testWidgets('trigger updates after picker confirms selection', (tester) async {
    Set<String>? value;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LdChoose.fromSelectItems<String>(
                  label: 'Pie',
                  placeholder: const Text('Choose a pie'),
                  value: value,
                  items: const [
                    LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
                    LdSelectItem(value: 'b', child: Text('Banana bread'), searchString: 'Banana bread'),
                  ],
                  onChanged: (next) => setState(() => value = next),
                  searchText: (item) => item.searchString ?? '',
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a pie'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Banana bread'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_done')));
    await tester.pumpAndSettle();

    expect(find.text('Banana bread'), findsOneWidget);
    expect(find.text('Choose a pie'), findsNothing);
  });
}
