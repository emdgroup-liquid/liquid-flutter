import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/repository.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';
import 'package:liquid_flutter/src/monkey/monkey_router_adapter.dart';
import 'package:liquid_flutter/src/monkey/monkey_selection.dart';
import 'package:liquid_flutter/src/monkey/monkey_sort_and_filter_state.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';
import 'package:provider/provider.dart';

/// Rebuilds monkey filter providers from the current router URL so filter UI
/// stays in sync while an open sheet/context menu remains mounted.
Widget ldFilterStateScope<T extends Identifiable<IdType>, IdType>({
  required GoRouterDelegate routerDelegate,
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required LdMonkeyRouterController<T, IdType> routerController,
  required LdRepository<T, IdType> repository,
  required Iterable<LdFilterOption<T, IdType>> baseFilters,
  required Iterable<LdSortOption<T, IdType>> baseSortOptions,
  required Widget child,
}) {
  return ListenableBuilder(
    listenable: routerDelegate,
    builder: (context, _) {
      final state = routerDelegate.state;
      final query = state.uri.queryParameters;

      final selection = LdMonkeyRouteStateParser.parseSelection<T, IdType>(
        routeConfig: routeConfig,
        query: query,
        pathParameters: state.pathParameters,
      );

      final sortAndFilterState = LdMonkeyRouteStateParser.parseSortAndFilter<T, IdType>(
        routeConfig: routeConfig,
        baseFilters: baseFilters,
        baseSortOptions: baseSortOptions,
        query: query,
      );

      return MultiProvider(
        providers: [
          Provider<LdMonkeyRouteConfig<T, IdType>>.value(value: routeConfig),
          Provider<LdMonkeyRouterController<T, IdType>>.value(value: routerController),
          Provider<LdMonkeySortAndFilterState<T, IdType>>.value(value: sortAndFilterState),
          Provider<LdMonkeySelection<T, IdType>>.value(value: selection),
          ListenableProvider<LdRepository<T, IdType>>.value(value: repository),
        ],
        child: child,
      );
    },
  );
}
