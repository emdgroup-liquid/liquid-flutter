import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  test('ldChooseCanConfirmSelection requires a change or non-empty selection', () {
    expect(
      ldChooseCanConfirmSelection<String>(current: {}, initial: {}),
      isFalse,
    );
    expect(
      ldChooseCanConfirmSelection<String>(current: {}, initial: {'a'}),
      isTrue,
    );
    expect(
      ldChooseCanConfirmSelection<String>(current: {'a'}, initial: {}),
      isTrue,
    );
    expect(
      ldChooseCanConfirmSelection<String>(current: {'a'}, initial: {'a'}),
      isTrue,
    );
  });

  test('ldChooseCanDismissPicker respects allowEmpty', () {
    expect(
      ldChooseCanDismissPicker<String>(
        current: {},
        initial: {},
        allowEmpty: true,
      ),
      isTrue,
    );
    expect(
      ldChooseCanDismissPicker<String>(
        current: {},
        initial: {},
        allowEmpty: false,
      ),
      isFalse,
    );
    expect(
      ldChooseCanDismissPicker<String>(
        current: {'a'},
        initial: {},
        allowEmpty: false,
      ),
      isTrue,
    );
  });

  testWidgets('allowEmpty does not confirm unchanged empty selection', (tester) async {
    Set<String>? result;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              allowEmpty: true,
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
              ],
              onChanged: (next) => result = next,
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    final doneButton = tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done')));
    expect(doneButton.disabled, isTrue);

    await tester.tap(find.byKey(const Key('ldChoose_done')));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('allowEmpty false keeps Done disabled until selection', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              allowEmpty: false,
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

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    final doneButton = tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done')));
    expect(doneButton.disabled, isTrue);

    await tester.tap(find.text('Apple pie'));
    await tester.pumpAndSettle();

    final enabledDoneButton = tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done')));
    expect(enabledDoneButton.disabled, isFalse);
  });

  testWidgets('multi-select clear does not throw and enables Done', (tester) async {
    Set<String>? result;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              multiple: true,
              allowEmpty: true,
              value: {'a', 'b'},
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
                LdSelectItem(value: 'b', child: Text('Banana bread'), searchString: 'Banana bread'),
              ],
              onChanged: (next) => result = next,
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    final doneButton = tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done')));
    expect(doneButton.disabled, isFalse);

    await tester.tap(find.byKey(const Key('ldChoose_done')));
    await tester.pumpAndSettle();

    expect(result, isEmpty);
  });

  testWidgets('multi-select deselect disables Done when selection matches initial', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              placeholder: const Text('Choose a pie'),
              multiple: true,
              allowEmpty: false,
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

    await tester.tap(find.text('Apple pie'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done'))).disabled,
      isFalse,
    );

    await tester.tap(find.text('Apple pie'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<LdAppBarAction>(find.byKey(const Key('ldChoose_done'))).disabled,
      isTrue,
    );
  });

  testWidgets('required modal picker does not dismiss from backdrop tap', (tester) async {
    Set<String>? result;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Scaffold(
            body: LdChoose.fromSelectItems<String>(
              label: 'Pie',
              mode: LdChooseMode.modal,
              placeholder: const Text('Choose a pie'),
              allowEmpty: false,
              items: const [
                LdSelectItem(value: 'a', child: Text('Apple pie'), searchString: 'Apple pie'),
              ],
              onChanged: (next) => result = next,
              searchText: (item) => item.searchString ?? '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ldChoose_trigger')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ldChoose_done')), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ldChoose_done')), findsOneWidget);
    expect(result, isNull);
  });
}
