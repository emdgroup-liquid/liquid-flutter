import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

typedef BasePath = String;
typedef RouteConfigId = String;
typedef LdMasterDetailRouteConfig = MapEntry<BasePath, Map<RouteConfigId, LdMasterDetailShellRouteConfig>>;

extension LdMasterDetailRouteConfigsX on LdMasterDetailRouteConfig {
  String? get basePath => key;
  String get compositePath {
    return "/$basePath/${value.entries.map((entry) => entry.value.detailPath).join('/')}";
  }

  String compositePathWithParams(Map<String, String> params) {
    String path = basePath ?? '';
    for (var entry in value.entries) {
      if (params.containsKey(entry.value.detailPathParam)) {
        path +=
            '/${entry.value.detailPath.replaceFirst(':${entry.value.detailPathParam}', params[entry.value.detailPathParam]!)}';
      }
    }
    return path;
  }
}

/// Configuration for a master detail shell route.
class LdMasterDetailShellRouteConfig<T> {
  final String _id;
  String get id => _id;

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
  required String basePath,
  required LdMasterDetailShellRouteConfig<T> routeConfig,
  Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
}) {
  return createMasterDetailCompositeShellRoute(
    child: child,
    basePath: basePath,
    routeConfigs: [routeConfig],
    pageBuilder: pageBuilder,
  );
}

ShellRoute createMasterDetailCompositeShellRoute({
  required Widget child,
  required String basePath,
  required List<LdMasterDetailShellRouteConfig> routeConfigs,
  Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
}) {
  pageBuilder ??= (context, state, child) => NoTransitionPage<void>(
        key: state.pageKey,
        child: child,
      );

  // Create a map of routeConfig.id to routeConfig for easy lookup
  // from [LdMasterDetail]
  final map = <String, LdMasterDetailShellRouteConfig>{};
  for (var config in routeConfigs) {
    map[config.id] = config;
  }
  final routeConfig = LdMasterDetailRouteConfig(basePath, map);

  return ShellRoute(
    pageBuilder: (context, state, _) =>
        pageBuilder!(context, state, Provider<LdMasterDetailRouteConfig>.value(value: routeConfig, child: child)),
    routes: [
      GoRoute(
        path: basePath,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      ...routeConfigs
          .map((routeConfig) => [
                GoRoute(
                  path: "/$basePath/${routeConfig.detailPath}",
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ])
          .expand((element) => element)
          .toList(growable: false),
      GoRoute(
        path: routeConfig.compositePath,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}
