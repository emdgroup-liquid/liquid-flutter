import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Configuration for a master detail shell route.
class LdMasterDetailShellRouteConfig<T> {
  final String _id;
  String get id => _id;

  /// The base path for the master detail view.
  final String basePath;

  /// The path, if the detail view is shown (either as a page, dialog, or in
  /// a separate view).
  final String detailPath;

  /// A function to get the item ID from an item.
  final String Function(T item) itemToPath;

  /// A function to retrieve an item from a path parameter.
  final FutureOr<T?> Function(String pathParam) pathToItem;

  /// Gets the detail path parameter name from the detail path.
  String get detailPathParam => detailPath.split('/').lastWhere((segment) => segment.startsWith(':')).substring(1);

  /// Creates a new shell route configuration.
  LdMasterDetailShellRouteConfig({
    required this.basePath,
    required this.detailPath,
    required this.itemToPath,
    required this.pathToItem,
    String? id,
  }) : _id = id ?? T.toString();
}

/// Helper function to create a router configuration that uses the master detail component
/// as a shell route.
ShellRoute createMasterDetailShellRoute<T>({
  required Widget child,
  required LdMasterDetailShellRouteConfig<T> routeConfig,
  Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
}) {
  return createMasterDetailCompositeShellRoute(
    child: child,
    routeConfigs: [routeConfig],
    pageBuilder: pageBuilder,
  );
}

ShellRoute createMasterDetailCompositeShellRoute({
  required Widget child,
  required List<LdMasterDetailShellRouteConfig> routeConfigs,
  Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
}) {
  pageBuilder ??= (context, state, child) => NoTransitionPage<void>(
        key: state.pageKey,
        child: child,
      );

  // Create a map of routeConfig.id to routeConfig for easy lookup
  // from [LdMasterDetail]
  final routeConfigMap = <String, LdMasterDetailShellRouteConfig>{};
  for (var config in routeConfigs) {
    routeConfigMap[config.id] = config;
  }

  return ShellRoute(
    pageBuilder: (context, state, _) => pageBuilder!(
        context,
        state,
        Provider<Map<String, LdMasterDetailShellRouteConfig>>.value(
          value: routeConfigMap,
          child: child,
        )),
    routes: [
      ...routeConfigs
          .map((routeConfig) => [
                GoRoute(
                  path: routeConfig.basePath,
                  builder: (context, state) => const SizedBox.shrink(),
                ),
                GoRoute(
                  path: "/${routeConfig.basePath}/${routeConfig.detailPath}",
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ])
          .expand((element) => element)
          .toList(growable: false),
    ],
  );
}
