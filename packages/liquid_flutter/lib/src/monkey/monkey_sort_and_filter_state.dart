import 'package:flutter/material.dart';
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

  static void updateFilter<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    LdFilterOption<T, IdType> filter,
  ) =>
      LdMonkeyRouterController.of<T, IdType>(context).updateFilter(context, filter);

  static void updateSortOptions<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    List<LdSortOption<T, IdType>> sortOptions,
  ) =>
      LdMonkeyRouterController.of<T, IdType>(context).updateSortOptions(context, sortOptions);

  static LdMonkeySortAndFilterState<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context.watch<LdMonkeySortAndFilterState<T, IdType>>();
    }
    return context.read<LdMonkeySortAndFilterState<T, IdType>>();
  }

  List<LdFilterOption<T, IdType>> get activeFilters => filters.where((filter) => filter.isOn).toList();
  List<LdSortOption<T, IdType>> get activeSortOptions => sortOptions.where((sortOption) => sortOption.isOn).toList();
}
