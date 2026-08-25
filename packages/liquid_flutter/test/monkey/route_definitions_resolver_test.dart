import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 30,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

LdFilterOneOf<TestItem, int, String> _categoryFilter({Map<String, Widget Function(BuildContext)>? allValues}) {
  return LdFilterOneOf<TestItem, int, String>(
    name: 'category',
    label: (context) => 'Category',
    icon: (context) => const Icon(Icons.category),
    allValues: allValues ?? {},
  );
}

void main() {
  group('LdMonkeyRouteDefinitionsResolver', () {
    testWidgets('shows localized loading then mounts adapter', (WidgetTester tester) async {
      final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
      final repository = createTestListController();
      final filterCompleter = Completer<List<LdFilterOption<TestItem, int>>>();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Provider<LdMonkeyRouteConfig<TestItem, int>>.value(
              value: routeConfig,
              child: ListenableProvider<LdListController<TestItem, int>>.value(
                value: repository,
                child: LdMonkeyRouteDefinitionsResolver<TestItem, int>(
                  filtersBuilder: (_) => filterCompleter.future,
                  sortOptionsBuilder: (_) async => [],
                  child: (context, resolved) => LdMonkeyRouterAdapter<TestItem, int>(
                    routeConfig: routeConfig,
                    filters: resolved.filters.toList(),
                    sortOptions: resolved.sortOptions,
                    child: const Text('Ready'),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        ),
      );

      await _pumpUntilFound(tester, find.byType(LdLoader));
      expect(find.textContaining('filters'), findsOneWidget);

      filterCompleter.complete([_categoryFilter()]);
      await tester.pumpAndSettle();
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('routeDefinitionsLoadingText overrides default loading copy', (WidgetTester tester) async {
      final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
      final repository = createTestListController();
      final filterCompleter = Completer<List<LdFilterOption<TestItem, int>>>();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Provider<LdMonkeyRouteConfig<TestItem, int>>.value(
              value: routeConfig,
              child: ListenableProvider<LdListController<TestItem, int>>.value(
                value: repository,
                child: LdMonkeyRouteDefinitionsResolver<TestItem, int>(
                  routeDefinitionsLoadingText: (_) => 'Custom catalog loading',
                  filtersBuilder: (_) => filterCompleter.future,
                  sortOptionsBuilder: (_) async => [],
                  child: (context, resolved) => const Text('Ready'),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        ),
      );

      await _pumpUntilFound(tester, find.textContaining('Custom catalog loading'));

      filterCompleter.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('hydrates oneOf from URL after async filtersBuilder', (WidgetTester tester) async {
      final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
      final categoryQueryKey = routeConfig.filterQueryKey('category');
      final repository = createTestListController();

      final router = GoRouter(
        initialLocation: '/?$categoryQueryKey=Gold',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Provider<LdMonkeyRouteConfig<TestItem, int>>.value(
              value: routeConfig,
              child: ListenableProvider<LdListController<TestItem, int>>.value(
                value: repository,
                child: LdMonkeyRouteDefinitionsResolver<TestItem, int>(
                  filtersBuilder: (_) async => [
                    _categoryFilter(
                      allValues: {
                        for (final option in ['Gold', 'Silver'])
                          option: (context) => Text(option),
                      },
                    ),
                  ],
                  sortOptionsBuilder: (_) async => [],
                  // URL hydration is applied by LdMonkeyRouterAdapter (not the
                  // resolver), so that builder isOn defaults can be seeded.
                  child: (context, resolved) => LdMonkeyRouterAdapter<TestItem, int>(
                    routeConfig: routeConfig,
                    filters: resolved.filters.toList(),
                    sortOptions: resolved.sortOptions,
                    child: Builder(
                      builder: (context) {
                        final gold = LdMonkeySortAndFilterState.of<TestItem, int>(context)
                            .filters
                            .whereType<LdFilterOneOf<TestItem, int, String>>()
                            .first;
                        return Text('selected:${gold.selectedValue}');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('selected:Gold'), findsOneWidget);
    });

    testWidgets('refreshFilterDefinitions re-fetches while keeping shell', (WidgetTester tester) async {
      final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
      final repository = createTestListController();
      var loadCount = 0;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Provider<LdMonkeyRouteConfig<TestItem, int>>.value(
              value: routeConfig,
              child: ListenableProvider<LdListController<TestItem, int>>.value(
                value: repository,
                child: LdMonkeyRouteDefinitionsResolver<TestItem, int>(
                  filtersBuilder: (_) async {
                    loadCount++;
                    await Future<void>.delayed(const Duration(milliseconds: 30));
                    return [
                      LdFilterBool<TestItem, int>(
                        name: 'active',
                        label: (context) => 'Active $loadCount',
                        icon: (context) => const Icon(Icons.check),
                        isOn: loadCount > 1,
                      ),
                    ];
                  },
                  sortOptionsBuilder: (_) async => [],
                  child: (context, resolved) => LdMonkeyRouterAdapter<TestItem, int>(
                    routeConfig: routeConfig,
                    filters: resolved.filters.toList(),
                    sortOptions: resolved.sortOptions,
                    child: Builder(
                      builder: (context) {
                        final label = LdMonkeySortAndFilterState.of<TestItem, int>(context)
                            .filters
                            .first
                            .label(context);
                        return Column(
                          children: [
                            Text(label),
                            LdButton(
                              child: const Text('Refresh'),
                              onPressed: () {
                                LdMonkeySortAndFilterState.refreshFilterDefinitions<TestItem, int>(
                                  context,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Active 1'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.byType(LdLoader), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.textContaining('Active 2'), findsOneWidget);
      expect(loadCount, 2);
    });
  });
}
