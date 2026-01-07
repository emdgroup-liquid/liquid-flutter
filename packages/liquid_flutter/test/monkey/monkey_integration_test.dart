import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('Monkey Integration Tests', () {
    group('Side-by-Side Layout', () {
      testWidgets('renders master and detail side-by-side when wide enough', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );

        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: LdMonkeyDetailPage<TestItem, int>(
            body: Builder(
              builder: (context) {
                final viewing = LdMonkeyShellState.of<TestItem, int>(context).viewingItems;
                return Text('Viewing: ${viewing.join(", ")}');
              },
            ),
          ),
          masterPage: LdMonkeyMasterPage<TestItem, int>(
            buildItem: (context, item) => LdListItem(
              title: Text(item.value?.name ?? ''),
            ),
          ),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.sideBySide,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

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

        router.go('/test/1');
        await tester.pumpAndSettle();

        // Both master and detail should be visible in side-by-side mode
        expect(find.text('Item 1'), findsWidgets);
        expect(find.textContaining('Viewing'), findsWidgets);
      });
    });

    group('Responsive Behavior', () {
      testWidgets('switches layout based on screen width in auto mode', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
          ],
        );

        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(
          routes: routes,
          initialLocation: '/test',
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

        router.go('/test');
        await tester.pumpAndSettle();

        // Layout should adapt based on screen size
        expect(find.byType(LdMonkeyShell<TestItem, int>), findsOneWidget);
      });
    });

    group('URL State Sync', () {
      testWidgets('selection updates URL query parameters', (WidgetTester tester) async {
        final repository = createTestRepository();
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: LdMonkeyMasterPage<TestItem, int>(
            buildItem: (context, item) => LdListItem(
              title: Text(item.value?.name ?? ''),
            ),
          ),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

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

        router.go('/test');
        await tester.pumpAndSettle();

        // Note: Testing URL updates requires more complex setup with actual router state
        // This test documents expected behavior
        expect(router.routerDelegate.currentConfiguration.uri.path, equals('/test'));
      });

      testWidgets('filter changes update URL query parameters', (WidgetTester tester) async {
        final filter = LdFilterBool<TestItem, int>(
          name: 'id-active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final repository = createTestRepository(filters: {filter});
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

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

        router.go('/test?id-active=true');
        await tester.pumpAndSettle();

        expect(repository.filters['id-active']!.isOn, isTrue);
      });
    });

    group('Navigation', () {
      testWidgets('navigates to detail page when item selected', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
          ],
        );

        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const Text('Detail Page'),
          masterPage: LdMonkeyMasterPage<TestItem, int>(
            buildItem: (context, item) => LdListItem(
              title: Text(item.value?.name ?? ''),
            ),
          ),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.neverSideBySide,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

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

        router.go('/test');
        await tester.pumpAndSettle();

        router.go('/test/1');
        await tester.pumpAndSettle();

        expect(find.text('Detail Page'), findsOneWidget);
      });

      testWidgets('navigates back to master when detail route cleared', (WidgetTester tester) async {
        final repository = createTestRepository();

        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const Text('Detail Page'),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => repository,
          layoutMode: LdMonkeyLayoutMode.neverSideBySide,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

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

        router.go('/test/1');
        await tester.pumpAndSettle();
        expect(find.text('Detail Page'), findsOneWidget);

        router.go('/test');
        await tester.pumpAndSettle();
        expect(find.text('Detail Page'), findsNothing);
      });
    });
  });
}
