import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('search shows typeahead suggestions while typing', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
                LdSelectItem(value: 'b', child: Text('Banana bread'), searchString: 'Banana bread'),
              ],
              onChanged: (_) {},
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Ban');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Apple pie'), findsOneWidget);
    expect(find.text('Banana bread'), findsAtLeastNWidgets(2));
  });

  testWidgets('submitting search filters the list', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
                LdSelectItem(value: 'b', child: Text('Banana bread'), searchString: 'Banana bread'),
              ],
              onChanged: (_) {},
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Banana');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    final list = find.byType(LdSelectableList<LdSelectItem<String>, String>);
    expect(
      find.descendant(of: list, matching: find.text('Apple pie')),
      findsNothing,
    );
    expect(
      find.descendant(of: list, matching: find.text('Banana bread')),
      findsOneWidget,
    );
  });
}
