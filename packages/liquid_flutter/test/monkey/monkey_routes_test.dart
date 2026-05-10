import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _RouteTestItem with Identifiable<int> {
  @override
  final int id;
  _RouteTestItem(this.id);
}

void main() {
  group('buildMonkeyRoutes', () {
    final routeConfig = LdMonkeyRouteConfig.identifiableInt<_RouteTestItem>(itemName: 'item');

    LdRepository<_RouteTestItem, int> testRepository() => LdRepository.fromList<_RouteTestItem, int>(
          list: [
            _RouteTestItem(1),
            _RouteTestItem(2),
            _RouteTestItem(3),
          ],
        );

    test('master route path and name', () {
      final routes = buildMonkeyRoutes<_RouteTestItem, int>(
        masterPath: '/test',
        routeConfig: routeConfig,
        detailPage: const SizedBox(),
        masterPage: const SizedBox(),
        repositoryBuilder: (context) => testRepository(),
        filters: const [],
        sortOptions: const [],
        actions: const [],
      );

      final shellRoute = routes.firstWhere((route) => route is ShellRoute) as ShellRoute;
      final masterRoute = shellRoute.routes.first as GoRoute;

      expect(masterRoute.path, '/test');
      expect(masterRoute.name, 'item-master');
    });

    test('detail route path and name', () {
      final routes = buildMonkeyRoutes<_RouteTestItem, int>(
        masterPath: '/test',
        routeConfig: routeConfig,
        detailPage: const SizedBox(),
        masterPage: const SizedBox(),
        repositoryBuilder: (context) => testRepository(),
        filters: const [],
        sortOptions: const [],
        actions: const [],
      );

      final shellRoute = routes.firstWhere((route) => route is ShellRoute) as ShellRoute;
      final masterRoute = shellRoute.routes.first as GoRoute;
      final detailRoute = masterRoute.routes.first as GoRoute;

      expect(detailRoute.path, ':viewing_item');
      expect(detailRoute.name, 'item-detail');
    });
  });
}
