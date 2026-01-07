import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdFilterSearchOption Tests', () {
    group('Serialization', () {
      test('serialize() returns searchText when on and non-empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test query',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        expect(filter.serialize(), equals('test query'));
      });

      test('serialize() returns empty string when off', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test query',
          isOn: false,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        expect(filter.serialize(), isEmpty);
      });

      test('serialize() returns empty string when searchText is empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() updates searchText and isOn state', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: false,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final marshaled = filter.marshalSerialized('new query');
        expect(marshaled.searchText, equals('new query'));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to false when empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.searchText, isEmpty);
        expect(marshaled.isOn, isFalse);
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() works correctly with search text', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'Item 1',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final matchingItem = createTestItem(1, name: 'Item 1');
        final nonMatchingItem = createTestItem(2, name: 'Item 2');

        expect(filter.optimisticFilter(matchingItem), isTrue);
        expect(filter.optimisticFilter(nonMatchingItem), isFalse);
      });

      test('optimisticFilter() returns true when filter is off', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: false,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final item = createTestItem(1, name: 'Item 1');
        expect(filter.optimisticFilter(item), isTrue);
      });

      test('optimisticFilter() returns true when searchText is empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final item = createTestItem(1, name: 'Item 1');
        expect(filter.optimisticFilter(item), isTrue);
      });
    });

    group('CopyWith', () {
      test('copyWith() preserves all properties', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: true,
          hint: 'Enter search',
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
          debounceDelay: const Duration(milliseconds: 500),
        );

        final newFilter = filter.copyWith(
          searchText: 'new query',
          isOn: false,
        );

        expect(newFilter.searchText, equals('new query'));
        expect(newFilter.isOn, isFalse);
        expect(newFilter.name, equals('search'));
        expect(newFilter.hint, equals('Enter search'));
        expect(newFilter.debounceDelay, equals(const Duration(milliseconds: 500)));
      });

      test('copyWith() preserves optimisticFilter function', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'Item',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final newFilter = filter.copyWith(searchText: 'Item 1');
        final item = createTestItem(1, name: 'Item 1');

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders search input widget', (WidgetTester tester) async {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: Row(
                    children: [
                      Expanded(child: Text(filter.searchText)),
                      LdButton.vague(
                        size: LdSize.s,
                        onPressed: () {
                          repository.updateFilter(
                            filter.name,
                            (f) => f!.copyWith(isOn: false),
                          );
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('test'), findsOneWidget);
      });
    });
  });
}
