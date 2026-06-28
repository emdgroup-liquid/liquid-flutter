import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Structural-diff helpers and URL serialization utilities for
/// [LdMonkeyRouterAdapter].
bool ldMonkeyHasSameFilterStructure<T extends Identifiable<IdType>, IdType>(
  Iterable<LdFilterOption<T, IdType>> left,
  Iterable<LdFilterOption<T, IdType>> right,
) {
  final leftByName = {
    for (final filter in left) filter.name: ldMonkeyFilterStructureSignature(filter),
  };
  final rightByName = {
    for (final filter in right) filter.name: ldMonkeyFilterStructureSignature(filter),
  };

  if (leftByName.length != rightByName.length) {
    return false;
  }

  for (final entry in leftByName.entries) {
    if (rightByName[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

Object ldMonkeyFilterStructureSignature<T extends Identifiable<IdType>, IdType>(
  LdFilterOption<T, IdType> filter,
) {
  if (filter is LdFilterOneOf<T, IdType, dynamic>) {
    return Object.hash(
      filter.runtimeType,
      ldMonkeyStableKeySignature(filter.allValues.keys),
    );
  }

  if (filter is LdFilterAnyOf<T, IdType, dynamic>) {
    return Object.hash(
      filter.runtimeType,
      ldMonkeyStableKeySignature(filter.allValues.keys),
    );
  }

  return filter.runtimeType;
}

String ldMonkeyStableKeySignature(Iterable<dynamic> values) {
  final keys = values.map((value) => value.toString()).toList()..sort();
  return keys.join('|');
}

bool ldMonkeyHasSameSortStructure<T extends Identifiable<IdType>, IdType>(
  Iterable<LdSortOption<T, IdType>> left,
  Iterable<LdSortOption<T, IdType>> right,
) {
  final leftByName = {
    for (final sortOption in left) sortOption.name: sortOption.runtimeType,
  };
  final rightByName = {
    for (final sortOption in right) sortOption.name: sortOption.runtimeType,
  };

  if (leftByName.length != rightByName.length) {
    return false;
  }

  for (final entry in leftByName.entries) {
    if (rightByName[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

Set<LdFilterOption<T, IdType>> ldMonkeyReplaceFilterByName<T extends Identifiable<IdType>, IdType>(
  Iterable<LdFilterOption<T, IdType>> filters,
  LdFilterOption<T, IdType> filter,
) {
  final byName = <String, LdFilterOption<T, IdType>>{
    for (final current in filters) current.name: current,
  };
  byName[filter.name] = filter;
  return byName.values.toSet();
}

/// Rebuilds the current query parameter map from the active sort and
/// filter state so that subsequent overrides operate on a normalised view.
Map<String, dynamic> ldMonkeyCurrentQueryParameters<T extends Identifiable<IdType>, IdType>(
  BuildContext context, {
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required Uri baseUri,
  required LdMonkeySortAndFilterState<T, IdType> sortAndFilterState,
}) {
  final queryParameters = <String, dynamic>{
    ...baseUri.queryParameters,
  };

  for (final filter in sortAndFilterState.filters) {
    final queryKey = routeConfig.filterQueryKey(filter.name);
    if (filter.isOn) {
      queryParameters[queryKey] = filter.serialize();
    } else {
      queryParameters.remove(queryKey);
    }
  }

  final sortKey = routeConfig.sortQueryKey;
  final sortOptionString = sortAndFilterState.sortOptions
      .where((sortOption) => sortOption.isOn)
      .map((sortOption) => sortOption.serialize())
      .join("_");

  if (sortOptionString.isNotEmpty) {
    queryParameters[sortKey] = sortOptionString;
  } else {
    queryParameters.remove(sortKey);
  }

  return queryParameters;
}

Set<String> ldMonkeyPathParamNames(String path) {
  return RegExp(r':(\w+)').allMatches(path).map((match) => match.group(1)!).toSet();
}

/// Collects every path parameter name declared along the route tree from the
/// root down to (and including) the [GoRoute] named [routeName].
Set<String> ldMonkeyDetailRoutePathParamNames(
  GoRouter router,
  String routeName,
) {
  final result = <String>{};

  bool visit(List<RouteBase> routes, Set<String> accumulated) {
    for (final route in routes) {
      final next = {...accumulated};
      if (route is GoRoute) {
        next.addAll(ldMonkeyPathParamNames(route.path));
        if (route.name == routeName) {
          result.addAll(next);
          return true;
        }
      }
      if (visit(route.routes, next)) {
        return true;
      }
    }
    return false;
  }

  visit(router.configuration.routes, <String>{});
  return result;
}

/// Keeps ancestor path segments (nested monkeys) and sets this monkey's
/// [LdMonkeyRouteConfig.viewingParamName].
///
/// Only forwards path parameters that the target detail route actually
/// declares. Without this, navigating to a parent-level detail route from a
/// deeper level (e.g. switching projects while viewing a file) would leak the
/// deeper level's params (e.g. `viewing_file`) into a route that does not
/// define them, tripping a `GoRouter` assertion.
Map<String, String> ldMonkeyPathParametersForDetail<T extends Identifiable<IdType>, IdType>(
  BuildContext context, {
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required String viewingSerialized,
}) {
  final router = GoRouter.of(context);
  final validParamNames = ldMonkeyDetailRoutePathParamNames(
    router,
    routeConfig.detailRouteName,
  );
  return <String, String>{
    for (final entry in router.state.pathParameters.entries)
      if (validParamNames.contains(entry.key)) entry.key: entry.value,
    routeConfig.viewingParamName: viewingSerialized,
  };
}
