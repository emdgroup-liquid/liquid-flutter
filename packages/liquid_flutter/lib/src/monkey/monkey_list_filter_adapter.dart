// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyListFilterAdapter<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget child;

  const LdMonkeyListFilterAdapter({
    super.key,
    required this.child,
  });

  @override
  State<LdMonkeyListFilterAdapter<T, IdType>> createState() => _LdMonkeyListFilterAdapterState<T, IdType>();
}

class _LdMonkeyListFilterAdapterState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyListFilterAdapter<T, IdType>> {
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

      if (context.mounted && !filtersEqual) {
        final repository = context.read<LdListController<T, IdType>>();
        await repository.refreshList(context: context, reason: LdFetchReason.filter);
      }

      if (context.mounted && !sortOptionsEqual) {
        final repository = context.read<LdListController<T, IdType>>();
        await repository.refreshList(context: context, reason: LdFetchReason.sort);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdMonkeySortAndFilterState<T, IdType>?>();
    return widget.child;
  }
}
