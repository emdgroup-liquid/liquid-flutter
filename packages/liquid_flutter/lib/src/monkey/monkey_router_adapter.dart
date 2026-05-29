import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_deleted_items_guard.dart';
import 'package:liquid_flutter/src/monkey/monkey_repository_filter_adapter.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';
import 'package:provider/provider.dart';

/// Centralised contract for all router mutations a monkey component
/// performs in response to user interaction.
///
/// The concrete implementation lives on [LdMonkeyRouterAdapterState] so all
/// `GoRouter` interaction stays in a single place. Consumers should never
/// call methods on this directly; instead they use the static facades on
/// [LdMonkeySelection] and [LdMonkeySortAndFilterState] which look this up
/// via [BuildContext].
abstract class LdMonkeyRouterController<T extends Identifiable<IdType>, IdType> {
  void updateSelection(BuildContext context, Set<IdType> selection);

  void updateViewing(BuildContext context, Set<IdType> viewingItems);

  void updateShowSelectionControls(BuildContext context, bool showSelectionControls);

  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter);

  void updateSortOptions(BuildContext context, List<LdSortOption<T, IdType>> sortOptions);

  static LdMonkeyRouterController<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdMonkeyRouterController<T, IdType>>();
  }
}

/// Sync the state of the router with the state of the shell.
class LdMonkeyRouterAdapter<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget child;
  final LdMonkeyRouteConfig<T, IdType> routeConfig;

  final List<LdFilterOption<T, IdType>> filters;
  final List<LdSortOption<T, IdType>> sortOptions;

  const LdMonkeyRouterAdapter({
    super.key,
    required this.child,
    required this.routeConfig,
    required this.filters,
    required this.sortOptions,
  });

  @override
  State<LdMonkeyRouterAdapter<T, IdType>> createState() => LdMonkeyRouterAdapterState<T, IdType>();
}

typedef LdMonkeyShowingDetail<T extends Identifiable<IdType>, IdType> = bool;

class LdMonkeyRouterAdapterState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyRouterAdapter<T, IdType>>
    implements LdMonkeyRouterController<T, IdType> {
  // This keeps UI updates responsive while the router delegate catches up.
  LdMonkeySortAndFilterState<T, IdType>? _latestSortAndFilterState;

  bool _hasSameFilterStructure(
    Iterable<LdFilterOption<T, IdType>> left,
    Iterable<LdFilterOption<T, IdType>> right,
  ) {
    final leftByName = {
      for (final filter in left) filter.name: _filterStructureSignature(filter),
    };
    final rightByName = {
      for (final filter in right) filter.name: _filterStructureSignature(filter),
    };

    if (leftByName.length != rightByName.length) {
      return false;
    }

    for (final entry in leftByName.entries) {
      if (rightByName[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  Object _filterStructureSignature(LdFilterOption<T, IdType> filter) {
    if (filter is LdFilterOneOf<T, IdType, dynamic>) {
      return Object.hash(
        filter.runtimeType,
        _stableKeySignature(filter.allValues.keys),
      );
    }

    if (filter is LdFilterAnyOf<T, IdType, dynamic>) {
      return Object.hash(
        filter.runtimeType,
        _stableKeySignature(filter.allValues.keys),
      );
    }

    return filter.runtimeType;
  }

  String _stableKeySignature(Iterable<dynamic> values) {
    final keys = values.map((value) => value.toString()).toList()..sort();
    return keys.join('|');
  }

  bool _hasSameSortStructure(
    Iterable<LdSortOption<T, IdType>> left,
    Iterable<LdSortOption<T, IdType>> right,
  ) {
    final leftByName = {
      for (final sortOption in left) sortOption.name: sortOption.runtimeType,
    };
    final rightByName = {
      for (final sortOption in right) sortOption.name: sortOption.runtimeType,
    };

    if (leftByName.length != rightByName.length) {
      return false;
    }

    for (final entry in leftByName.entries) {
      if (rightByName[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  @override
  void didUpdateWidget(covariant LdMonkeyRouterAdapter<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final latestState = _latestSortAndFilterState;
    if (latestState == null) {
      return;
    }

    final filterDefinitionsChanged = !_hasSameFilterStructure(oldWidget.filters, widget.filters);
    final sortDefinitionsChanged = !_hasSameSortStructure(oldWidget.sortOptions, widget.sortOptions);

    if (!filterDefinitionsChanged && !sortDefinitionsChanged) {
      return;
    }

    // Structural filter/sort definition changes mean cached state may reference
    // stale objects. Drop cache and rebuild from fresh route definitions.
    _latestSortAndFilterState = null;
  }

  Set<LdFilterOption<T, IdType>> _replaceFilterByName(
    Iterable<LdFilterOption<T, IdType>> filters,
    LdFilterOption<T, IdType> filter,
  ) {
    final byName = <String, LdFilterOption<T, IdType>>{
      for (final current in filters) current.name: current,
    };
    byName[filter.name] = filter;
    return byName.values.toSet();
  }

  LdMonkeySortAndFilterState<T, IdType> _resolveSortAndFilterState(BuildContext context) {
    final current = _latestSortAndFilterState;
    if (current != null) {
      return current;
    }
    return context.read<LdMonkeySortAndFilterState<T, IdType>>();
  }

  @override
  void updateSelection(BuildContext context, Set<IdType> selection) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();

    final queryParameters = {
      ...router.state.uri.queryParameters,
    };

    if (routeConfig.serialiseIdType(selection).isNotEmpty) {
      queryParameters[routeConfig.selectionQueryKey] = routeConfig.serialiseIdType(selection);
    } else {
      queryParameters.remove(routeConfig.selectionQueryKey);
    }

    router.replace(
      router.state.uri.replace(queryParameters: queryParameters).toString(),
    );
  }

  @override
  void updateViewing(BuildContext context, Set<IdType> viewingItems) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();

    final viewingParam = routeConfig.serialiseIdType(viewingItems);

    final showingDetail = context.read<LdMonkeyShowingDetail<T, IdType>>();

    final queryParameters = Map<String, dynamic>.from(router.state.uri.queryParameters);
    final pathParameters = _pathParametersForDetail(context, routeConfig, viewingParam);

    if (showingDetail) {
      if (viewingItems.isEmpty) {
        router.pop();
      } else {
        router.replaceNamed(
          routeConfig.detailRouteName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      }
    } else {
      if (viewingItems.isNotEmpty) {
        router.pushNamed(
          routeConfig.detailRouteName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      }
    }
  }

  /// Keeps ancestor path segments (nested monkeys) and sets this monkey's
  /// [LdMonkeyRouteConfig.viewingParamName].
  Map<String, String> _pathParametersForDetail(
    BuildContext context,
    LdMonkeyRouteConfig<T, IdType> routeConfig,
    String viewingSerialized,
  ) {
    return <String, String>{
      ...GoRouter.of(context).state.pathParameters,
      routeConfig.viewingParamName: viewingSerialized,
    };
  }

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final queryParameters = <String, dynamic>{
      ...router.state.uri.queryParameters,
    };
    if (showSelectionControls) {
      queryParameters[routeConfig.showSelectionControlsQueryKey] = 'true';
    } else {
      queryParameters.remove(routeConfig.showSelectionControlsQueryKey);
    }
    router.replace(
      router.state.uri.replace(queryParameters: queryParameters).toString(),
    );
  }

  @override
  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter) {
    final currentState = _resolveSortAndFilterState(context);
    _latestSortAndFilterState = LdMonkeySortAndFilterState<T, IdType>(
      filters: _replaceFilterByName(currentState.filters, filter),
      sortOptions: currentState.sortOptions,
    );
    if (mounted) {
      setState(() {});
    }

    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final queryParameters = _currentQueryParameters(context);
    final queryKey = routeConfig.filterQueryKey(filter.name);
    if (filter.isOn) {
      queryParameters[queryKey] = filter.serialize();
    } else {
      queryParameters.remove(queryKey);
    }
    router.replace(
      router.state.uri.replace(queryParameters: queryParameters).toString(),
    );
  }

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<T, IdType>> sortOptions) {
    final currentState = _resolveSortAndFilterState(context);
    _latestSortAndFilterState = LdMonkeySortAndFilterState<T, IdType>(
      filters: currentState.filters,
      sortOptions: sortOptions,
    );
    if (mounted) {
      setState(() {});
    }

    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final queryParameters = _currentQueryParameters(context);

    final queryKey = routeConfig.sortQueryKey;

    final sortOptionString =
        sortOptions.where((sortOption) => sortOption.isOn).map((sortOption) => sortOption.serialize()).join("_");

    if (sortOptionString.isNotEmpty) {
      queryParameters[queryKey] = sortOptionString;
    } else {
      queryParameters.remove(queryKey);
    }

    router.replace(
      router.state.uri.replace(queryParameters: queryParameters).toString(),
    );
  }

  /// Rebuilds the current query parameter map from the active sort and
  /// filter state so that subsequent overrides operate on a normalised view.
  Map<String, dynamic> _currentQueryParameters(BuildContext context) {
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final sortAndFilterState = _resolveSortAndFilterState(context);
    final queryParameters = <String, dynamic>{
      ...router.state.uri.queryParameters,
    };

    for (final filter in sortAndFilterState.filters) {
      final queryKey = routeConfig.filterQueryKey(filter.name);
      if (filter.isOn) {
        queryParameters[queryKey] = filter.serialize();
      } else {
        queryParameters.remove(queryKey);
      }
    }

    final sortKey = routeConfig.sortQueryKey;
    final sortOptionString = sortAndFilterState.sortOptions
        .where((sortOption) => sortOption.isOn)
        .map((sortOption) => sortOption.serialize())
        .join("_");

    if (sortOptionString.isNotEmpty) {
      queryParameters[sortKey] = sortOptionString;
    } else {
      queryParameters.remove(sortKey);
    }

    return queryParameters;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: GoRouter.of(context).routerDelegate,
      child: Builder(
        builder: (context) {
          final delegate = context.watch<GoRouterDelegate>();
          final matches = delegate.currentConfiguration.routes;

          final detailMatch = matches.firstWhereOrNull(
            (match) => match is GoRoute && match.name == widget.routeConfig.detailRouteName,
          ) as GoRoute?;

          final state = delegate.state;
          final query = state.uri.queryParameters;
          final selection = LdMonkeyRouteStateParser.parseSelection<T, IdType>(
            routeConfig: widget.routeConfig,
            query: query,
            pathParameters: state.pathParameters,
          );
          final baseSortAndFilterState = _latestSortAndFilterState;
          final sortAndFilterState = LdMonkeyRouteStateParser.parseSortAndFilter<T, IdType>(
            routeConfig: widget.routeConfig,
            baseFilters: baseSortAndFilterState?.filters ?? widget.filters,
            baseSortOptions: baseSortAndFilterState?.sortOptions ?? widget.sortOptions,
            query: query,
          );
          _latestSortAndFilterState = sortAndFilterState;

          return MultiProvider(
            providers: [
              Provider<LdMonkeyRouterController<T, IdType>>.value(value: this),
              Provider.value(
                value: selection,
              ),
              Provider<LdMonkeyShowingDetail<T, IdType>>.value(
                value: detailMatch != null,
              ),
              Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                value: sortAndFilterState,
              ),
            ],
            child: LdMonkeyRepositoryFilterAdapter<T, IdType>(
              child: LdMonkeyDeletedItemsGuard<T, IdType>(child: widget.child),
            ),
          );
        },
      ),
    );
  }
}
