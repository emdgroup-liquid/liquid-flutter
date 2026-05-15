// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyRepositoryFilterAdapter<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget child;

  const LdMonkeyRepositoryFilterAdapter({
    super.key,
    required this.child,
  });

  @override
  State<LdMonkeyRepositoryFilterAdapter<T, IdType>> createState() => _LdMonkeyRepositoryFilterAdapterState<T, IdType>();
}

class _LdMonkeyRepositoryFilterAdapterState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyRepositoryFilterAdapter<T, IdType>> {
  LdMonkeySortAndFilterState<T, IdType>? _lastSortAndFilterState;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _applyFilters();
  }

  void _applyFilters() async {
    await Future.delayed(Duration.zero);
    if (!context.mounted) return;

    final sortAndFilterState = context.read<LdMonkeySortAndFilterState<T, IdType>?>();
    if (sortAndFilterState != null) {
      await Future.delayed(Duration.zero);

      final filtersEqual = _lastSortAndFilterState?.filters.equals(sortAndFilterState.filters) ?? false;
      final sortOptionsEqual = _lastSortAndFilterState?.sortOptions.equals(sortAndFilterState.sortOptions) ?? false;

      _lastSortAndFilterState = sortAndFilterState;

      if (context.mounted && (!filtersEqual || !sortOptionsEqual)) {
        final repository = context.read<LdRepository<T, IdType>>();

        repository.refreshList(context: context, hard: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdMonkeySortAndFilterState<T, IdType>?>();
    return widget.child;
  }
}
