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
        repositoryBuilder: (context, state) => testRepository(),
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
        repositoryBuilder: (context, state) => testRepository(),
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

  group('buildMonkeyRouteTree', () {
    final cfgA = LdMonkeyRouteConfig.identifiableInt<_RouteTestItem>(itemName: 'a');
    final cfgB = LdMonkeyRouteConfig.identifiableInt<_RouteTestItem>(itemName: 'b');
    final cfgC = LdMonkeyRouteConfig.identifiableInt<_RouteTestItem>(itemName: 'c');

    LdRepository<_RouteTestItem, int> testRepository() => LdRepository.fromList<_RouteTestItem, int>(
          list: [
            _RouteTestItem(1),
            _RouteTestItem(2),
            _RouteTestItem(3),
          ],
        );

    test('two levels: nested detail path uses prefix', () {
      final routes = buildMonkeyRouteTree<_RouteTestItem, int>(
        masterPath: '/p',
        root: MonkeyRouteNode<_RouteTestItem, int>(
          routeConfig: cfgA,
          masterPage: const SizedBox(),
          detailPage: const SizedBox(),
          repositoryBuilder: (context, state) => testRepository(),
          filters: const [],
          sortOptions: const [],
          actions: const [],
          child: MonkeyRouteNode<_RouteTestItem, int>(
            detailPathPrefix: 'files',
            routeConfig: cfgB,
            masterPage: const SizedBox(),
            detailPage: const SizedBox(),
            repositoryBuilder: (context, state) => testRepository(),
            filters: const [],
            sortOptions: const [],
            actions: const [],
          ),
        ),
      );

      final goRoutes = _collectGoRoutes(routes);
      final bDetail = goRoutes.firstWhere((r) => r.name == 'b-detail');
      expect(bDetail.path, 'files/:viewing_b');
    });

    test('three levels: innermost detail path', () {
      final routes = buildMonkeyRouteTree<_RouteTestItem, int>(
        masterPath: '/p',
        root: MonkeyRouteNode<_RouteTestItem, int>(
          routeConfig: cfgA,
          masterPage: const SizedBox(),
          detailPage: const SizedBox(),
          repositoryBuilder: (context, state) => testRepository(),
          filters: const [],
          sortOptions: const [],
          actions: const [],
          child: MonkeyRouteNode<_RouteTestItem, int>(
            detailPathPrefix: 'b',
            routeConfig: cfgB,
            masterPage: const SizedBox(),
            detailPage: const SizedBox(),
            repositoryBuilder: (context, state) => testRepository(),
            filters: const [],
            sortOptions: const [],
            actions: const [],
            child: MonkeyRouteNode<_RouteTestItem, int>(
              detailPathPrefix: 'c',
              routeConfig: cfgC,
              masterPage: const SizedBox(),
              detailPage: const SizedBox(),
              repositoryBuilder: (context, state) => testRepository(),
              filters: const [],
              sortOptions: const [],
              actions: const [],
            ),
          ),
        ),
      );

      final goRoutes = _collectGoRoutes(routes);
      final cDetail = goRoutes.firstWhere((r) => r.name == 'c-detail');
      expect(cDetail.path, 'c/:viewing_c');
    });
  });
}

List<GoRoute> _collectGoRoutes(List<RouteBase> routes) {
  final out = <GoRoute>[];
  for (final r in routes) {
    if (r is ShellRoute) {
      out.addAll(_collectGoRoutes(r.routes));
    } else if (r is GoRoute) {
      out.add(r);
      out.addAll(_collectGoRoutes(r.routes));
    }
  }
  return out;
}
