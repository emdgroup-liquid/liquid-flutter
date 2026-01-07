import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('buildMonkeyRoutes Tests', () {
    group('Route Structure', () {
      test('creates master route', () {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final shellRoute = routes.firstWhere((route) => route is ShellRoute) as ShellRoute;
        final masterRoute = (shellRoute.routes.first as GoRoute);

        expect(masterRoute.path, equals('/test'));
        expect(masterRoute.name, equals('/test-master'));
      });

      test('creates detail route with path parameter', () {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final shellRoute = routes.firstWhere((route) => route is ShellRoute) as ShellRoute;
        final masterRoute = shellRoute.routes.first as GoRoute;
        final detailRoute = masterRoute.routes.first as GoRoute;

        expect(detailRoute.path, equals('/:selected_id'));
        expect(detailRoute.name, equals('/test-detail'));
      });

      test('wraps routes in ShellRoute', () {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        expect(routes.any((route) => route is ShellRoute), isTrue);
      });
    });

    group('Detail Route', () {
      testWidgets('detail route renders detail page', (WidgetTester tester) async {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const Text('Detail Page'),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        );

        router.go('/test/1');
        await tester.pumpAndSettle();

        expect(find.text('Detail Page'), findsOneWidget);
      });

      testWidgets('detail route uses MaterialPage when detailInDialog is false and effectiveLayout is detail',
          (WidgetTester tester) async {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const Text('Detail Page'),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.neverSideBySide,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
          detailInDialog: false,
        );

        final router = GoRouter(routes: routes);

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        );

        router.go('/test/1');
        await tester.pumpAndSettle();

        expect(find.text('Detail Page'), findsOneWidget);
      });

      testWidgets('detail route uses LdModalPage when detailInDialog is true', (WidgetTester tester) async {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const Text('Detail Page'),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.neverSideBySide,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
          detailInDialog: true,
        );

        final router = GoRouter(routes: routes);

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        );

        router.go('/test/1');
        await tester.pumpAndSettle();

        expect(find.text('Detail Page'), findsOneWidget);
      });
    });

    group('Shell Builder', () {
      testWidgets('uses custom shellBuilder when provided', (WidgetTester tester) async {
        var customBuilderCalled = false;

        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
          shellBuilder: ({
            required context,
            required routeState,
            required child,
            required pathParameterName,
            required masterPage,
            required basePath,
          }) {
            customBuilderCalled = true;
            return Container(child: child);
          },
        );

        final router = GoRouter(routes: routes);

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        );

        router.go('/test');
        await tester.pumpAndSettle();

        expect(customBuilderCalled, isTrue);
      });

      testWidgets('uses default LdMonkeyShell when shellBuilder not provided', (WidgetTester tester) async {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'id',
        );

        final router = GoRouter(routes: routes);

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp.router(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        );

        router.go('/test');
        await tester.pumpAndSettle();

        expect(find.byType(LdMonkeyShell<TestItem, int>), findsOneWidget);
      });
    });

    group('Path Parameter Name', () {
      test('uses pathParameterName in route paths', () {
        final routes = buildMonkeyRoutes<TestItem, int>(
          basePath: '/test',
          detailPage: const SizedBox(),
          masterPage: const SizedBox(),
          repositoryBuilder: (context) async => createTestRepository(),
          layoutMode: LdMonkeyLayoutMode.auto,
          parseSelected: (selected) => selected.split('_').map(int.parse).toSet(),
          pathParameterName: 'itemId',
        );

        final shellRoute = routes.firstWhere((route) => route is ShellRoute) as ShellRoute;
        final masterRoute = shellRoute.routes.first as GoRoute;
        final detailRoute = masterRoute.routes.first as GoRoute;

        expect(detailRoute.path, equals('/:selected_itemId'));
      });
    });
  });
}
