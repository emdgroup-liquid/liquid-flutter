import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// Test item class
class _TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final String category;

  _TestItem(this.id, this.name, this.value, this.category);

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, category: $category)';
}

enum _Category { categoryA, categoryB, categoryC }

void main() {
  group('LdFilterOneOf Tests', () {
    final allValues = {
      _Category.categoryA: (BuildContext context) => const Text('Category A'),
      _Category.categoryB: (BuildContext context) => const Text('Category B'),
      _Category.categoryC: (BuildContext context) => const Text('Category C'),
    };

    group('Serialization', () {
      test('serialize() returns selectedValue.toString() when on', () {
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final matchingItem = _TestItem(1, 'Item 1', 10, 'A');
        final nonMatchingItem = _TestItem(2, 'Item 2', 20, 'B');

        expect(filter.optimisticFilter(matchingItem), isTrue);
        expect(filter.optimisticFilter(nonMatchingItem), isFalse);
      });

      test('optimisticFilter() handles null selectedValue', () {
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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

        final item = _TestItem(1, 'Item 1', 10, 'B');
        expect(filter.optimisticFilter(item), isTrue);
      });
    });

    group('CopyWith', () {
      test('copyWith() updates selectedValue correctly', () {
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
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
        final filter = LdFilterOneOf<_TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        final newFilter = filter.copyWith(selectedValue: _Category.categoryA);
        final item = _TestItem(1, 'Item 1', 10, 'A');

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders selection widget', (WidgetTester tester) async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0, 'A'),
        );

        final monkey = LdMonkey<_TestItem, int>(
          path: '/test',
          parseId: (id) => int.parse(id),
          detailPath: (ids) => '/test/${ids.join(",")}',
          buildRepository: (context) => repository,
          buildDetail: (context, item) => Text(item.value?.name ?? 'Loading'),
          listBuilder: (route, state, onSelectionChanged) => LdSelectableList<_TestItem, int>(
            paginator: route.repository,
            itemBuilder: (context, item, index) => LdListItem(
              title: Text(item.value?.name ?? ''),
            ),
            onSelectionChange: onSelectionChanged,
          ),
        );

        final filter = LdFilterOneOf<_TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          optimisticFilter: (item, selected) => selected == _Category.categoryA && item.category == 'A',
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: Builder(
                    builder: (context) {
                      monkey.initRepository(context, {}, {});
                      return LdFilterOneOfWidget(
                        filter: filter,
                      );
                    },
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
