import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

enum _Category { categoryA, categoryB, categoryC }

void main() {
  group('LdFilterAnyOf Tests', () {
    final allValues = {
      _Category.categoryA: (BuildContext context) => const Text('Category A'),
      _Category.categoryB: (BuildContext context) => const Text('Category B'),
      _Category.categoryC: (BuildContext context) => const Text('Category C'),
    };

    group('Serialization', () {
      test('serialize() returns comma-separated selected values', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA, _Category.categoryB},
          isOn: true,
        );

        final serialized = filter.serialize();
        expect(serialized, contains('_Category.categoryA'));
        expect(serialized, contains('_Category.categoryB'));
        expect(serialized.split(',').length, equals(2));
      });

      test('serialize() returns empty string when no selection', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {},
          isOn: true,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('serialize() returns empty string when filter is off', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA},
          isOn: false,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() parses multiple values', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
        );

        final marshaled = filter.marshalSerialized('_Category.categoryA,_Category.categoryB');
        expect(marshaled.selectedValues, contains(_Category.categoryA));
        expect(marshaled.selectedValues, contains(_Category.categoryB));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() handles empty string', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA},
          isOn: true,
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.selectedValues, isEmpty);
        expect(marshaled.isOn, isFalse);
      });

      test('marshalSerialized() handles invalid values', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA},
          isOn: true,
        );

        final marshaled = filter.marshalSerialized('invalid,_Category.categoryB');
        expect(marshaled.selectedValues, contains(_Category.categoryB));
        expect(marshaled.selectedValues.length, equals(1));
      });
    });

    group('CopyWith', () {
      test('copyWith() updates selectedValues correctly', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA},
        );

        final newFilter = filter.copyWith(
          selectedValues: {_Category.categoryB, _Category.categoryC},
          isOn: true,
        );

        expect(newFilter.selectedValues, equals({_Category.categoryB, _Category.categoryC}));
        expect(newFilter.isOn, isTrue);
        expect(filter.selectedValues, equals({_Category.categoryA}));
      });
    });

    group('UI Rendering', () {
      testWidgets('renders in LdFilterModal and can be activated/deactivated and interacted with',
          (WidgetTester tester) async {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {},
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider<LdRepository<TestItem, int>>.value(
                  value: repository,
                  child: ListenableProvider<TestSortAndFilterState<TestItem, int>>.value(
                    value: shellState,
                    child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                      value: shellState.controllerDelegate,
                      child: Builder(
                        builder: (context) {
                          context.watch<TestSortAndFilterState<TestItem, int>>();
                          return Provider<LdMonkeySortAndFilterState<TestItem, int>>.value(
                            value: shellState.state,
                            child: const LdFilterModal<TestItem, int>(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        Future<void> openChooseMenu(WidgetTester tester) async {
          final chooseButton = find.byKey(const Key("ldChoose_trigger"));
          expect(chooseButton, findsOneWidget);
          await tester.tap(chooseButton);
          await tester.pumpAndSettle();
        }

        Future<void> doneChooseMenu(WidgetTester tester) async {
          final doneButton = find.byKey(const Key("ldChoose_done"));
          expect(doneButton, findsOneWidget);
          await tester.tap(doneButton);
          await tester.pumpAndSettle();
        }

        final categoriesFilterButton = find.widgetWithText(LdButton, 'Categories');

        expect(shellState.filtersMap['categories']!.isOn, isFalse);
        expect(categoriesFilterButton, findsOneWidget);

        await tester.tap(categoriesFilterButton);
        await tester.pumpAndSettle();

        expect(shellState.filtersMap['categories']!.isOn, isTrue);

        await openChooseMenu(tester);

        final categoryAItem = find.widgetWithText(LdListItem, 'Category A');
        expect(categoryAItem, findsOneWidget);

        await tester.tap(categoryAItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        final updatedFilter = shellState.filtersMap['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter.selectedValues, contains(_Category.categoryA));
        expect(updatedFilter.isOn, isTrue);

        await openChooseMenu(tester);
        await tester.pumpAndSettle();

        final categoryBItem = find.widgetWithText(LdListItem, 'Category B');
        expect(categoryBItem, findsOneWidget);

        await tester.tap(categoryBItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        final updatedFilter2 = shellState.filtersMap['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter2.selectedValues, contains(_Category.categoryA));
        expect(updatedFilter2.selectedValues, contains(_Category.categoryB));
        expect(updatedFilter2.isOn, isTrue);

        // Deselect Category A by tapping it again
        await openChooseMenu(tester);
        await tester.pumpAndSettle();

        await tester.tap(categoryAItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        final updatedFilter3 = shellState.filtersMap['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter3.selectedValues, isNot(contains(_Category.categoryA)));
        expect(updatedFilter3.selectedValues, contains(_Category.categoryB));
        expect(updatedFilter3.isOn, isTrue);

        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        expect(shellState.filtersMap['categories']!.isOn, isFalse);
      });
    });
  });
}
