import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class FetchOffsetParameters<T extends Identifiable<IdType>, IdType> {
  BuildContext context;
  final IdType id;
  final Set<LdFilterOption<T, IdType>>? filters;
  final List<LdSortOption<T, IdType>>? sortOptions;
  FetchOffsetParameters({
    required this.context,
    required this.id,
    required this.filters,
    required this.sortOptions,
  });
}
