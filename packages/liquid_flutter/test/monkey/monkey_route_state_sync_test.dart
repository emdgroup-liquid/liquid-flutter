import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_sync.dart';

import 'test_utils.dart';

void main() {
  group('ldMonkeySeedDefinitionDefaults', () {
    late LdMonkeyRouteConfig<TestItem, int> routeConfig;

    setUp(() {
      routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'task');
    });

    test('seeds isOn filters when query key is absent', () {
      final definition = LdFilterBool<TestItem, int>(
        name: 'active',
        label: (context) => 'Active',
        icon: (context) => const Icon(Icons.check),
        isOn: true,
      );
      final parsed = LdMonkeySortAndFilterState<TestItem, int>(
        filters: {definition.copyWith(isOn: false)},
        sortOptions: const [],
      );

      final seeded = ldMonkeySeedDefinitionDefaults<TestItem, int>(
        routeConfig: routeConfig,
        parsed: parsed,
        query: const {},
        definitionFilters: [definition],
        definitionSortOptions: const [],
      );

      expect(seeded, isNotNull);
      expect(seeded!.filters.single.isOn, isTrue);
    });

    test('does not override filters already present in the query', () {
      final definition = LdFilterBool<TestItem, int>(
        name: 'active',
        label: (context) => 'Active',
        icon: (context) => const Icon(Icons.check),
        isOn: true,
      );
      final parsed = LdMonkeySortAndFilterState<TestItem, int>(
        filters: {definition.copyWith(isOn: false)},
        sortOptions: const [],
      );

      final seeded = ldMonkeySeedDefinitionDefaults<TestItem, int>(
        routeConfig: routeConfig,
        parsed: parsed,
        query: {routeConfig.filterQueryKey('active'): 'true'},
        definitionFilters: [definition],
        definitionSortOptions: const [],
      );

      expect(seeded, isNull);
    });

    test('seeds isOn sorts when sort query is absent', () {
      final definition = LdSortOption<TestItem, int>(
        name: 'name',
        label: (context) => 'Name',
        icon: (context) => const Icon(Icons.sort),
        isOn: true,
        direction: LdSortOptionDirection.desc,
      );
      final parsed = LdMonkeySortAndFilterState<TestItem, int>(
        filters: const {},
        sortOptions: [definition.copyWith(isOn: false)],
      );

      final seeded = ldMonkeySeedDefinitionDefaults<TestItem, int>(
        routeConfig: routeConfig,
        parsed: parsed,
        query: const {},
        definitionFilters: const [],
        definitionSortOptions: [definition],
      );

      expect(seeded, isNotNull);
      expect(seeded!.activeSortOptions.single.direction, LdSortOptionDirection.desc);
    });
  });

  group('ldMonkeyDefaultsReflectedInQuery', () {
    late LdMonkeyRouteConfig<TestItem, int> routeConfig;

    setUp(() {
      routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'task');
    });

    test('returns false when an active filter key is missing', () {
      final state = LdMonkeySortAndFilterState<TestItem, int>(
        filters: {
          LdFilterBool<TestItem, int>(
            name: 'active',
            label: (context) => 'Active',
            icon: (context) => const Icon(Icons.check),
            isOn: true,
          ),
        },
        sortOptions: const [],
      );

      expect(
        ldMonkeyDefaultsReflectedInQuery<TestItem, int>(
          routeConfig: routeConfig,
          query: const {},
          state: state,
        ),
        isFalse,
      );
    });

    test('returns true when active filters and sorts are in the query', () {
      final state = LdMonkeySortAndFilterState<TestItem, int>(
        filters: {
          LdFilterBool<TestItem, int>(
            name: 'active',
            label: (context) => 'Active',
            icon: (context) => const Icon(Icons.check),
            isOn: true,
          ),
        },
        sortOptions: [
          LdSortOption<TestItem, int>(
            name: 'name',
            label: (context) => 'Name',
            icon: (context) => const Icon(Icons.sort),
            isOn: true,
          ),
        ],
      );

      expect(
        ldMonkeyDefaultsReflectedInQuery<TestItem, int>(
          routeConfig: routeConfig,
          query: {
            routeConfig.filterQueryKey('active'): 'true',
            routeConfig.sortQueryKey: 'name-asc',
          },
          state: state,
        ),
        isTrue,
      );
    });
  });
}
