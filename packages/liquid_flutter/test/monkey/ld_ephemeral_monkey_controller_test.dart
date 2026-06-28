import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdEphemeralMonkeyController', () {
    test('updateFilter replaces filter by name', () {
      final filter = LdFilterSearch<TestItem, int, String>(
        name: 'search',
        label: (context) => 'Search',
        icon: (context) => const Icon(Icons.search),
      );
      final controller = LdEphemeralMonkeyController<TestItem, int>(
        filters: {filter},
      );

      controller.updateFilter(
        filter.copyWith(searchText: 'query', isOn: true),
      );

      final updated = controller.filters.first as LdFilterSearch<TestItem, int, String>;
      expect(updated.searchText, 'query');
      expect(updated.isOn, isTrue);
    });

    testWidgets('repository refreshes on filter update', (tester) async {
      final items = [createTestItem(1, name: 'Alpha'), createTestItem(2, name: 'Beta')];
      var fetchCount = 0;
      final repository = LdListController.fromModel(
        LdCallbackModel<TestItem, int>(
          fetchListWithParameters: (parameters) async {
            fetchCount++;
            return LdListPage<TestItem>(
              newItems: items,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ),
      );

      final controller = LdEphemeralMonkeyController<TestItem, int>(
        filters: {
          LdFilterSearch<TestItem, int, String>(
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
            home: ListenableProvider<LdListController<TestItem, int>>.value(
              value: repository,
              child: LdEphemeralMonkeyAdapter<TestItem, int>(
                controller: controller,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final initialFetchCount = fetchCount;
      final filter = controller.filters.first as LdFilterSearch<TestItem, int, String>;
      controller.updateFilter(
        filter.copyWith(searchText: 'alpha', isOn: true),
      );
      await tester.pumpAndSettle();

      expect(fetchCount, greaterThan(initialFetchCount));
    });
  });
}
