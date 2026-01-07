import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

enum _Category { categoryA, categoryB, categoryC }

void main() {
  group('LdFilterOneOf Tests', () {
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
      test('serialize() returns selectedValue.toString() when on', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        expect(filter.serialize(), equals('_Category.categoryA'));
      });

      test('serialize() returns empty string when off', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: false,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        expect(filter.serialize(), isEmpty);
      });

      test('serialize() returns empty string when selectedValue is null', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() parses comma-separated values correctly', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final marshaled = filter.marshalSerialized('_Category.categoryB');
        expect(marshaled.selectedValue, equals(_Category.categoryB));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() handles empty string', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final marshaled = filter.marshalSerialized('');

        expect(marshaled.isOn, isFalse);
      });

      test('marshalSerialized() handles invalid value', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final marshaled = filter.marshalSerialized('invalid');

        expect(marshaled.isOn, isFalse);
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() uses selected value', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final matchingItem = createTestItemWithCategory(1, 'A');
        final nonMatchingItem = createTestItemWithCategory(2, 'B');

        expect(filter.optimisticFilter(matchingItem), isTrue);
        expect(filter.optimisticFilter(nonMatchingItem), isFalse);
      });

      test('optimisticFilter() handles null selectedValue', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          isOn: true,
          optimisticFilter: (item, selected) {
            if (selected == null) return true;
            return selected == _Category.categoryA && item.category == 'A';
          },
        );

        final item = createTestItemWithCategory(1, 'B');
        expect(filter.optimisticFilter(item), isTrue);
      });
    });

    group('CopyWith', () {
      test('copyWith() updates selectedValue correctly', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final newFilter = filter.copyWith(
          selectedValue: _Category.categoryB,
          isOn: true,
        );

        expect(newFilter.selectedValue, equals(_Category.categoryB));
        expect(newFilter.isOn, isTrue);
        expect(filter.selectedValue, equals(_Category.categoryA));
      });

      test('copyWith() preserves optimisticFilter function', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final newFilter = filter.copyWith(selectedValue: _Category.categoryA);
        final item = createTestItemWithCategory(1, 'A');

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders selection widget', (WidgetTester tester) async {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: LdFilterOneOfWidget<TestItem, int, _Category>(
                    filter: filter,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Category'), findsOneWidget);
      });
    });
  });
}
