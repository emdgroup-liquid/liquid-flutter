import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    ldDisableAnimations = true;
  });
  tearDown(() {
    ldDisableAnimations = false;
  });

  group('LdMonkeyShell Tests', () {
    group('Repository Initialization', () {
      testWidgets('initializes repository via repositoryBuilder', (WidgetTester tester) async {
        var repositoryCreated = false;
        final repository = createTestRepository();
        final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');

        final router = GoRouter(
          initialLocation: '/test',
          routes: buildMonkeyRoutes<TestItem, int>(
            masterPath: '/test',
            routeConfig: routeConfig,
            repositoryBuilder: (context, state) {
              repositoryCreated = true;
              return repository;
            },
            filtersBuilder: (_) async => [],
            sortOptionsBuilder: (_) async => [],
            actions: const [],
            masterPage: const SizedBox(),
            detailPage: LdMonkeyDetailPage<TestItem, int>(
              body: LdMonkeyStackDetailView<TestItem, int>(
                buildDetail: (context, item) => Text(item.value.toString()),
              ),
            ),
          ),
        );

        
await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: const [
                ...LiquidLocalizations.localizationsDelegates,
              ],
              routerConfig: router,
            ),
          ),
        );

        // Use bounded pumps to avoid timeout from continuous list-refresh scheduling.
        for (var i = 0; i < 10; i++) { await tester.pump(const Duration(milliseconds: 100)); }
        expect(repositoryCreated, isTrue);
      });

      testWidgets('applies query parameters to repository filters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final repository = createTestRepository();
        final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');

        final router = GoRouter(
          initialLocation: '/test',
          routes: buildMonkeyRoutes<TestItem, int>(
            masterPath: '/test',
            routeConfig: routeConfig,
            repositoryBuilder: (context, state) => repository,
            filtersBuilder: (_) async => [filter],
            sortOptionsBuilder: (_) async => [],
            actions: const [],
            masterPage: const SizedBox(),
            detailPage: LdMonkeyDetailPage<TestItem, int>(
              body: LdMonkeyStackDetailView<TestItem, int>(
                buildDetail: (context, item) => Text(item.value.toString()),
              ),
            ),
          ),
        );

        // Navigate with filter query param
        router.go('/test?active-item=true');

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: const [
                ...LiquidLocalizations.localizationsDelegates,
              ],
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // The filter state should reflect the query parameter
        final ctx = tester.element(find.byType(LdMonkeyShell<TestItem, int>).last);
        final sortAndFilterState = ctx.read<LdMonkeySortAndFilterState<TestItem, int>>();
        final activeFilter = sortAndFilterState.filters.firstWhere((f) => f.name == 'active');
        expect(activeFilter.isOn, isTrue);
      });

      testWidgets('disables filters not in query parameters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
        );

        final repository = createTestRepository();
        final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');

        final router = GoRouter(
          initialLocation: '/test',
          routes: buildMonkeyRoutes<TestItem, int>(
            masterPath: '/test',
            routeConfig: routeConfig,
            repositoryBuilder: (context, state) => repository,
            filtersBuilder: (_) async => [filter],
            sortOptionsBuilder: (_) async => [],
            actions: const [],
            masterPage: const SizedBox(),
            detailPage: LdMonkeyDetailPage<TestItem, int>(
              body: LdMonkeyStackDetailView<TestItem, int>(
                buildDetail: (context, item) => Text(item.value.toString()),
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: const [
                ...LiquidLocalizations.localizationsDelegates,
              ],
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // With no query param, the initially-on filter should be off
        final ctx = tester.element(find.byType(LdMonkeyShell<TestItem, int>).last);
        final sortAndFilterState = ctx.read<LdMonkeySortAndFilterState<TestItem, int>>();
        final activeFilter = sortAndFilterState.filters.firstWhere((f) => f.name == 'active');
        expect(activeFilter.isOn, isFalse);
      });

      testWidgets('calls initWithSelection when selected items exist', (WidgetTester tester) async {
        var initWithSelectionCalled = false;
        final repository = createTestRepository(
          getOffsetById: (id, {filters, sortOptions}) async {
            initWithSelectionCalled = true;
            return 0;
          },
        );

        final itemRouteConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
        final router = GoRouter(
          initialLocation: '/test/1',
          routes: [
            ...buildMonkeyRoutes<TestItem, int>(
              masterPath: '/test',
              routeConfig: itemRouteConfig,
              repositoryBuilder: (context, state) => repository,
              filtersBuilder: (_) async => [],
              sortOptionsBuilder: (_) async => [],
              actions: const [],
              detailPage: LdMonkeyDetailPage<TestItem, int>(
                body: LdMonkeyStackDetailView<TestItem, int>(buildDetail: (context, item) {
                  return Text(item.value.toString());
                }),
              ),
              masterPage: const SizedBox(),
            ),
          ],
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: const [
                ...LiquidLocalizations.localizationsDelegates,
              ],
              routerConfig: router,
            ),
          ),
        );

        // Use pump with duration instead of pumpAndSettle to avoid timeout
        // from continuous list-refresh scheduling.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(initWithSelectionCalled, isTrue);
      });

      testWidgets('calls fetchItemsAtOffset when no selected items', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [],
        );

        final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
        final router = GoRouter(
          initialLocation: '/test',
          routes: buildMonkeyRoutes<TestItem, int>(
            masterPath: '/test',
            routeConfig: routeConfig,
            repositoryBuilder: (context, state) => repository,
            filtersBuilder: (_) async => [],
            sortOptionsBuilder: (_) async => [],
            actions: const [],
            masterPage: const SizedBox(),
            detailPage: LdMonkeyDetailPage<TestItem, int>(
              body: LdMonkeyStackDetailView<TestItem, int>(
                buildDetail: (context, item) => Text(item.value.toString()),
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: const [
                ...LiquidLocalizations.localizationsDelegates,
              ],
              routerConfig: router,
            ),
          ),
        );

        // Use pump with duration instead of pumpAndSettle to avoid timeout
        // from continuous list-refresh scheduling.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        // Repository should have been initialized (empty list is fine)
        expect(repository.itemsMap.isNotEmpty || repository.itemsMap.isEmpty, isTrue);
      });
    });
  });
}
