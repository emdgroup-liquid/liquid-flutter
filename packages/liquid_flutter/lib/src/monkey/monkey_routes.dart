import 'dart:async';

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
  required String basePath,
  required Widget detailPage,
  required Widget masterPage,
  required Future<LdRepository<T, IdType>> Function(BuildContext context) repositoryBuilder,
  required LdMonkeyLayoutMode layoutMode,
  required Set<IdType> Function(String selected) parseSelected,
  required String pathParameterName,
  Widget Function({
    required BuildContext context,
    required GoRouterState routeState,
    required Widget child,
    required String pathParameterName,
    required Widget masterPage,
    required String basePath,
  })? shellBuilder,
  LdModalRoute Function(BuildContext context)? filterModalBuilder,
  bool detailInDialog = false,
}) {
  return [
    ShellRoute(
      routes: [
        GoRoute(
          name: "$basePath-master",
          path: basePath,
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: masterPage,
          ),
          routes: [
            GoRoute(
              name: "$basePath-detail",
              path: "/:selected_$pathParameterName",
              pageBuilder: (context, goState) {
                final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();

                final page = detailPage;

                if (effectiveLayout == LdMonkeyEffectiveLayoutMode.detail) {
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
                    key: goState.pageKey,
                  );
                }
                return NoTransitionPage<void>(
                  key: goState.pageKey,
                  child: page,
                );
              },
            ),
          ],
        ),
      ],
      builder: (context, routeState, child) => shellBuilder != null
          ? shellBuilder(
              context: context,
              routeState: routeState,
              child: child,
              basePath: basePath,
              masterPage: masterPage,
              pathParameterName: pathParameterName,
            )
          : LdMonkeyShell(
              basePath: basePath,
              parseSelected: parseSelected,
              masterPage: masterPage,
              repositoryBuilder: repositoryBuilder,
              layoutMode: layoutMode,
              routeState: routeState,
              pathParameterName: pathParameterName,
              child: child,
            ),
    )
  ];
}
