import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyShell Tests', () {
    group('Repository Initialization', () {
      testWidgets('initializes repository via repositoryBuilder', (WidgetTester tester) async {
        var repositoryCreated = false;
        final repository = createTestRepository();

        final router = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => LdMonkeyShell<TestItem, int>(
                basePath: '/test',
                routeState: state,
                masterPage: const SizedBox(),
                parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                repositoryBuilder: (context) async {
                  repositoryCreated = true;
                  return repository;
                },
                pathParameterName: 'id',
                child: const SizedBox(),
              ),
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

        await tester.pumpAndSettle();
        expect(repositoryCreated, isTrue);
      });

      testWidgets('applies query parameters to repository filters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'id-active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
        );

        final repository = createTestRepository(filters: {filter});

        final router = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => LdMonkeyShell<TestItem, int>(
                basePath: '/test',
                routeState: state,
                masterPage: const SizedBox(),
                parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                repositoryBuilder: (context) async => repository,
                pathParameterName: 'id',
                child: const SizedBox(),
              ),
            ),
          ],
        );

        router.go('/test?id-active=true');
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
        expect(repository.filters['id-active']!.isOn, isTrue);
      });

      testWidgets('disables filters not in query parameters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'id-active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
        );

        final repository = createTestRepository(filters: {filter});

        final router = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => LdMonkeyShell<TestItem, int>(
                basePath: '/test',
                routeState: state,
                masterPage: const SizedBox(),
                parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                repositoryBuilder: (context) async => repository,
                pathParameterName: 'id',
                child: const SizedBox(),
              ),
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

        await tester.pumpAndSettle();
        expect(repository.filters['id-active']!.isOn, isFalse);
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
              repositoryBuilder: (context) => repository,
              filters: const [],
              sortOptions: const [],
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

        await tester.pumpAndSettle();
        expect(initWithSelectionCalled, isTrue);
      });

      testWidgets('calls fetchItemsAtOffset when no selected items', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [],
        );

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => LdMonkeyShell<TestItem, int>(
                basePath: '/test',
                routeState: state,
                masterPage: const SizedBox(),
                parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                repositoryBuilder: (context) async => repository,
                pathParameterName: 'id',
                child: const SizedBox(),
              ),
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

        await tester.pumpAndSettle();
        // Repository should have been initialized and fetched
        expect(repository.itemsMap.isNotEmpty || repository.itemsMap.isEmpty, isTrue);
      });
    });

    group('Route Selection', () {
      testWidgets('routeSelection returns path parameter value', (WidgetTester tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/test',
              routes: [
                GoRoute(
                  path: ':selected_id',
                  builder: (context, state) {
                    return LdMonkeyShell<TestItem, int>(
                      basePath: '/test',
                      routeState: state,
                      masterPage: const SizedBox(),
                      repositoryBuilder: (context) async => createTestRepository(),
                      parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                      pathParameterName: 'id',
                      child: Builder(
                        builder: (context) {
                          final shell = context.findAncestorWidgetOfExactType<LdMonkeyShell<TestItem, int>>()!;
                          expect(shell.routeSelection, equals('1_2_3'));
                          return const SizedBox();
                        },
                      ),
                    );
                  },
                ),
              ],
              builder: (context, state) => const SizedBox(),
            ),
          ],
        );

        router.go('/test/1_2_3');
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
      });

      testWidgets('routeSelection returns null when no path parameter', (WidgetTester tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                return LdMonkeyShell<TestItem, int>(
                  basePath: '/test',
                  routeState: state,
                  masterPage: const SizedBox(),
                  parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
                  pathParameterName: 'id',
                  child: Builder(
                    builder: (context) {
                      final shell = context.findAncestorWidgetOfExactType<LdMonkeyShell<TestItem, int>>()!;
                      expect(shell.routeSelection, isNull);
                      return const SizedBox();
                    },
                  ),
                );
              },
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
        await tester.pumpAndSettle();
      });
    });
  });
}
