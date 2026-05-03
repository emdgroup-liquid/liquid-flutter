import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class FetchPageParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final int offset;
  final int pageSize;
  final String? pageToken;
  final Set<LdFilterOption<T, IdType>>? filters;
  final List<LdSortOption<T, IdType>>? sortOptions;
  FetchPageParameters({
    required this.context,
    required this.offset,
    required this.pageSize,
    required this.pageToken,
    required this.filters,
    required this.sortOptions,
  });
}
