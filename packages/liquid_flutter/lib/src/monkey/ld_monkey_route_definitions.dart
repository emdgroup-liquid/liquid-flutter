import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';

typedef LdMonkeyFiltersBuilder<T extends Identifiable<IdType>, IdType> =
    Future<List<LdFilterOption<T, IdType>>> Function(BuildContext context);

typedef LdMonkeySortOptionsBuilder<T extends Identifiable<IdType>, IdType> =
    Future<List<LdSortOption<T, IdType>>> Function(BuildContext context);

typedef LdMonkeyReorderHandler<T extends Identifiable<IdType>, IdType> = Future<T> Function(
  BuildContext context,
  T item,
  int fromIndex,
  int toIndex,
);

typedef LdMonkeyRouteDefinitionsLoadingTextBuilder = String Function(BuildContext context);

/// Resolved filter and sort definitions passed to [LdMonkeyRouterAdapter].
class LdMonkeyResolvedRouteDefinitions<T extends Identifiable<IdType>, IdType> {
  const LdMonkeyResolvedRouteDefinitions({
    required this.filters,
    required this.sortOptions,
  });

  final Set<LdFilterOption<T, IdType>> filters;
  final List<LdSortOption<T, IdType>> sortOptions;
}
