import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_deleted_items_guard.dart';
import 'package:liquid_flutter/src/monkey/monkey_repository_filter_adapter.dart';
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
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final queryParameters = _currentQueryParameters();
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
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final queryParameters = _currentQueryParameters();

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
  Map<String, dynamic> _currentQueryParameters() {
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    final router = GoRouter.of(context);
    final sortAndFilterState = context.read<LdMonkeySortAndFilterState<T, IdType>>();
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

    for (final sortOption in sortAndFilterState.sortOptions) {
      final queryKey = routeConfig.sortQueryKey;
      if (sortOption.isOn) {
        queryParameters[queryKey] = sortOption.serialize();
      } else {
        queryParameters.remove(queryKey);
      }
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

          final query = delegate.state.uri.queryParameters;
          final viewing = delegate.state.pathParameters[widget.routeConfig.viewingParamName];

          Set<IdType> parsedViewing = {};
          if (viewing != null) {
            parsedViewing = widget.routeConfig.parseIdType(viewing);
          }

          final selection = query[widget.routeConfig.selectionQueryKey];
          Set<IdType> parsedSelection = {};
          if (selection != null) {
            parsedSelection = widget.routeConfig.parseIdType(selection);
          }

          final showSelectionControls = query[widget.routeConfig.showSelectionControlsQueryKey] == 'true';

          final filters = widget.filters.map((filter) {
            final queryKey = widget.routeConfig.filterQueryKey(filter.name);
            if (query.containsKey(queryKey)) {
              return filter.marshalSerialized(query[queryKey]!);
            }
            return filter.copyWith(isOn: false);
          });

          final sortQuery = query[widget.routeConfig.sortQueryKey];

          final sortOptionsLeft = widget.sortOptions.map((sortOption) {
            return sortOption.copyWith(isOn: false);
          }).toList();

          final parsedSortQuery = sortQuery
                  ?.split("_")
                  .toSet()
                  .map((sortEntry) {
                    final sortOption = sortOptionsLeft.firstWhereOrNull(
                      (sortOption) => sortOption.name == sortEntry.split("-")[0],
                    );
                    if (sortOption != null) {
                      sortOptionsLeft.remove(sortOption);
                      return sortOption.marshalSerialized(sortEntry);
                    }
                    return null;
                  })
                  .nonNulls
                  .toList() ??
              [];

          return MultiProvider(
            providers: [
              Provider<LdMonkeyRouterController<T, IdType>>.value(value: this),
              Provider.value(
                value: LdMonkeySelection<T, IdType>(
                  selection: parsedSelection,
                  viewing: parsedViewing,
                  showSelectionControls: showSelectionControls,
                ),
              ),
              Provider<LdMonkeyShowingDetail<T, IdType>>.value(
                value: detailMatch != null,
              ),
              Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                value: LdMonkeySortAndFilterState<T, IdType>(
                  filters: filters.toSet(),
                  sortOptions: parsedSortQuery + sortOptionsLeft,
                ),
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
