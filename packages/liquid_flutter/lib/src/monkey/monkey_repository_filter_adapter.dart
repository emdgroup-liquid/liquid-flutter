// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_sort_and_filter_state.dart';
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _applyFilters();
  }

  void _applyFilters() async {
    await Future.delayed(Duration.zero);
    if (!context.mounted) return;
    final repository = context.read<LdRepository<T, IdType>>();
    final sortAndFilterState = context.read<LdMonkeySortAndFilterState<T, IdType>?>();
    if (sortAndFilterState != null) {
      print("Sort and filter state: ${sortAndFilterState.filters}");
      print("Repository filters: ${repository.filters}");
      bool filtersChanged = !repository.filters.equals(sortAndFilterState.filters);
      bool sortOptionsChanged = !repository.sortOptions.equals(sortAndFilterState.sortOptions);
      if (filtersChanged) {
        repository.updateFilters(sortAndFilterState.filters);
      }
      if (sortOptionsChanged) {
        repository.updateSortOptions(sortAndFilterState.sortOptions);
      }

      await Future.delayed(Duration.zero);
      print("Context mounted: ${context.mounted}");
      print("Filters changed: $filtersChanged");
      print("Sort options changed: $sortOptionsChanged");
      if (context.mounted && (filtersChanged || sortOptionsChanged)) {
        print("Refreshing repository");
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
