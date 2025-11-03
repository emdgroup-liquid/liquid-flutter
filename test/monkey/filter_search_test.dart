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
  final bool active;

  _TestItem(this.id, this.name, this.value, [bool? active]) : active = active ?? true;

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, active: $active)';
}

void main() {
  group('LdFilterSearchOption Tests', () {
    group('Serialization', () {
      test('serialize() returns searchText when on and non-empty', () {
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'Item 1',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final matchingItem = _TestItem(1, 'Item 1', 10);
        final nonMatchingItem = _TestItem(2, 'Item 2', 20);

        expect(filter.optimisticFilter(matchingItem), isTrue);
        expect(filter.optimisticFilter(nonMatchingItem), isFalse);
      });

      test('optimisticFilter() returns true when filter is off', () {
        final filter = LdFilterSearchOption<_TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: false,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final item = _TestItem(1, 'Item 1', 10);
        expect(filter.optimisticFilter(item), isTrue);
      });

      test('optimisticFilter() returns true when searchText is empty', () {
        final filter = LdFilterSearchOption<_TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final item = _TestItem(1, 'Item 1', 10);
        expect(filter.optimisticFilter(item), isTrue);
      });
    });

    group('CopyWith', () {
      test('copyWith() preserves all properties', () {
        final filter = LdFilterSearchOption<_TestItem, int, String>(
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
        final filter = LdFilterSearchOption<_TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'Item',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
        );

        final newFilter = filter.copyWith(searchText: 'Item 1');
        final item = _TestItem(1, 'Item 1', 10);

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders search input widget', (WidgetTester tester) async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
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

        final filter = LdFilterSearchOption<_TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test',
          isOn: true,
          optimisticFilter: (item, searchText) => item.name.contains(searchText),
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
                      return Row(
                        children: [
                          Expanded(child: Text(filter.searchText)),
                          LdButton.vague(
                            child: const Icon(Icons.close),
                            size: LdSize.s,
                            onPressed: () {},
                          ),
                        ],
                      ).padM();
                    },
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
