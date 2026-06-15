import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/ld_monkey_route_definitions.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';
import 'package:liquid_flutter/src/monkey/monkey_sort_and_filter_state.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';
import 'package:provider/provider.dart';

Future<LdMonkeyResolvedRouteDefinitions<T, IdType>> resolveMonkeyRouteDefinitions<
    T extends Identifiable<IdType>,
    IdType>({
  required BuildContext context,
  required LdMonkeyFiltersBuilder<T, IdType> filtersBuilder,
  required LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder,
}) async {
  final results = await Future.wait([
    filtersBuilder(context),
    sortOptionsBuilder(context),
  ]);

  final filtersList = results[0] as List<LdFilterOption<T, IdType>>;
  final sortOptions = results[1] as List<LdSortOption<T, IdType>>;

  LdMonkeyRouteConfig<T, IdType>? routeConfig;
  Map<String, String> query = {};
  try {
    routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      query = router.state.uri.queryParameters;
    }
  } on ProviderNotFoundException {
    routeConfig = null;
  }

  var filters = filtersList.toSet();

  if (routeConfig != null) {
    filters = filters
        .map((filter) {
          final queryKey = routeConfig!.filterQueryKey(filter.name);
          final serialized = query[queryKey];
          if (serialized == null) {
            return filter.copyWith(isOn: false);
          }
          return filter.marshalSerialized(serialized);
        })
        .toSet();
  }

  return LdMonkeyResolvedRouteDefinitions<T, IdType>(
    filters: filters,
    sortOptions: sortOptions,
  );
}

/// Applies URL query to already-hydrated base filters.
LdMonkeySortAndFilterState<T, IdType> parseSortAndFilterFromContext<T extends Identifiable<IdType>, IdType>(
  BuildContext context, {
  required Set<LdFilterOption<T, IdType>> baseFilters,
  required List<LdSortOption<T, IdType>> baseSortOptions,
}) {
  final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
  final router = GoRouter.of(context);
  return LdMonkeyRouteStateParser.parseSortAndFilter<T, IdType>(
    routeConfig: routeConfig,
    baseFilters: baseFilters,
    baseSortOptions: baseSortOptions,
    query: router.state.uri.queryParameters,
  );
}
