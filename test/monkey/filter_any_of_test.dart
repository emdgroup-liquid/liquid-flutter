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

    // Helper to create test items with category
    TestItem createTestItemWithCategory(int id, String category) {
      return TestItem(id, 'Item $id', id * 10, true, category);
    }

    group('Serialization', () {
      test('serialize() returns comma-separated selected values', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA, _Category.categoryB},
          isOn: true,
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
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
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
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
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() parses multiple values', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
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
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
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
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
        );

        final marshaled = filter.marshalSerialized('invalid,_Category.categoryB');
        expect(marshaled.selectedValues, contains(_Category.categoryB));
        expect(marshaled.selectedValues.length, equals(1));
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() uses selected values set', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA, _Category.categoryB},
          isOn: true,
          optimisticFilter: (item, selected) {
            return selected.contains(_Category.categoryA) && item.category == 'A' ||
                selected.contains(_Category.categoryB) && item.category == 'B';
          },
        );

        final matchingItemA = createTestItemWithCategory(1, 'A');
        final matchingItemB = createTestItemWithCategory(2, 'B');
        final nonMatchingItem = createTestItemWithCategory(3, 'C');

        expect(filter.optimisticFilter(matchingItemA), isTrue);
        expect(filter.optimisticFilter(matchingItemB), isTrue);
        expect(filter.optimisticFilter(nonMatchingItem), isFalse);
      });

      test('optimisticFilter() returns false when selectedValues is empty', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {},
          isOn: true,
          optimisticFilter: (item, selected) => selected.isNotEmpty && selected.contains(_Category.categoryA),
        );

        final item = createTestItemWithCategory(1, 'A');
        expect(filter.optimisticFilter(item), isFalse);
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
          optimisticFilter: (item, selected) => selected.contains(_Category.categoryA),
        );

        final newFilter = filter.copyWith(
          selectedValues: {_Category.categoryB, _Category.categoryC},
          isOn: true,
        );

        expect(newFilter.selectedValues, equals({_Category.categoryB, _Category.categoryC}));
        expect(newFilter.isOn, isTrue);
        expect(filter.selectedValues, equals({_Category.categoryA}));
      });

      test('copyWith() preserves optimisticFilter function', () {
        final filter = LdFilterAnyOf<TestItem, int, _Category>(
          name: 'categories',
          label: (context) => 'Categories',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: {_Category.categoryA},
          isOn: true,
          optimisticFilter: (item, selected) => selected.contains(_Category.categoryA) && item.category == 'A',
        );

        final newFilter = filter.copyWith(selectedValues: {_Category.categoryA});
        final item = createTestItemWithCategory(1, 'A');

        expect(newFilter.optimisticFilter(item), isTrue);
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
          optimisticFilter: (item, selected) => selected.any((cat) => item.category.contains(cat.toString())),
        );

        final repository = createTestRepository(
          filters: {filter},
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: const LdFilterModal<TestItem, int>(),
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

        expect(repository.filters['categories']!.isOn, isFalse);

        expect(categoriesFilterButton, findsOneWidget);
        await tester.tap(categoriesFilterButton);
        await tester.pumpAndSettle();

        // Check if the filter is now active in the repository's filters
        expect(repository.filters['categories']!.isOn, isTrue);

        // Find the LdChoose widget and interact with it
        // LdChoose shows a button that opens a modal/page with selectable items
        // Find the LdTouchableSurface that triggers the choose menu
        await openChooseMenu(tester);

        // Now find and tap Category A in the modal
        final categoryAItem = find.widgetWithText(LdListItem, 'Category A');
        expect(categoryAItem, findsOneWidget);

        await tester.tap(categoryAItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        // Verify Category A is selected
        final updatedFilter = repository.filters['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter.selectedValues, contains(_Category.categoryA));
        expect(updatedFilter.isOn, isTrue);

        //await debugCaptureImage(tester, 'filter_any_of_test_3');
        // Open the choose menu again to select Category B
        await openChooseMenu(tester);
        await tester.pumpAndSettle();

        final categoryBItem = find.widgetWithText(LdListItem, 'Category B');
        expect(categoryBItem, findsOneWidget);
        await tester.tap(categoryBItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        // Verify both categories are selected
        final updatedFilter2 = repository.filters['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter2.selectedValues, contains(_Category.categoryA));
        expect(updatedFilter2.selectedValues, contains(_Category.categoryB));
        expect(updatedFilter2.isOn, isTrue);

        // Deselect Category A by tapping it again
        await openChooseMenu(tester);
        await tester.pumpAndSettle();

        await tester.tap(categoryAItem);
        await tester.pumpAndSettle();

        await doneChooseMenu(tester);

        // Verify only Category B is selected
        final updatedFilter3 = repository.filters['categories'] as LdFilterAnyOf<TestItem, int, _Category>;
        expect(updatedFilter3.selectedValues, isNot(contains(_Category.categoryA)));
        expect(updatedFilter3.selectedValues, contains(_Category.categoryB));
        expect(updatedFilter3.isOn, isTrue);

        // Find and tap the X button to deactivate
        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        // Check if the filter is now inactive in the repository's filters
        expect(repository.filters['categories']!.isOn, isFalse);
      });
    });
  });
}
