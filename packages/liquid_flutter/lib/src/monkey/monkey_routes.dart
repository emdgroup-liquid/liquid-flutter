import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/actions/actions.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/ld_model.dart';
import 'package:liquid_flutter/src/monkey/ld_monkey_route_definitions.dart';
import 'package:liquid_flutter/src/monkey/monkey_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_tree.dart';

/// Builds the routing configuration for a monkey component.
List<RouteBase> buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required String masterPath,
  required Widget detailPage,
  required Widget masterPage,
  required LdModel<T, IdType, Object?, Object?> Function(
    BuildContext context,
    GoRouterState routeState,
  ) modelBuilder,
  required LdMonkeyFiltersBuilder<T, IdType> filtersBuilder,
  required LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder,
  LdMonkeyRouteDefinitionsLoadingTextBuilder? routeDefinitionsLoadingText,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder,
  List<RouteBase>? additionalDetailRoutes,
  List<RouteBase>? additionalMasterRoutes,
  bool detailInDialog = false,
  Widget? createPage,
  LdMonkeyLayoutMode layoutMode = LdMonkeyLayoutMode.auto,
  double? reflowBreakpoint,
  double? detailPanelFraction,
  bool? allowMultipleSelection,
  bool? immediateViewSelection,
}) {
  return buildMonkeyRouteTree<T, IdType>(
    masterPath: masterPath,
    root: MonkeyRouteNode<T, IdType>(
      routeConfig: routeConfig,
      masterPage: masterPage,
      detailPage: detailPage,
      createPage: createPage,
      modelBuilder: modelBuilder,
      filtersBuilder: filtersBuilder,
      sortOptionsBuilder: sortOptionsBuilder,
      routeDefinitionsLoadingText: routeDefinitionsLoadingText,
      actions: actions,
      detailInDialog: detailInDialog,
      shellBuilder: shellBuilder,
      layoutMode: layoutMode,
      reflowBreakpoint: reflowBreakpoint,
      detailPanelFraction: detailPanelFraction,
      allowMultipleSelection: allowMultipleSelection,
      immediateViewSelection: immediateViewSelection,
    ),
    additionalMasterRoutes: additionalMasterRoutes,
    additionalDetailRoutes: additionalDetailRoutes,
  );
}
