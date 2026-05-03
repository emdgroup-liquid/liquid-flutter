import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Builds the routing configuration for a monkey component.
///
/// Creates a set of [GoRoute] instances that handle:
/// - Master list view at the base [basePath]
/// - Detail view at [basePath]/:selected_[pathParameterName]
/// - Filter modal at [basePath]/filters
///
/// The routes are wrapped in a [ShellRoute] that provides the master-detail
/// layout and handles responsive behavior.
///
/// ## Parameters
///
/// - [basePath]: The base route path for the master view
/// - [pathParameterName]: The name of the path parameter for the selected items
/// - [repositoryBuilder]: Builder function that creates a repository instance asynchronously
/// - [layoutMode]: Controls the layout behavior of the master-detail interface
/// - [shellBuilder]: Optional wrapper widget that can be used to wrap the entire monkey shell
/// - [masterPageBuilder]: Optional builder for the master page (defaults to [LdMonkeyMasterPage])
/// - [detailPageBuilder]: Optional builder for the detail page (defaults to [LdMonkeyDetailPage])
/// - [filterModalBuilder]: Optional builder for the filter modal (defaults to [ldFilterModal])
///
/// Returns a list of routes that can be added to a [GoRouter] configuration.
List<RouteBase> buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required Widget detailPage,
  required Widget masterPage,
  required LdRepository<T, IdType> Function(BuildContext context) repositoryBuilder,
  required List<LdFilterOption<T, IdType>> filters,
  required List<LdSortOption<T, IdType>> sortOptions,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget? monkeyShell,
  LdModalRoute Function(BuildContext context)? filterModalBuilder,
  bool detailInDialog = false,
}) {
  return [
    ShellRoute(
      routes: [
        GoRoute(
          name: routeConfig.masterRouteName,
          path: routeConfig.basePath,
          pageBuilder: (context, state) => MaterialPage<void>(
            child: masterPage,
          ),
          routes: [
            GoRoute(
              name: routeConfig.detailRouteName,
              path: "/:${routeConfig.viewingParamName}",
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
              child: MonkeyRouterAdapter<T, IdType>(
                routeConfig: routeConfig,
                filters: filters,
                sortOptions: sortOptions,
                child: monkeyShell ??
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
