import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

class _ChildItem with Identifiable<String> {
  @override
  final String id;
  final String name;
  _ChildItem(this.id, this.name);
}

void main() {
  group('Monkey route integration', () {
    final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');

    testWidgets('buildMonkeyRoutes navigates to detail', (WidgetTester tester) async {
      final routes = buildMonkeyRoutes<TestItem, int>(
        masterPath: '/t',
        routeConfig: routeConfig,
        masterPage: LdMonkeyMasterPage<TestItem, int>(
          buildItem: (context, item) => LdListItem(
            title: Text(item.value?.name ?? ''),
          ),
        ),
        detailPage: const Text('Detail'),
        modelBuilder: (context, state) => createTestModel(),
        filtersBuilder: (_) async => [],
        sortOptionsBuilder: (_) async => [],
        actions: const [],
        layoutMode: LdMonkeyLayoutMode.neverSideBySide,
      );

      final router = GoRouter(
        routes: routes,
        initialLocation: '/t',
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
      router.go('/t/1');
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);
    });

    testWidgets(
      'nested tree: child scope is available on parent detail (= child master)',
      (WidgetTester tester) async {
        final parentRouteConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'parent');
        final childRouteConfig = LdMonkeyRouteConfig.identifiableString<_ChildItem>(itemName: 'child');

        final routes = buildMonkeyRouteTree<TestItem, int>(
          masterPath: '/p',
          root: MonkeyRouteNode<TestItem, int>(
            routeConfig: parentRouteConfig,
            masterPage: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(title: Text(item.value?.name ?? '')),
            ),
            // parent detail acts as the child's master page in stacked m-d
            detailPage: LdMonkeyMasterPage<_ChildItem, String>(
              buildItem: (context, item) => LdListItem(title: Text(item.value?.name ?? '')),
            ),
            modelBuilder: (context, state) => createTestModel(),
            filtersBuilder: (_) async => [],
            sortOptionsBuilder: (_) async => [],
            actions: const [],
            layoutMode: LdMonkeyLayoutMode.neverSideBySide,
            child: MonkeyRouteNode<_ChildItem, String>(
              detailPathPrefix: 'children',
              routeConfig: childRouteConfig,
              masterPage: const SizedBox(),
              detailPage: const Text('ChildDetail'),
              modelBuilder: (context, state) => LdCallbackModel<_ChildItem, String>(
                isGreedy: true,
                getById: (context, id) async => _ChildItem(id, id.toUpperCase()),
                fetchListWithParameters: (parameters) async {
                  final items = [_ChildItem('a', 'A'), _ChildItem('b', 'B')];
                  return LdListPage<_ChildItem>(
                    newItems: items.skip(parameters.offset).take(parameters.pageSize).toList(),
                    hasMore: parameters.offset + parameters.pageSize < items.length,
                    total: items.length,
                  );
                },
              ),
              filtersBuilder: (_) async => [],
              sortOptionsBuilder: (_) async => [],
              actions: const [],
              layoutMode: LdMonkeyLayoutMode.neverSideBySide,
            ),
          ),
        );

        final router = GoRouter(routes: routes, initialLocation: '/p');

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

        // Navigating to the parent's detail page used to throw
        // ProviderNotFoundException for LdMonkeySelection<_ChildItem, String>
        // because the child scope was only mounted under the deeper detail
        // route. With the fix, the child scope wraps the parent detail too.
        router.go('/p/1');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);

        router.go('/p/1/children/a');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('ChildDetail'), findsOneWidget);
      },
    );
  });
}
