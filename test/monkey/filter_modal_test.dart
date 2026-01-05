import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('Filter Modal Tests', () {
    group('LdFilterModal Widget', () {
      testWidgets('renders correctly with filters', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
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

        expect(find.text('Active'), findsWidgets);
      });

      testWidgets('shows active and inactive filters separately', (WidgetTester tester) async {
        final activeFilter = LdFilterBoolOption<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final inactiveFilter = LdFilterBoolOption<TestItem, int>(
          name: 'inactive',
          label: (context) => 'Inactive',
          icon: (context) => const Icon(Icons.close),
          isOn: false,
          optimisticFilter: (item) => !item.active,
        );

        final repository = createTestRepository(
          filters: {activeFilter, inactiveFilter},
        );

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

        expect(find.text('Active'), findsWidgets);
        expect(find.text('Inactive'), findsWidgets);
      });

      testWidgets('updates when filter stream emits', (WidgetTester tester) async {
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

        // Update filter
        repository.updateFilter('active', (f) => f!.copyWith(isOn: true));
        await tester.pumpAndSettle();

        // Modal should reflect the update
        expect(repository.filters['active']!.isOn, isTrue);
      });

      testWidgets('shows sort options', (WidgetTester tester) async {
        final sortOption = LdSortOption<TestItem, int>(
          name: 'name',
          label: (context) => 'Name',
          icon: (context) => const Icon(Icons.sort),
          optimisticSort: (a, b) => a.name.compareTo(b.name),
        );

        final repository = createTestRepository(
          sortOptions: [sortOption],
        );

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

        expect(find.text('Name'), findsOneWidget);
      });
    });

    group('LdFilterContextMenu Widget', () {
      testWidgets('renders filter button', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              locale: const Locale('en'),
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: const LdFilterContextMenu<TestItem, int>(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(LdContextMenu), findsOneWidget);
      });
    });
  });
}
