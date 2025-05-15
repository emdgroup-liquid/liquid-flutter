import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Configuration for a master detail shell route.
class LdMasterDetailShellRouteConfig<T> {
  /// The base path for the master detail view.
  final String basePath;

  /// The path, if the detail view is shown (either as a page, dialog, or in
  /// a separate view).
  final String detailPath;

  /// A function to get the item ID from an item.
  final String Function(T item) itemIdGetter;

  /// A function to retrieve an item from an ID.
  final T? Function(String id) itemProvider;

  /// Gets the detail path parameter name from the detail path.
  String get detailPathParam => detailPath
      .split('/')
      .lastWhere((segment) => segment.startsWith(':'))
      .substring(1);

  /// Creates a new shell route configuration.
  LdMasterDetailShellRouteConfig({
    required this.basePath,
    required this.detailPath,
    required this.itemIdGetter,
    required this.itemProvider,
  });
}

/// Helper function to create a router configuration that uses the master detail component
/// as a shell route.
ShellRoute createMasterDetailShellRoute<T>({
  required Widget child,
  required LdMasterDetailShellRouteConfig<T> routeConfig,
  Page Function(BuildContext context, GoRouterState state, Widget child)?
      pageBuilder,
}) {
  pageBuilder ??= (context, state, child) => NoTransitionPage<void>(
        key: state.pageKey,
        child: child,
      );
  return ShellRoute(
    // _ is the placeholder from the dummy widgets of the routes
    pageBuilder: (context, state, _) => pageBuilder!(
      context,
      state,
      // We wrap the child in a provider to make the route configuration
      // available to LdMasterDetail
      Provider<LdMasterDetailShellRouteConfig<T>?>.value(
        value: routeConfig,
        child: child,
      ),
    ),

    // We just define the routes with a dummy builder, as the actual
    // building is done in the childBuilder
    routes: [
      // Dummy base route
      GoRoute(
        path: routeConfig.basePath,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      // Dummy detail route
      GoRoute(
        path: "/${routeConfig.basePath}/${routeConfig.detailPath}",
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}
