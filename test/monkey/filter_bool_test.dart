import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// Test item class
class _TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;

  _TestItem(this.id, this.name, this.value, [this.active = true]);

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, active: $active)';
}

void main() {
  group('LdFilterBoolOption Tests', () {
    group('Serialization', () {
      test('serialize() returns "true"', () {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        expect(filter.serialize(), equals('true'));
      });

      test('marshalSerialized() turns filter on', () {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final marshaled = filter.marshalSerialized('true');
        expect(marshaled.isOn, isTrue);
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() calls provided function', () {
        var functionCalled = false;
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) {
            functionCalled = true;
            return item.active;
          },
        );

        final item = _TestItem(1, 'Item 1', 10, true);
        filter.optimisticFilter(item);

        expect(functionCalled, isTrue);
      });

      test('optimisticFilter() returns correct value', () {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final activeItem = _TestItem(1, 'Item 1', 10, true);
        final inactiveItem = _TestItem(2, 'Item 2', 20, false);

        expect(filter.optimisticFilter(activeItem), isTrue);
        expect(filter.optimisticFilter(inactiveItem), isFalse);
      });
    });

    group('CopyWith', () {
      test('copyWith() creates new instance correctly', () {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(isOn: true);

        expect(newFilter.isOn, isTrue);
        expect(filter.isOn, isFalse);
        expect(newFilter.name, equals('active'));
      });

      test('copyWith() preserves optimisticFilter function', () {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(isOn: true);
        final item = _TestItem(1, 'Item 1', 10, true);

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders as LdListItem with toggle', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'boolFilter',
          label: (context) => 'Bool filter',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final repository = LdRepository<_TestItem, int>(
          filters: {filter},
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

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: Builder(
                    builder: (context) {
                      // Access repository to initialize it
                      monkey.initRepository(context, {}, {});
                      return LdFilterModal(
                        route: monkey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final boolFilterButton = find.widgetWithText(LdButton, 'Bool filter');

        expect(repository.filters['boolFilter']!.isOn, isFalse);

        expect(boolFilterButton, findsOneWidget);
        await tester.tap(boolFilterButton);
        await tester.pumpAndSettle();

        // Check if the filter is now active in the repoitory's activeFilters
        expect(repository.filters['boolFilter']!.isOn, isTrue);

        // find an x icon ldbutton
        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        // Check if the filter is now inactive in the repository's filters
        expect(repository.filters['boolFilter']!.isOn, isFalse);
      });
    });
  });
}
