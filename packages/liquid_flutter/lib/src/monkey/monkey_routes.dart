import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Builds the routing configuration for a monkey component.
///
/// Creates a set of [GoRoute] instances that handle:
/// - Master list view at [masterPath]
/// - Detail view at `[masterPath]/:viewing_<itemName>`
///
/// The routes are wrapped in a [ShellRoute] that provides the master-detail
/// layout and handles responsive behavior.
///
/// ## Parameters
///
/// - [routeConfig]: Route naming and id (de)serialization for URL state
/// - [masterPath]: Full path for the master [GoRoute] (e.g. `/tasks`). Detail
///   navigation uses [GoRoute.name] from the config, not this string.
/// - [detailPage]: The detail widget rendered for the detail route
/// - [masterPage]: The master widget rendered for the master route
/// - [repositoryBuilder]: Builder function that creates a repository instance asynchronously
/// - [filters]: Available filter options that are synchronized with query params
/// - [sortOptions]: Available sort options that are synchronized with query params
/// - [actions]: Monkey actions available in master/detail contexts
/// - [shellBuilder]: Optional shell wrapper receiving the current [GoRouterState]
///   and nested route [child]
/// - [additionalMasterRoutes]: Optional extra routes nested under the master route
/// - [additionalDetailRoutes]: Optional extra routes nested under the detail route
/// - [detailInDialog]: Shows detail in an [LdModalRoute] when not side-by-side
///
/// Returns a list of routes that can be added to a [GoRouter] configuration.
List<RouteBase> buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required String masterPath,
  required Widget detailPage,
  required Widget masterPage,
  required LdRepository<T, IdType> Function(BuildContext context) repositoryBuilder,
  required List<LdFilterOption<T, IdType>> filters,
  required List<LdSortOption<T, IdType>> sortOptions,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder,
  List<RouteBase>? additionalDetailRoutes,
  List<RouteBase>? additionalMasterRoutes,
  bool detailInDialog = false,
}) {
  return [
    ShellRoute(
      routes: [
        GoRoute(
          name: routeConfig.masterRouteName,
          path: masterPath,
          pageBuilder: (context, state) => MaterialPage<void>(
            child: masterPage,
          ),
          routes: [
            ...additionalMasterRoutes ?? [],
            GoRoute(
              name: routeConfig.detailRouteName,
              path: ":${routeConfig.viewingParamName}",
              routes: additionalDetailRoutes ?? [],
              pageBuilder: (context, goState) {
                final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();

                final page = detailPage;

                if (effectiveLayout != LdMonkeyEffectiveLayoutMode.sideBySide) {
                  if (detailInDialog) {
                    return LdModalPage(
                      builder: (context) => LdModalRoute(
                        context: context,
                        pageBuilder: (context) => page,
                      ),
                    );
                  }

                  return MaterialPage(
                    child: page,
                  );
                }
                return NoTransitionPage<void>(
                  child: page,
                );
              },
            ),
          ],
        ),
      ],
      builder: (context, routeState, child) {
        return Provider<LdMonkeyRouteConfig<T, IdType>>.value(
          value: routeConfig,
          child: Provider<LdMonkeyActions<T, IdType>>.value(
            value: actions,
            child: LdRepositoryProvider<T, IdType>(
              repositoryBuilder: repositoryBuilder,
              child: LdMonkeyRouterAdapter<T, IdType>(
                routeConfig: routeConfig,
                filters: filters,
                sortOptions: sortOptions,
                child: shellBuilder?.call(context, routeState, child) ??
                    LdMonkeyShell<T, IdType>(
                      masterPage: masterPage,
                      child: child,
                    ),
              ),
            ),
          ),
        );
      },
    ),
  ];
}
