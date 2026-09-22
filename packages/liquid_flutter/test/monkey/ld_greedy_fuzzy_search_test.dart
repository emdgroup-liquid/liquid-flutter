import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class _SearchItem with Identifiable<int> {
  _SearchItem(this.id, this.label);

  @override
  final int id;
  final String label;
}

void main() {
  group('ldFuzzySearchItems', () {
    final items = [
      _SearchItem(1, 'Strawberry pie'),
      _SearchItem(2, 'Apple pie'),
      _SearchItem(3, 'Banana bread'),
    ];

    test('returns all items for empty query', () {
      expect(
        ldFuzzySearchItems(
          items: items,
          query: '',
          searchText: (item) => item.label,
        ),
        items,
      );
    });

    test('matches typos fuzzily', () {
      final result = ldFuzzySearchItems(
        items: items,
        query: 'strawbery',
        searchText: (item) => item.label,
      );
      expect(result.map((e) => e.id), [1]);
    });
  });

  group('ldFuzzySearchFromFilters', () {
    final items = [
      _SearchItem(1, 'Strawberry pie'),
      _SearchItem(2, 'Apple pie'),
    ];

    test('returns all items when search filter is off', () {
      final filters = <LdFilterOption<_SearchItem, int>>{
        LdFilterSearch<_SearchItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
        ),
      };

      expect(
        ldFuzzySearchFromFilters(
          items: items,
          filters: filters,
          searchText: (item) => item.label,
        ),
        items,
      );
    });

    test('filters when search filter is active', () {
      final filters = <LdFilterOption<_SearchItem, int>>{
        LdFilterSearch<_SearchItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'apple',
          isOn: true,
        ),
      };

      final result = ldFuzzySearchFromFilters(
        items: items,
        filters: filters,
        searchText: (item) => item.label,
      );
      expect(result.map((e) => e.id), [2]);
    });
  });

  testWidgets('LdCallbackModel.fromList searchText applies fuzzy search from search filter', (tester) async {
    final items = [
      _SearchItem(1, 'Apple pie'),
      _SearchItem(2, 'Banana bread'),
    ];
    final repository = LdListController.fromModel(
      LdCallbackModel.fromList<_SearchItem, int>(
        list: items,
        searchText: (item) => item.label,
      ),
    );

    final controller = LdEphemeralMonkeyController<_SearchItem, int>(
      filters: {
        LdFilterSearch<_SearchItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
        ),
      },
    );

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: ListenableProvider<LdListController<_SearchItem, int>>.value(
            value: repository,
            child: LdEphemeralMonkeyAdapter<_SearchItem, int>(
              controller: controller,
              child: Builder(
                builder: (context) {
                  return LdListConfigProvider<_SearchItem, int>(
                    config: LdListConfig<_SearchItem, int>(
                      paginator: repository,
                      itemBuilder: (context, item, index) {
                        return LdListItem(title: Text(item.value.label));
                      },
                    ),
                    child: LdSelectableList<_SearchItem, int>(
                      listController: repository,
                      showSelectionControls: true,
                      child: LdList<_SearchItem, int>(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apple pie'), findsOneWidget);
    expect(find.text('Banana bread'), findsOneWidget);

    final filter = controller.filters.first as LdFilterSearch<_SearchItem, int, String>;
    controller.updateFilter(filter.copyWith(searchText: 'Apple', isOn: true));
    await tester.pumpAndSettle();

    expect(find.text('Apple pie'), findsOneWidget);
    expect(find.text('Banana bread'), findsNothing);
  });
}
