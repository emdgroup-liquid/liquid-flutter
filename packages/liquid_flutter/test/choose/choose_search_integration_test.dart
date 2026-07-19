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
  testWidgets('ephemeral search filters greedy repository list', (tester) async {
    final items = [
      _SearchItem(1, 'Apple pie'),
      _SearchItem(2, 'Banana bread'),
    ];
    final repository = LdListController(
      LdCallbackModel.greedy<_SearchItem, int, _SearchItem, _SearchItem>(
        pageSize: 10,
        getById: (context, id) async => items.firstWhere((item) => item.id == id),
        fetchListWithParameters: (parameters) async {
          var filtered = items.toList();
          if (parameters.filters.isNotEmpty) {
            filtered = ldFuzzySearchFromFilters<_SearchItem, int>(
              items: filtered,
              filters: parameters.filters,
              searchText: (item) => item.label,
            );
          }
          return LdListPage<_SearchItem>(
            newItems: filtered,
            hasMore: false,
            total: filtered.length,
          );
        },
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
