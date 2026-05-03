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
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
        );

        expect(filter.serialize(), equals('true'));
      });

      test('serialize() returns "true" when filter is off', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        expect(filter.serialize(), equals('true'));
      });

      test('marshalSerialized() sets isOn to true regardless of input', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        final marshaled = filter.marshalSerialized('true');
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to true with empty string', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to true with any value', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        final marshaled = filter.marshalSerialized('invalid');
        expect(marshaled.isOn, isTrue);
      });
    });

    group('CopyWith', () {
      test('copyWith() updates isOn correctly', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        final newFilter = filter.copyWith(isOn: true);

        expect(newFilter.isOn, isTrue);
        expect(filter.isOn, isFalse);
      });

      test('copyWith() updates name correctly', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final newFilter = filter.copyWith(name: 'inactive');

        expect(newFilter.name, equals('inactive'));
        expect(filter.name, equals('active'));
      });

      test('copyWith() updates label correctly', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final newFilter = filter.copyWith(label: (context) => 'Inactive');
        final context = MockBuildContext();

        expect(newFilter.label(context), equals('Inactive'));
        expect(filter.label(context), equals('Active'));
      });

      test('copyWith() updates icon correctly', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final newFilter = filter.copyWith(icon: (context) => const Icon(Icons.close));
        final context = MockBuildContext();

        expect(newFilter.icon(context), isA<Icon>());
        expect((newFilter.icon(context) as Icon).icon, equals(Icons.close));
      });

      test('copyWith() preserves values when not provided', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
        );

        final newFilter = filter.copyWith();

        expect(newFilter.name, equals(filter.name));
        expect(newFilter.isOn, equals(filter.isOn));
        final context = MockBuildContext();
        expect(newFilter.label(context), equals(filter.label(context)));
      });
    });

    group('UI Rendering', () {
      testWidgets('build() returns Container when filter is off', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
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
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
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
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
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
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
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
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
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
