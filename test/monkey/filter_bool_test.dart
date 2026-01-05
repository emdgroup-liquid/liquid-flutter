import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdFilterBoolOption Tests', () {
    // Helper to create test items
    TestItem createTestItem(int id, {bool? active}) {
      return TestItem(id, 'Item $id', id * 10, active ?? true);
    }

    group('Serialization', () {
      test('serialize() returns "true" when filter is on', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        expect(filter.serialize(), equals('true'));
      });

      test('serialize() returns "true" when filter is off', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        expect(filter.serialize(), equals('true'));
      });

      test('marshalSerialized() sets isOn to true regardless of input', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final marshaled = filter.marshalSerialized('true');
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to true with empty string', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to true with any value', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final marshaled = filter.marshalSerialized('invalid');
        expect(marshaled.isOn, isTrue);
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() uses provided function when filter is on', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final activeItem = createTestItem(1, active: true);
        final inactiveItem = createTestItem(2, active: false);

        expect(filter.optimisticFilter(activeItem), isTrue);
        expect(filter.optimisticFilter(inactiveItem), isFalse);
      });

      test('optimisticFilter() uses provided function when filter is off', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final activeItem = createTestItem(1, active: true);
        final inactiveItem = createTestItem(2, active: false);

        expect(filter.optimisticFilter(activeItem), isTrue);
        expect(filter.optimisticFilter(inactiveItem), isFalse);
      });

      test('optimisticFilter() works with complex filter logic', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'high-value',
          label: (context) => 'High Value',
          icon: (context) => const Icon(Icons.star),
          isOn: true,
          optimisticFilter: (item) => item.value > 20 && item.active,
        );

        final highValueActiveItem = createTestItem(3, active: true); // value = 30
        final lowValueActiveItem = createTestItem(1, active: true); // value = 10
        final highValueInactiveItem = createTestItem(3, active: false); // value = 30

        expect(filter.optimisticFilter(highValueActiveItem), isTrue);
        expect(filter.optimisticFilter(lowValueActiveItem), isFalse);
        expect(filter.optimisticFilter(highValueInactiveItem), isFalse);
      });
    });

    group('CopyWith', () {
      test('copyWith() updates isOn correctly', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(isOn: true);

        expect(newFilter.isOn, isTrue);
        expect(filter.isOn, isFalse);
      });

      test('copyWith() updates name correctly', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(name: 'inactive');

        expect(newFilter.name, equals('inactive'));
        expect(filter.name, equals('active'));
      });

      test('copyWith() updates label correctly', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(label: (context) => 'Inactive');
        final context = MockBuildContext();

        expect(newFilter.label(context), equals('Inactive'));
        expect(filter.label(context), equals('Active'));
      });

      test('copyWith() updates icon correctly', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(icon: (context) => const Icon(Icons.close));
        final context = MockBuildContext();

        expect(newFilter.icon(context), isA<Icon>());
        expect((newFilter.icon(context) as Icon).icon, equals(Icons.close));
      });

      test('copyWith() updates optimisticFilter correctly', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith(optimisticFilter: (item) => !item.active);
        final activeItem = createTestItem(1, active: true);
        final inactiveItem = createTestItem(2, active: false);

        expect(newFilter.optimisticFilter(activeItem), isFalse);
        expect(newFilter.optimisticFilter(inactiveItem), isTrue);
        expect(filter.optimisticFilter(activeItem), isTrue);
        expect(filter.optimisticFilter(inactiveItem), isFalse);
      });

      test('copyWith() preserves values when not provided', () {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final newFilter = filter.copyWith();

        expect(newFilter.name, equals(filter.name));
        expect(newFilter.isOn, equals(filter.isOn));
        final context = MockBuildContext();
        expect(newFilter.label(context), equals(filter.label(context)));
        final item = createTestItem(1, active: true);
        expect(newFilter.optimisticFilter(item), equals(filter.optimisticFilter(item)));
      });
    });

    group('UI Rendering', () {
      testWidgets('build() returns Container when filter is off', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: Builder(
                    builder: (context) => filter.build(context, repository),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Active'), findsNothing);
        expect(find.byType(LdListItem), findsNothing);
      });

      testWidgets('build() returns LdListItem when filter is on', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: Builder(
                    builder: (context) => filter.build(context, repository),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(LdListItem), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('build() shows X button when filter is on', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: Builder(
                    builder: (context) => filter.build(context, repository),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.widgetWithIcon(LdButton, LucideIcons.x), findsOneWidget);
      });

      testWidgets('tapping X button deactivates filter', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: Builder(
                    builder: (context) => filter.build(context, repository),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(repository.filters['active']!.isOn, isTrue);

        final xButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xButton, findsOneWidget);
        await tester.tap(xButton);
        await tester.pumpAndSettle();

        expect(repository.filters['active']!.isOn, isFalse);
      });

      testWidgets('renders in LdFilterModal and can be activated/deactivated', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: const LdFilterModal<TestItem, int>(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final activeFilterButton = find.widgetWithText(LdButton, 'Active');

        expect(repository.filters['active']!.isOn, isFalse);

        expect(activeFilterButton, findsOneWidget);
        await tester.tap(activeFilterButton);
        await tester.pumpAndSettle();

        expect(repository.filters['active']!.isOn, isTrue);

        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        expect(repository.filters['active']!.isOn, isFalse);
      });
    });
  });
}
