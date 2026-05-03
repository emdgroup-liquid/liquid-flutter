import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_deleted_items_guard.dart';
import 'package:liquid_flutter/src/monkey/monkey_repository_filter_adapter.dart';
import 'package:liquid_flutter/src/monkey/monkey_sort_and_filter_state.dart';
import 'package:provider/provider.dart';

/// Sync the state of the router with the state of the shell.
class MonkeyRouterAdapter<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget child;
  final LdMonkeyRouteConfig<T, IdType> routeConfig;

  final List<LdFilterOption<T, IdType>> filters;
  final List<LdSortOption<T, IdType>> sortOptions;

  const MonkeyRouterAdapter({
    super.key,
    required this.child,
    required this.routeConfig,
    required this.filters,
    required this.sortOptions,
  });

  @override
  State<MonkeyRouterAdapter<T, IdType>> createState() => MonkeyRouterAdapterState<T, IdType>();

  /// Updates the selection in the URL query paramter.
  static void updateSelection<T extends Identifiable<IdType>, IdType>(BuildContext context, Set<IdType> selection) {
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

    // We can simply update the current urls query parameters
    router.replace(router.state.uri.replace(queryParameters: queryParameters).toString());
  }

  /// Updates the viewing items
  static void updateViewingItems<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    Set<IdType> viewingItems,
  ) {
    final router = GoRouter.of(context);
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();

    // We should see if we can use the current query parameters, we will
    // need to filter out the filters and sort options otherwise removing them
    // will not work

    final viewingParam = routeConfig.serialiseIdType(viewingItems);

    final showingDetail = context.read<LdMonkeyShowingDetail<T, IdType>>();

    if (showingDetail) {
      if (viewingItems.isEmpty) {
        router.pop();
      } else {
        router.replace(
          Uri.parse("${routeConfig.basePath}/$viewingParam")
              .replace(queryParameters: router.state.uri.queryParameters)
              .toString(),
        );
      }
    } else {
      if (viewingItems.isNotEmpty) {
        router.push(
          Uri.parse("${routeConfig.basePath}/$viewingParam")
              .replace(queryParameters: router.state.uri.queryParameters)
              .toString(),
        );
      }
    }
  }

  static void updateShowSelectionControls<T extends Identifiable<IdType>, IdType>(
      BuildContext context, bool showSelectionControls) {
    final router = GoRouter.of(context);
    final queryParameters = <String, dynamic>{...router.state.uri.queryParameters};
    final routeConfig = context.read<LdMonkeyRouteConfig<T, IdType>>();
    if (showSelectionControls) {
      queryParameters[routeConfig.showSelectionControlsQueryKey] = 'true';
    } else {
      queryParameters.remove(routeConfig.showSelectionControlsQueryKey);
    }
    router.replace(router.state.uri.replace(queryParameters: queryParameters).toString());
  }
}

typedef LdMonkeyShowingDetail<T extends Identifiable<IdType>, IdType> = bool;

class MonkeyRouterAdapterState<T extends Identifiable<IdType>, IdType> extends State<MonkeyRouterAdapter<T, IdType>> {
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
                    final sortOption =
                        sortOptionsLeft.firstWhereOrNull((sortOption) => sortOption.name == sortEntry.split("-")[0]);
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
