import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_repository_filter_adapter.dart';
import 'package:provider/provider.dart';

/// Provides monkey filter/selection state from [LdEphemeralMonkeyController]
/// without [GoRouter].
class LdEphemeralMonkeyAdapter<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdEphemeralMonkeyAdapter({
    super.key,
    required this.controller,
    required this.child,
  });

  final LdEphemeralMonkeyController<T, IdType> controller;
  final Widget child;

  @override
  State<LdEphemeralMonkeyAdapter<T, IdType>> createState() => _LdEphemeralMonkeyAdapterState<T, IdType>();
}

class _LdEphemeralMonkeyAdapterState<T extends Identifiable<IdType>, IdType>
    extends State<LdEphemeralMonkeyAdapter<T, IdType>> {
  String? _lastFilterSignature;
  String? _lastSortSignature;
  LdMonkeySortAndFilterState<T, IdType>? _cachedSortAndFilterState;
  LdMonkeySelection<T, IdType>? _cachedMonkeySelection;

  LdMonkeySortAndFilterState<T, IdType> _sortAndFilterState() {
    final next = widget.controller.sortAndFilterState;
    final cached = _cachedSortAndFilterState;
    if (cached != null &&
        cached.filters.equals(next.filters) &&
        cached.sortOptions.equals(next.sortOptions)) {
      return cached;
    }
    return _cachedSortAndFilterState = next;
  }

  LdMonkeySelection<T, IdType> _monkeySelection() {
    final next = widget.controller.monkeySelection;
    final cached = _cachedMonkeySelection;
    if (cached != null &&
        setEquals(cached.selection, next.selection) &&
        setEquals(cached.viewing, next.viewing) &&
        cached.showSelectionControls == next.showSelectionControls) {
      return cached;
    }
    return _cachedMonkeySelection = next;
  }

  @override
  void initState() {
    super.initState();
    final state = widget.controller.sortAndFilterState;
    _lastFilterSignature = _filterSignature(state);
    _lastSortSignature = _sortSignature(state);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant LdEphemeralMonkeyAdapter<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _lastFilterSignature = null;
      _lastSortSignature = null;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  String _filterSignature(LdMonkeySortAndFilterState<T, IdType> state) {
    final parts = state.filters.map((filter) => '${filter.name}=${filter.serialize()}').toList()..sort();
    return parts.join('|');
  }

  String _sortSignature(LdMonkeySortAndFilterState<T, IdType> state) {
    final parts = state.sortOptions.map((sort) => '${sort.name}=${sort.serialize()}').toList();
    return parts.join('|');
  }

  void _onControllerChanged() {
    final state = widget.controller.sortAndFilterState;
    final filterSignature = _filterSignature(state);
    final sortSignature = _sortSignature(state);
    final filtersChanged = _lastFilterSignature != filterSignature;
    final sortChanged = _lastSortSignature != sortSignature;
    _lastFilterSignature = filterSignature;
    _lastSortSignature = sortSignature;

    if (!filtersChanged && !sortChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final repository = LdRepository.maybeOf<T, IdType>(context);
      if (repository == null) {
        return;
      }
      if (filtersChanged) {
        await repository.refreshList(context: context, reason: LdFetchReason.filter);
      } else if (sortChanged) {
        await repository.refreshList(context: context, reason: LdFetchReason.sort);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdEphemeralMonkeyController<T, IdType>>.value(
      value: widget.controller,
      child: Builder(
        builder: (context) {
          context.watch<LdEphemeralMonkeyController<T, IdType>>();

          return MultiProvider(
            providers: [
              Provider<LdMonkeyRouterController<T, IdType>>.value(
                value: widget.controller.controllerDelegate,
              ),
              Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                value: _sortAndFilterState(),
              ),
              Provider<LdMonkeySelection<T, IdType>>.value(
                value: _monkeySelection(),
              ),
              Provider<LdMonkeyShowingDetail<T, IdType>>.value(value: false),
            ],
            child: LdMonkeyRepositoryFilterAdapter<T, IdType>(
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
