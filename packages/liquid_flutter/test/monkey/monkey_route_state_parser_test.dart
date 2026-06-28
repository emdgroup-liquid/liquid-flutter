import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyRouteConfig', () {
    late LdMonkeyRouteConfig<TestItem, int> routeConfig;

    setUp(() {
      routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'task');
    });

    test('parseIdType parses underscore-separated integers', () {
      expect(routeConfig.parseIdType('1_2_3'), equals({1, 2, 3}));
    });

    test('parseIdType ignores invalid segments', () {
      expect(routeConfig.parseIdType('1_x_3'), equals({1, 3}));
    });

    test('serialiseIdType joins ids with underscores', () {
      expect(routeConfig.serialiseIdType({1, 2, 3}), equals('1_2_3'));
    });

    test('filterQueryKey includes item name', () {
      expect(routeConfig.filterQueryKey('status'), equals('status-task'));
    });

    test('sortQueryKey includes item name', () {
      expect(routeConfig.sortQueryKey, equals('sort-task'));
    });

    test('identifiableString parseIdType splits on underscores', () {
      final stringConfig = LdMonkeyRouteConfig.identifiableString<_StringDoc>(itemName: 'doc');
      expect(stringConfig.parseIdType('alpha_beta'), equals({'alpha', 'beta'}));
    });
  });

  group('LdMonkeyRouteStateParser.parseSelection', () {
    late LdMonkeyRouteConfig<TestItem, int> routeConfig;

    setUp(() {
      routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'task');
    });

    test('parses selection from query parameters', () {
      final selection = LdMonkeyRouteStateParser.parseSelection<TestItem, int>(
        routeConfig: routeConfig,
        query: {routeConfig.selectionQueryKey: '1_2'},
        pathParameters: const {},
      );

      expect(selection.selection, equals({1, 2}));
      expect(selection.viewing, isEmpty);
      expect(selection.showSelectionControls, isFalse);
    });

    test('parses viewing from path parameters', () {
      final selection = LdMonkeyRouteStateParser.parseSelection<TestItem, int>(
        routeConfig: routeConfig,
        query: const {},
        pathParameters: {routeConfig.viewingParamName: '3_4'},
      );

      expect(selection.viewing, equals({3, 4}));
      expect(selection.selection, isEmpty);
    });

    test('parses showSelectionControls from query', () {
      final selection = LdMonkeyRouteStateParser.parseSelection<TestItem, int>(
        routeConfig: routeConfig,
        query: {routeConfig.showSelectionControlsQueryKey: 'true'},
        pathParameters: const {},
      );

      expect(selection.showSelectionControls, isTrue);
    });

    test('returns empty sets when parameters are absent', () {
      final selection = LdMonkeyRouteStateParser.parseSelection<TestItem, int>(
        routeConfig: routeConfig,
        query: const {},
        pathParameters: const {},
      );

      expect(selection.selection, isEmpty);
      expect(selection.viewing, isEmpty);
      expect(selection.showSelectionControls, isFalse);
    });
  });

  group('LdMonkeyRouteStateParser.parseSortAndFilter', () {
    late LdMonkeyRouteConfig<TestItem, int> routeConfig;
    late LdFilterBool<TestItem, int> activeFilter;
    late LdFilterBool<TestItem, int> statusFilter;
    late LdSortOption<TestItem, int> nameSort;
    late LdSortOption<TestItem, int> valueSort;

    setUp(() {
      routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'task');
      activeFilter = LdFilterBool<TestItem, int>(
        name: 'active',
        label: (context) => 'Active',
        icon: (context) => const Icon(Icons.check),
        isOn: true,
      );
      statusFilter = LdFilterBool<TestItem, int>(
        name: 'status',
        label: (context) => 'Status',
        icon: (context) => const Icon(Icons.flag),
        isOn: true,
      );
      nameSort = LdSortOption<TestItem, int>(
        name: 'name',
        label: (context) => 'Name',
        icon: (context) => const Icon(Icons.sort),
        isOn: true,
        direction: LdSortOptionDirection.asc,
      );
      valueSort = LdSortOption<TestItem, int>(
        name: 'value',
        label: (context) => 'Value',
        icon: (context) => const Icon(Icons.numbers),
        isOn: false,
        direction: LdSortOptionDirection.desc,
      );
    });

    test('turns filters off when query key is absent', () {
      final state = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: {activeFilter, statusFilter},
        baseSortOptions: [nameSort, valueSort],
        query: const {},
      );

      expect(state.filters.every((filter) => !filter.isOn), isTrue);
    });

    test('marshals active filters from query', () {
      final state = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: {activeFilter, statusFilter},
        baseSortOptions: const [],
        query: {routeConfig.filterQueryKey('active'): 'true'},
      );

      final active = state.filters.firstWhere((filter) => filter.name == 'active');
      final status = state.filters.firstWhere((filter) => filter.name == 'status');

      expect(active.isOn, isTrue);
      expect(status.isOn, isFalse);
    });

    test('ignores unknown filter keys in query', () {
      final state = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: {activeFilter},
        baseSortOptions: const [],
        query: {routeConfig.filterQueryKey('unknown'): 'true'},
      );

      expect(state.filters.single.isOn, isFalse);
    });

    test('parses multi-sort query preserving order', () {
      final state = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: const {},
        baseSortOptions: [nameSort, valueSort],
        query: {routeConfig.sortQueryKey: 'value-desc_name-asc'},
      );

      expect(state.sortOptions.length, equals(2));
      expect(state.sortOptions[0].name, equals('value'));
      expect(state.sortOptions[0].isOn, isTrue);
      expect(state.sortOptions[0].direction, equals(LdSortOptionDirection.desc));
      expect(state.sortOptions[1].name, equals('name'));
      expect(state.sortOptions[1].isOn, isTrue);
      expect(state.sortOptions[1].direction, equals(LdSortOptionDirection.asc));
    });

    test('ignores unknown sort names in query', () {
      final state = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: const {},
        baseSortOptions: [nameSort],
        query: {routeConfig.sortQueryKey: 'missing-desc_name-asc'},
      );

      expect(state.sortOptions.where((sort) => sort.isOn).map((sort) => sort.name), equals(['name']));
    });

    test('round-trips selection and sort/filter through serialize helpers', () {
      final query = {
        routeConfig.selectionQueryKey: routeConfig.serialiseIdType({1, 2}),
        routeConfig.showSelectionControlsQueryKey: 'true',
        routeConfig.filterQueryKey('active'): activeFilter.serialize(),
        routeConfig.sortQueryKey: nameSort.serialize(),
      };

      final selection = LdMonkeyRouteStateParser.parseSelection<TestItem, int>(
        routeConfig: routeConfig,
        query: query,
        pathParameters: {routeConfig.viewingParamName: routeConfig.serialiseIdType({2})},
      );

      final sortAndFilter = LdMonkeyRouteStateParser.parseSortAndFilter<TestItem, int>(
        routeConfig: routeConfig,
        baseFilters: {activeFilter.copyWith(isOn: false), statusFilter.copyWith(isOn: false)},
        baseSortOptions: [nameSort.copyWith(isOn: false), valueSort],
        query: query,
      );

      expect(selection.selection, equals({1, 2}));
      expect(selection.viewing, equals({2}));
      expect(selection.showSelectionControls, isTrue);
      expect(sortAndFilter.activeFilters.map((filter) => filter.name), equals(['active']));
      expect(sortAndFilter.activeSortOptions.single.name, equals('name'));
    });
  });
}

class _StringDoc with Identifiable<String> {
  @override
  final String id;

  _StringDoc(this.id);
}
