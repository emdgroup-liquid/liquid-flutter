import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/actions/actions.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/repository.dart';
import 'package:liquid_flutter/src/monkey/data/repository_provider.dart';
import 'package:liquid_flutter/src/monkey/filter/ld_filter_option.dart';
import 'package:liquid_flutter/src/monkey/monkey_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/sort/sort_option.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_router_adapter.dart';
import 'package:liquid_flutter/src/monkey/monkey_shell.dart';
import 'package:provider/provider.dart';

/// Provider stack for one monkey level: [LdMonkeyRouteConfig], actions,
/// repository, [LdMonkeyRouterAdapter], and shell.
///
/// Used by [buildMonkeyRouteTree] and may be used manually for custom
/// [GoRouter] shapes.
class LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdMonkeyRouteScope({
    super.key,
    required this.routeState,
    required this.routeConfig,
    required this.actions,
    required this.filters,
    required this.sortOptions,
    required this.repositoryBuilder,
    required this.masterPage,
    required this.child,
    this.shellBuilder,
    this.layoutMode = LdMonkeyLayoutMode.auto,
    this.reflowBreakpoint,
    this.detailPanelFlex,
    this.allowMultipleSelection,
    this.immediateViewSelection,
  });

  final GoRouterState routeState;

  final LdMonkeyRouteConfig<T, IdType> routeConfig;

  final List<LdMonkeyAction<T, IdType>> actions;

  final List<LdFilterOption<T, IdType>> filters;

  final List<LdSortOption<T, IdType>> sortOptions;

  /// Called when the repository is created; [routeState] is the shell state
  /// at build time (updates when navigation changes).
  final LdRepository<T, IdType> Function(
    BuildContext context,
    GoRouterState routeState,
  ) repositoryBuilder;

  final Widget masterPage;

  final Widget child;

  final Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder;

  final LdMonkeyLayoutMode layoutMode;

  final double? reflowBreakpoint;

  final double? detailPanelFlex;

  final bool? allowMultipleSelection;

  final bool? immediateViewSelection;

  @override
  Widget build(BuildContext context) {
    return Provider<LdMonkeyRouteConfig<T, IdType>>.value(
      value: routeConfig,
      child: Provider<LdMonkeyActions<T, IdType>>.value(
        value: actions,
        child: LdRepositoryProvider<T, IdType>(
          repositoryBuilder: (context) => repositoryBuilder(context, routeState),
          child: LdMonkeyRouterAdapter<T, IdType>(
            routeConfig: routeConfig,
            filters: filters,
            sortOptions: sortOptions,
            child: shellBuilder?.call(context, routeState, child) ??
                LdMonkeyShell<T, IdType>(
                  masterPage: masterPage,
                  layoutMode: layoutMode,
                  reflowBreakpoint: reflowBreakpoint ?? 600,
                  detailPanelFlex: detailPanelFlex ?? 2,
                  allowMultipleSelection: allowMultipleSelection ?? true,
                  immediateViewSelection: immediateViewSelection,
                  child: child,
                ),
          ),
        ),
      ),
    );
  }
}
