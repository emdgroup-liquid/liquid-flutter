import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class FetchPageParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final int offset;
  final int pageSize;
  final String? pageToken;
  final LdFetchReason reason;
  final LdListCache<T, IdType> cache;

  FetchPageParameters({
    required this.context,
    required this.offset,
    required this.pageSize,
    required this.pageToken,
    required this.reason,
    required this.cache,
  });

  Set<LdFilterOption<T, IdType>> get filters =>
      context
          .read<LdMonkeySortAndFilterState<T, IdType>?>()
          ?.filters
          // Empty serialized values represent "All" for some filters, so they
          // should not constrain repository queries.
          .where((filter) => filter.isOn && filter.serialize().isNotEmpty)
          .toSet() ??
      {};

  List<LdSortOption<T, IdType>> get sortOptions =>
      context
          .read<LdMonkeySortAndFilterState<T, IdType>?>()
          ?.sortOptions
          .where((sortOption) => sortOption.isOn)
          .toList() ??
      [];

  /// Deterministic cache key for the active filter and sort query.
  String get cacheKey => ldListCacheKey<T, IdType>(
        filters: filters,
        sortOptions: sortOptions,
        pageToken: pageToken,
      );
}

class FetchOffsetParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final IdType id;
  final LdFetchReason reason;
  final LdListCache<T, IdType> cache;

  FetchOffsetParameters({
    required this.context,
    required this.id,
    required this.reason,
    required this.cache,
  });

  Set<LdFilterOption<T, IdType>> get filters =>
      context
          .read<LdMonkeySortAndFilterState<T, IdType>?>()
          ?.filters
          .where((filter) => filter.isOn && filter.serialize().isNotEmpty)
          .toSet() ??
      {};

  List<LdSortOption<T, IdType>> get sortOptions =>
      context
          .read<LdMonkeySortAndFilterState<T, IdType>?>()
          ?.sortOptions
          .where((sortOption) => sortOption.isOn)
          .toList() ??
      [];

  /// Deterministic cache key for the active filter and sort query.
  String get cacheKey => ldListCacheKey<T, IdType>(
        filters: filters,
        sortOptions: sortOptions,
      );
}
