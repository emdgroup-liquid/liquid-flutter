import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

/// Wraps a [LdFilterModal] (or [LdFilterContextMenu]) with the providers it
/// needs: repository, router-controller, and sort-and-filter state.
Widget _wrapFilterModal<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required TestSortAndFilterState<T, IdType> shellState,
}) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: Scaffold(
        body: ListenableProvider<LdRepository<T, IdType>>.value(
          value: repository,
          child: ListenableProvider<TestSortAndFilterState<T, IdType>>.value(
            value: shellState,
            child: Provider<LdMonkeyRouterController<T, IdType>>.value(
              value: shellState.controllerDelegate,
              child: Builder(
                builder: (context) {
                  context.watch<TestSortAndFilterState<T, IdType>>();
                  return Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                    value: shellState.state,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Filter Modal Tests', () {
    group('LdFilterModal Widget', () {
      testWidgets('renders correctly with filters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapFilterModal(
            repository: repository,
            shellState: shellState,
            child: const LdFilterModal<TestItem, int>(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Active'), findsWidgets);
      });

      testWidgets('shows active and inactive filters separately', (WidgetTester tester) async {
        final activeFilter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
        );

        final inactiveFilter = LdFilterBool<TestItem, int>(
          name: 'inactive',
          label: (context) => 'Inactive',
          icon: (context) => const Icon(Icons.close),
          isOn: false,
        );

        final shellState = TestSortAndFilterState<TestItem, int>(
          filters: {activeFilter, inactiveFilter},
        );
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapFilterModal(
            repository: repository,
            shellState: shellState,
            child: const LdFilterModal<TestItem, int>(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Active'), findsWidgets);
        expect(find.text('Inactive'), findsWidgets);
      });

      testWidgets('updates when filter is toggled via shellState', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapFilterModal(
            repository: repository,
            shellState: shellState,
            child: const LdFilterModal<TestItem, int>(),
          ),
        );

        await tester.pumpAndSettle();

        // Update filter programmatically
        shellState.updateFilter(MockBuildContext(), filter.copyWith(isOn: true));
        await tester.pumpAndSettle();

        expect(shellState.filtersMap['active']!.isOn, isTrue);
      });

      testWidgets('shows sort options', (WidgetTester tester) async {
        final sortOption = LdSortOption<TestItem, int>(
          name: 'name',
          label: (context) => 'Name',
          icon: (context) => const Icon(Icons.sort),
        );

        final shellState = TestSortAndFilterState<TestItem, int>(
          sortOptions: [sortOption],
        );
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapFilterModal(
            repository: repository,
            shellState: shellState,
            child: const LdFilterModal<TestItem, int>(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Name'), findsOneWidget);
      });
    });

    group('LdFilterContextMenu Widget', () {
      testWidgets('renders filter button', (WidgetTester tester) async {
        final shellState = TestSortAndFilterState<TestItem, int>();
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapFilterModal(
            repository: repository,
            shellState: shellState,
            child: const LdFilterContextMenu<TestItem, int>(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(LdContextMenu), findsOneWidget);
      });
    });
  });
}
