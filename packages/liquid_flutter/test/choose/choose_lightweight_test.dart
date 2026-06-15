import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdChoose.fromSelectItems opens picker with search field', (tester) async {
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

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Apple pie'), findsOneWidget);
    expect(find.text('Banana bread'), findsOneWidget);
  });
}
