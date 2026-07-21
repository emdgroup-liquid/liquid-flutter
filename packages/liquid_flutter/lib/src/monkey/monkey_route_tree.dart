import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/modal/modal.dart';
import 'package:liquid_flutter/src/monkey/actions/actions.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/ld_model.dart';
import 'package:liquid_flutter/src/monkey/ld_monkey_route_definitions.dart';
import 'package:liquid_flutter/src/monkey/monkey_effective_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/monkey_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_scope.dart';
import 'package:provider/provider.dart';

/// One level in a stacked monkey route tree (parent detail hosts the next
/// shell; optional [detailPathPrefix] before `:viewing_*`).
///
/// Each [routeConfig] must use a unique [LdMonkeyRouteConfig.itemName] across
/// the whole tree so path params, query keys, and [GoRoute.name]s do not
/// collide.
class MonkeyRouteNode<T extends Identifiable<IdType>, IdType> {
  const MonkeyRouteNode({
    required this.routeConfig,
    required this.masterPage,
    required this.detailPage,
    required this.modelBuilder,
    this.createPage,
    required this.filtersBuilder,
    required this.sortOptionsBuilder,
    required this.actions,
    this.routeDefinitionsLoadingText,
    this.detailInDialog = false,
    this.shellBuilder,
    this.child,
    this.detailPathPrefix,
    this.layoutMode = LdMonkeyLayoutMode.auto,
    this.reflowBreakpoint,
    this.detailPanelFraction,
    this.allowMultipleSelection,
    this.immediateViewSelection,
    this.scopeStorageKey,
  });

  final LdMonkeyRouteConfig<T, IdType> routeConfig;

  final Widget masterPage;

  final Widget detailPage;

  final Widget? createPage;

  final LdMonkeyFiltersBuilder<T, IdType> filtersBuilder;

  final LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder;

  final LdMonkeyRouteDefinitionsLoadingTextBuilder? routeDefinitionsLoadingText;

  final List<LdMonkeyAction<T, IdType>> actions;

  final LdModel<T, IdType, Object?, Object?> Function(
    BuildContext context,
    GoRouterState routeState,
  ) modelBuilder;

  final bool detailInDialog;

  final Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder;

  /// Deeper monkey; parent [detailPage] is usually the same widget as this
  /// level's [masterPage] (stacked master-detail).
  ///
  /// Typed as [MonkeyRouteNode] with `dynamic` type arguments so a child
  /// level may use a different [Identifiable] type than its parent.
  final MonkeyRouteNode<dynamic, dynamic>? child;

  /// Static segment before `:viewing_<itemName>` for this level's detail route
  /// (no slashes), e.g. `files` → `files/:viewing_file`.
  final String? detailPathPrefix;

  final LdMonkeyLayoutMode layoutMode;

  final double? reflowBreakpoint;

  final double? detailPanelFraction;

  final bool? allowMultipleSelection;

  final bool? immediateViewSelection;

  /// Overrides [defaultMonkeyScopeStorageKey] for this subtree.
  final String Function(MonkeyRouteNode<dynamic, dynamic> root, GoRouterState state)? scopeStorageKey;

  /// [KeyedSubtree] + [LdMonkeyRouteScope] for this level (nested shells).
  Widget buildMonkeyScopeSubtree({
    required MonkeyRouteNode<dynamic, dynamic> root,
    required GoRouterState routeState,
    required Widget child,
  }) {
    final storageKey = scopeStorageKey?.call(root, routeState) ??
        defaultMonkeyScopeStorageKey(root, this as MonkeyRouteNode<dynamic, dynamic>, routeState);
    return KeyedSubtree(
      key: ValueKey<String>(storageKey),
      child: LdMonkeyRouteScope<T, IdType>(
        routeState: routeState,
        routeConfig: routeConfig,
        actions: actions,
        filtersBuilder: filtersBuilder,
        sortOptionsBuilder: sortOptionsBuilder,
        routeDefinitionsLoadingText: routeDefinitionsLoadingText,
        modelBuilder: modelBuilder,
        masterPage: masterPage,
        shellBuilder: shellBuilder,
        layoutMode: layoutMode,
        reflowBreakpoint: reflowBreakpoint,
        detailPanelFraction: detailPanelFraction,
        allowMultipleSelection: allowMultipleSelection,
        immediateViewSelection: immediateViewSelection,
        child: child,
      ),
    );
  }
}

/// Builds a [ShellRoute] list for a stacked monkey tree of arbitrary depth.
///
/// URLs look like: `[masterPath]/:[viewing_root](/[prefix_i]/:[viewing_i])*`.
///
/// In a stacked master‑detail tree the parent's [MonkeyRouteNode.detailPage]
/// is rendered as the next level's master page. To make that work each
/// [LdMonkeyRouteScope] must already be active at the parent's detail
/// position, so each detail [GoRoute] is wrapped in a [ShellRoute] that
/// provides the child level's scope (when a child exists).
List<RouteBase> buildMonkeyRouteTree<T extends Identifiable<IdType>, IdType>({
  required String masterPath,
  required MonkeyRouteNode<T, IdType> root,
  List<RouteBase>? additionalMasterRoutes,
  List<RouteBase>? additionalDetailRoutes,
}) {
  final rootNode = root as MonkeyRouteNode<dynamic, dynamic>;
  return [
    ShellRoute(
      routes: [
        GoRoute(
          name: root.routeConfig.masterRouteName,
          path: masterPath,
          pageBuilder: (context, state) => MaterialPage<void>(
            child: root.masterPage,
          ),
          routes: [
            ...?additionalMasterRoutes,
            ..._buildDetailRoutes(
              root: rootNode,
              node: rootNode,
              detailPath: ':${root.routeConfig.viewingParamName}',
              additionalDetailRoutes: additionalDetailRoutes,
            ),
          ],
        ),
      ],
      builder: (context, routeState, child) {
        return LdMonkeyRouteScope<T, IdType>(
          routeState: routeState,
          routeConfig: root.routeConfig,
          actions: root.actions,
          filtersBuilder: root.filtersBuilder,
          sortOptionsBuilder: root.sortOptionsBuilder,
          routeDefinitionsLoadingText: root.routeDefinitionsLoadingText,
          modelBuilder: root.modelBuilder,
          masterPage: root.masterPage,
          shellBuilder: root.shellBuilder,
          layoutMode: root.layoutMode,
          reflowBreakpoint: root.reflowBreakpoint,
          detailPanelFraction: root.detailPanelFraction,
          allowMultipleSelection: root.allowMultipleSelection,
          immediateViewSelection: root.immediateViewSelection,
          child: child,
        );
      },
    ),
  ];
}

Page<void> _detailPageBuilder(
  BuildContext context,
  Widget detailPage,
  bool detailInDialog,
) {
  final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();

  if (effectiveLayout != LdMonkeyEffectiveLayoutMode.sideBySide) {
    if (detailInDialog) {
      return LdModalPage(
        builder: (context) => LdModalRoute(
          context: context,
          pageBuilder: (context) => detailPage,
        ),
      );
    }

    return MaterialPage<void>(
      child: detailPage,
    );
  }
  return NoTransitionPage<void>(
    child: detailPage,
  );
}

/// Builds the detail [GoRoute] for [node] and, when [node] has a child,
/// wraps it in a [ShellRoute] that provides the child level's
/// [LdMonkeyRouteScope].
///
/// The child's scope must be active at [node]'s detail position because the
/// parent's detail page is also rendered as the child's master page in the
/// stacked master‑detail layout.
List<RouteBase> _buildDetailRoutes({
  required MonkeyRouteNode<dynamic, dynamic> root,
  required MonkeyRouteNode<dynamic, dynamic> node,
  required String detailPath,
  List<RouteBase>? additionalDetailRoutes,
}) {
  final createPage = node.createPage;
  final createRoute = createPage != null
      ? GoRoute(
          name: node.routeConfig.createRouteName,
          path: node.routeConfig.createPathSegment,
          pageBuilder: (context, goState) => _detailPageBuilder(
            context,
            createPage,
            node.detailInDialog,
          ),
        )
      : null;

  final detailRoute = GoRoute(
    name: node.routeConfig.detailRouteName,
    path: detailPath,
    pageBuilder: (context, goState) => _detailPageBuilder(
      context,
      node.detailPage,
      node.detailInDialog,
    ),
    routes: [
      ...?additionalDetailRoutes,
      if (node.child != null)
        ..._buildDetailRoutes(
          root: root,
          node: node.child!,
          detailPath: _detailPathSegment(node.child!),
        ),
    ],
  );

  final routes = <RouteBase>[
    if (createRoute != null) createRoute,
    detailRoute,
  ];

  if (node.child == null) {
    return routes;
  }

  return [
    ShellRoute(
      builder: (context, routeState, child) {
        return node.child!.buildMonkeyScopeSubtree(
          root: root,
          routeState: routeState,
          child: child,
        );
      },
      routes: routes,
    ),
  ];
}

String _detailPathSegment(MonkeyRouteNode<dynamic, dynamic> node) {
  final param = ':${node.routeConfig.viewingParamName}';
  final prefix = node.detailPathPrefix?.trim().replaceAll(RegExp(r'^/+|/+$'), '') ?? '';
  if (prefix.isEmpty) {
    return param;
  }
  return '$prefix/$param';
}

/// Default scope key: `|`‑joined values of the ancestor `viewing_*` path
/// params from [root] up to (but not including) [scope], in tree order.
///
/// [scope]'s own `viewing_*` param identifies the currently selected item
/// within this scope, not the scope itself, so excluding it keeps the scope
/// (and its repository) stable while navigating between sibling items.
String defaultMonkeyScopeStorageKey(
  MonkeyRouteNode<dynamic, dynamic> root,
  MonkeyRouteNode<dynamic, dynamic> scope,
  GoRouterState state,
) {
  final path = <MonkeyRouteNode<dynamic, dynamic>>[];
  if (!_collectPathTo(root, scope, path)) {
    return '';
  }
  if (path.isNotEmpty) {
    path.removeLast();
  }
  return path.map((n) => state.pathParameters[n.routeConfig.viewingParamName] ?? '').join('|');
}

bool _collectPathTo(
  MonkeyRouteNode<dynamic, dynamic>? node,
  MonkeyRouteNode<dynamic, dynamic> target,
  List<MonkeyRouteNode<dynamic, dynamic>> path,
) {
  if (node == null) {
    return false;
  }
  path.add(node);
  if (identical(node, target)) {
    return true;
  }
  if (_collectPathTo(node.child, target, path)) {
    return true;
  }
  path.removeLast();
  return false;
}
