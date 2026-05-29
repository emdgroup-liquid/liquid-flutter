import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class FetchPageParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final int offset;
  final int pageSize;
  final String? pageToken;

  FetchPageParameters({
    required this.context,
    required this.offset,
    required this.pageSize,
    required this.pageToken,
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
}

class FetchOffsetParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final IdType id;
  FetchOffsetParameters({
    required this.context,
    required this.id,
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
}
