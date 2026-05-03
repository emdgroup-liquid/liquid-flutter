import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySortAndFilterState<T extends Identifiable<IdType>, IdType> {
  final Set<LdFilterOption<T, IdType>> filters;
  final List<LdSortOption<T, IdType>> sortOptions;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LdMonkeySortAndFilterState<T, IdType> &&
        filters.equals(other.filters) &&
        sortOptions.equals(other.sortOptions);
  }

  @override
  int get hashCode => Object.hash(filters.hashCode, sortOptions.hashCode);

  LdMonkeySortAndFilterState({
    required this.filters,
    required this.sortOptions,
  });

  Map<String, dynamic> getQueryParamters(BuildContext context) {
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final queryParameters = <String, dynamic>{...router.state.uri.queryParameters};

    for (final filter in filters) {
      final queryKey = routeConfig.filterQueryKey(filter.name);
      if (filter.isOn) {
        queryParameters[queryKey] = filter.serialize();
      } else {
        queryParameters.remove(queryKey);
      }
    }

    final sortOptionsOn = sortOptions.where((sortOption) => sortOption.isOn).toList();

    final sortOptionsSerialized = sortOptionsOn.map((sortOption) => sortOption.serialize()).join("_");

    for (final sortOption in sortOptions) {
      final queryKey = routeConfig.sortQueryKey;
      if (sortOption.isOn) {
        queryParameters[queryKey] = sortOption.serialize();
      } else {
        queryParameters.remove(queryKey);
      }
    }
    return queryParameters;
  }

  static void updateFilter<T extends Identifiable<IdType>, IdType>(
      BuildContext context, LdFilterOption<T, IdType> filter) {
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final sortAndFilterState = context.read<LdMonkeySortAndFilterState<T, IdType>>();
    final queryParameters = sortAndFilterState.getQueryParamters(context);
    final queryKey = routeConfig.filterQueryKey(filter.name);
    if (filter.isOn) {
      queryParameters[queryKey] = filter.serialize();
    } else {
      queryParameters.remove(queryKey);
    }
    router.replace(router.state.uri.replace(queryParameters: queryParameters).toString());
  }

  static void updateSortOptions<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    List<LdSortOption<T, IdType>> sortOptions,
  ) {
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final sortAndFilterState = context.read<LdMonkeySortAndFilterState<T, IdType>>();
    final queryParameters = sortAndFilterState.getQueryParamters(context);

    final queryKey = routeConfig.sortQueryKey;

    print("Sort options: $sortOptions");

    final sortOptionString =
        sortOptions.where((sortOption) => sortOption.isOn).map((sortOption) => sortOption.serialize()).join("_");

    if (sortOptionString.isNotEmpty) {
      queryParameters[queryKey] = sortOptionString;
    } else {
      queryParameters.remove(queryKey);
    }

    router.replace(router.state.uri.replace(queryParameters: queryParameters).toString());
  }
}
