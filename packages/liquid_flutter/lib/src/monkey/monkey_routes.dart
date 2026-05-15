import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/actions/actions.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/repository.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/monkey_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_tree.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';

/// Builds the routing configuration for a monkey component.
///
/// Creates a set of [GoRoute] instances that handle:
/// - Master list view at [masterPath]
/// - Detail view at `[masterPath]/:viewing_<itemName>`
///
/// The routes are wrapped in a [ShellRoute] that provides the master-detail
/// layout and handles responsive behavior.
///
/// For nested monkeys, use [buildMonkeyRouteTree] and [MonkeyRouteNode].
///
/// ## Parameters
///
/// - [routeConfig]: Route naming and id (de)serialization for URL state
/// - [masterPath]: Full path for the master [GoRoute] (e.g. `/tasks`). Detail
///   navigation uses [GoRoute.name] from the config, not this string.
/// - [detailPage]: The detail widget rendered for the detail route
/// - [masterPage]: The master widget rendered for the master route
/// - [repositoryBuilder]: Creates the repository; receives [GoRouterState] so
///   nested routes can read ancestor path parameters.
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
  required LdRepository<T, IdType> Function(
    BuildContext context,
    GoRouterState routeState,
  ) repositoryBuilder,
  required List<LdFilterOption<T, IdType>> filters,
  required List<LdSortOption<T, IdType>> sortOptions,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder,
  List<RouteBase>? additionalDetailRoutes,
  List<RouteBase>? additionalMasterRoutes,
  bool detailInDialog = false,
  LdMonkeyLayoutMode layoutMode = LdMonkeyLayoutMode.auto,
  double? reflowBreakpoint,
  double? detailPanelFlex,
  bool? allowMultipleSelection,
  bool? immediateViewSelection,
}) {
  return buildMonkeyRouteTree<T, IdType>(
    masterPath: masterPath,
    root: MonkeyRouteNode<T, IdType>(
      routeConfig: routeConfig,
      masterPage: masterPage,
      detailPage: detailPage,
      repositoryBuilder: repositoryBuilder,
      filters: filters,
      sortOptions: sortOptions,
      actions: actions,
      detailInDialog: detailInDialog,
      shellBuilder: shellBuilder,
      layoutMode: layoutMode,
      reflowBreakpoint: reflowBreakpoint,
      detailPanelFlex: detailPanelFlex,
      allowMultipleSelection: allowMultipleSelection,
      immediateViewSelection: immediateViewSelection,
    ),
    additionalMasterRoutes: additionalMasterRoutes,
    additionalDetailRoutes: additionalDetailRoutes,
  );
}
