import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_deleted_items_guard.dart';
import 'package:liquid_flutter/src/monkey/monkey_list_filter_adapter.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_sync.dart';
import 'package:provider/provider.dart';

/// Centralised contract for all router mutations a monkey component
/// performs in response to user interaction.
///
/// The concrete implementation lives on [LdMonkeyRouterAdapterState] so all
/// `GoRouter` interaction stays in a single place. Consumers should never
/// call methods on this directly; instead they use the static facades on
/// [LdMonkeySelection] and [LdMonkeySortAndFilterState] which look this up
/// via [BuildContext].
abstract class LdMonkeyRouterController<T extends Identifiable<IdType>,
    IdType> {
  void updateSelection(BuildContext context, Set<IdType> selection);

  void updateViewing(BuildContext context, Set<IdType> viewingItems);

  void updateShowSelectionControls(
      BuildContext context, bool showSelectionControls);

  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter);

  void updateSortOptions(
      BuildContext context, List<LdSortOption<T, IdType>> sortOptions);

  static LdMonkeyRouterController<T, IdType>
      of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.read<LdMonkeyRouterController<T, IdType>>();
  }
}

/// Sync the state of the router with the state of the shell.
class LdMonkeyRouterAdapter<T extends Identifiable<IdType>, IdType>
    extends StatefulWidget {
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
  State<LdMonkeyRouterAdapter<T, IdType>> createState() =>
      LdMonkeyRouterAdapterState<T, IdType>();
}

typedef LdMonkeyShowingDetail<T extends Identifiable<IdType>, IdType> = bool;

class LdMonkeyRouterAdapterState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyRouterAdapter<T, IdType>>
    implements LdMonkeyRouterController<T, IdType> {
  // This keeps UI updates responsive while the router delegate catches up.
  LdMonkeySortAndFilterState<T, IdType>? _latestSortAndFilterState;

  /// Whether builder `isOn` defaults have been considered for this definition
  /// generation. Reset when filter/sort structure changes.
  bool _definitionDefaultsSeeded = false;

  /// True while a post-frame URL write for seeded defaults is in flight.
  ///
  /// Keeps optimistic seeded state until the router query catches up (parse
  /// still treats missing keys as off).
  bool _awaitingDefaultsUrlSync = false;

  /// URI written by the most recent [router.replace] within the current frame.
  ///
  /// `GoRouter.replace` does not update `router.state.uri` synchronously, so
  /// sequential mutations in the same callback (e.g. updating the selection and
  /// then toggling the selection controls) would otherwise each read the stale
  /// pre-replace URI and clobber one another. Chaining mutations through this
  /// pending URI lets the second mutation build on the first. It is cleared on
  /// the next frame once the router has caught up.
  Uri? _baseUri;

  @override
  void didUpdateWidget(covariant LdMonkeyRouterAdapter<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final filterDefinitionsChanged =
        !ldMonkeyHasSameFilterStructure(oldWidget.filters, widget.filters);
    final sortDefinitionsChanged = !ldMonkeyHasSameSortStructure(
        oldWidget.sortOptions, widget.sortOptions);

    if (!filterDefinitionsChanged && !sortDefinitionsChanged) {
      return;
    }

    // Structural filter/sort definition changes mean cached state may reference
    // stale objects. Drop cache and rebuild from fresh route definitions.
    _latestSortAndFilterState = null;
    _definitionDefaultsSeeded = false;
    _awaitingDefaultsUrlSync = false;
  }

  LdMonkeySortAndFilterState<T, IdType> _resolveSortAndFilterState(
      BuildContext context) {
    final current = _latestSortAndFilterState;
    if (current != null) {
      return current;
    }
    return context.read<LdMonkeySortAndFilterState<T, IdType>>();
  }

  void _replaceUri(GoRouter router, Uri uri) {
    _baseUri = uri;
    router.replace(uri.toString());
  }

  void _scheduleDefaultsUrlSync(LdMonkeySortAndFilterState<T, IdType> seeded) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_awaitingDefaultsUrlSync) {
        return;
      }
      final current = _latestSortAndFilterState ?? seeded;
      final router = GoRouter.of(context);
      final baseUri = _baseUri ?? router.state.uri;
      final queryParameters = ldMonkeyCurrentQueryParameters(
        context,
        routeConfig: widget.routeConfig,
        baseUri: baseUri,
        sortAndFilterState: current,
      );
      final nextUri = baseUri.replace(queryParameters: queryParameters);
      if (nextUri.toString() == baseUri.toString()) {
        _awaitingDefaultsUrlSync = false;
        return;
      }
      _replaceUri(router, nextUri);
    });
  }

  LdMonkeySortAndFilterState<T, IdType> _hydrateSortAndFilterState({
    required Map<String, String> query,
  }) {
    final baseSortAndFilterState = _latestSortAndFilterState;
    var sortAndFilterState =
        LdMonkeyRouteStateParser.parseSortAndFilter<T, IdType>(
      routeConfig: widget.routeConfig,
      baseFilters: baseSortAndFilterState?.filters ?? widget.filters,
      baseSortOptions:
          baseSortAndFilterState?.sortOptions ?? widget.sortOptions,
      query: query,
    );

    if (!_definitionDefaultsSeeded) {
      _definitionDefaultsSeeded = true;
      final seeded = ldMonkeySeedDefinitionDefaults(
        routeConfig: widget.routeConfig,
        parsed: sortAndFilterState,
        query: query,
        definitionFilters: widget.filters,
        definitionSortOptions: widget.sortOptions,
      );
      if (seeded != null) {
        sortAndFilterState = seeded;
        _awaitingDefaultsUrlSync = true;
        _scheduleDefaultsUrlSync(seeded);
      }
    } else if (_awaitingDefaultsUrlSync && _latestSortAndFilterState != null) {
      final latest = _latestSortAndFilterState!;
      if (ldMonkeyDefaultsReflectedInQuery(
        routeConfig: widget.routeConfig,
        query: query,
        state: latest,
      )) {
        _awaitingDefaultsUrlSync = false;
      } else {
        sortAndFilterState = latest;
      }
    }

    return sortAndFilterState;
  }

  @override
  void updateSelection(BuildContext context, Set<IdType> selection) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();

    final baseUri = _baseUri ?? router.state.uri;
    final queryParameters = {
      ...baseUri.queryParameters,
    };

    if (routeConfig.serialiseIdType(selection).isNotEmpty) {
      queryParameters[routeConfig.selectionQueryKey] =
          routeConfig.serialiseIdType(selection);
    } else {
      queryParameters.remove(routeConfig.selectionQueryKey);
    }

    _replaceUri(
      router,
      baseUri.replace(queryParameters: queryParameters),
    );
  }

  @override
  void updateViewing(BuildContext context, Set<IdType> viewingItems) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();

    final viewingParam = routeConfig.serialiseIdType(viewingItems);

    if (viewingParam ==
        router.state.pathParameters[routeConfig.viewingParamName]) {
      return;
    }

    final showingDetail = router.state.name == routeConfig.detailRouteName;
    final onCreateRoute = router.state.name == routeConfig.createRouteName;

    final queryParameters =
        Map<String, dynamic>.from(router.state.uri.queryParameters);
    final pathParameters = ldMonkeyPathParametersForDetail(
      context,
      routeConfig: routeConfig,
      viewingSerialized: viewingParam,
    );

    // While the create route is active the master list has no selection, so it
    // emits empty viewing updates we must ignore (popping here would close the
    // create page). Once an item is created, replace the create page with its
    // detail route instead of stacking on top of it.
    if (onCreateRoute) {
      if (viewingItems.isNotEmpty) {
        final uri = router.namedLocation(
          routeConfig.detailRouteName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );

        _baseUri = Uri.parse(uri);
        router.replace(uri);
      }
      return;
    }

    if (showingDetail) {
      if (viewingItems.isEmpty) {
        router.pop();
        _baseUri = router.state.uri;
      } else {
        final uri = router.namedLocation(
          routeConfig.detailRouteName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );

        _baseUri = Uri.parse(uri);
        router.replace(uri);
      }
    } else {
      if (viewingItems.isNotEmpty) {
        final uri = router.namedLocation(
          routeConfig.detailRouteName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );

        _baseUri = Uri.parse(uri);
        router.push(uri);
      }
    }
  }

  @override
  void updateShowSelectionControls(
      BuildContext context, bool showSelectionControls) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final baseUri = _baseUri ?? router.state.uri;
    final queryParameters = <String, dynamic>{
      ...baseUri.queryParameters,
    };

    if (showSelectionControls ==
        (queryParameters[routeConfig.showSelectionControlsQueryKey] ==
            'true')) {
      return;
    }

    if (showSelectionControls) {
      queryParameters[routeConfig.showSelectionControlsQueryKey] = 'true';
    } else {
      queryParameters.remove(routeConfig.showSelectionControlsQueryKey);
    }

    _replaceUri(
      router,
      baseUri.replace(queryParameters: queryParameters),
    );
  }

  @override
  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter) {
    final currentState = _resolveSortAndFilterState(context);
    _latestSortAndFilterState = LdMonkeySortAndFilterState<T, IdType>(
      filters: ldMonkeyReplaceFilterByName(currentState.filters, filter),
      sortOptions: currentState.sortOptions,
    );
    if (mounted) {
      setState(() {});
    }

    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final baseUri = _baseUri ?? router.state.uri;
    final queryParameters = ldMonkeyCurrentQueryParameters(
      context,
      routeConfig: routeConfig,
      baseUri: baseUri,
      sortAndFilterState: _resolveSortAndFilterState(context),
    );
    final queryKey = routeConfig.filterQueryKey(filter.name);
    if (filter.isOn) {
      queryParameters[queryKey] = filter.serialize();
    } else {
      queryParameters.remove(queryKey);
    }

    _replaceUri(
      router,
      (_baseUri ?? router.state.uri).replace(queryParameters: queryParameters),
    );
  }

  @override
  void updateSortOptions(
      BuildContext context, List<LdSortOption<T, IdType>> sortOptions) {
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
    final baseUri = _baseUri ?? router.state.uri;
    final queryParameters = ldMonkeyCurrentQueryParameters(
      context,
      routeConfig: routeConfig,
      baseUri: baseUri,
      sortAndFilterState: _resolveSortAndFilterState(context),
    );

    final queryKey = routeConfig.sortQueryKey;

    final sortOptionString = sortOptions
        .where((sortOption) => sortOption.isOn)
        .map((sortOption) => sortOption.serialize())
        .join("_");

    if (sortOptionString.isNotEmpty) {
      queryParameters[queryKey] = sortOptionString;
    } else {
      queryParameters.remove(queryKey);
    }

    _replaceUri(
      router,
      (_baseUri ?? router.state.uri).replace(queryParameters: queryParameters),
    );
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
            (match) =>
                match is GoRoute &&
                match.name == widget.routeConfig.detailRouteName,
          ) as GoRoute?;

          final state = delegate.state;
          final query = state.uri.queryParameters;

          final selection = LdMonkeyRouteStateParser.parseSelection<T, IdType>(
            routeConfig: widget.routeConfig,
            query: query,
            pathParameters: state.pathParameters,
          );
          final sortAndFilterState = _hydrateSortAndFilterState(query: query);
          _latestSortAndFilterState = sortAndFilterState;
          _baseUri = state.uri;

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
            child: _LdMonkeySelectionHydrator<T, IdType>(
              viewing: selection.viewing,
              child: LdMonkeyListFilterAdapter<T, IdType>(
                child:
                    LdMonkeyDeletedItemsGuard<T, IdType>(child: widget.child),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Anchors the list view around [viewing] items that may live outside the
/// currently loaded pages (e.g. a deep-linked detail selection).
///
/// Mounted *below* [LdMonkeySortAndFilterState] so that offset resolution in
/// [FetchOffsetParameters] reads the correct active filter/sort state.
class _LdMonkeySelectionHydrator<T extends Identifiable<IdType>, IdType>
    extends StatefulWidget {
  final Set<IdType> viewing;
  final Widget child;

  const _LdMonkeySelectionHydrator({
    super.key,
    required this.viewing,
    required this.child,
  });

  @override
  State<_LdMonkeySelectionHydrator<T, IdType>> createState() =>
      _LdMonkeySelectionHydratorState<T, IdType>();
}

class _LdMonkeySelectionHydratorState<T extends Identifiable<IdType>, IdType>
    extends State<_LdMonkeySelectionHydrator<T, IdType>> {
  Set<IdType> _lastHydratedViewing = {};
  int _selectionHydrationRequest = 0;

  void _scheduleSelectionHydration(Set<IdType> viewing) {
    if (setEquals(_lastHydratedViewing, viewing)) {
      return;
    }
    _lastHydratedViewing = {...viewing};
    final request = ++_selectionHydrationRequest;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          request != _selectionHydrationRequest ||
          viewing.isEmpty) {
        return;
      }
      final repository = LdListController.maybeOf<T, IdType>(context);
      if (repository == null) {
        return;
      }
      await repository.initWithSelection(context, viewing);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSelectionHydration(widget.viewing);
    return widget.child;
  }
}
