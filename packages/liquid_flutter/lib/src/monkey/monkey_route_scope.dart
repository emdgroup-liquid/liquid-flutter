import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/monkey/actions/actions.dart';
import 'package:liquid_flutter/src/monkey/data/identifiable.dart';
import 'package:liquid_flutter/src/monkey/data/ld_model.dart';
import 'package:liquid_flutter/src/monkey/data/monkey_data_provider.dart';
import 'package:liquid_flutter/src/monkey/ld_monkey_route_definitions.dart';
import 'package:liquid_flutter/src/monkey/ld_monkey_route_definitions_resolver.dart';
import 'package:liquid_flutter/src/monkey/monkey_layout_mode.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_config.dart';
import 'package:liquid_flutter/src/monkey/monkey_router_adapter.dart';
import 'package:liquid_flutter/src/monkey/actions/action_host.dart';
import 'package:liquid_flutter/src/monkey/actions/action_scope.dart';
import 'package:liquid_flutter/src/monkey/monkey_shell.dart';
import 'package:provider/provider.dart';

/// Provider stack for one monkey level: [LdMonkeyRouteConfig], actions,
/// model, list controller, [LdMonkeyRouterAdapter], and shell.
class LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdMonkeyRouteScope({
    super.key,
    required this.routeState,
    required this.routeConfig,
    required this.actions,
    required this.filtersBuilder,
    required this.sortOptionsBuilder,
    required this.modelBuilder,
    required this.masterPage,
    required this.child,
    this.routeDefinitionsLoadingText,
    this.shellBuilder,
    this.layoutMode = LdMonkeyLayoutMode.auto,
    this.reflowBreakpoint,
    this.detailPanelFraction,
    this.allowMultipleSelection,
    this.immediateViewSelection,
    this.reorderHandler,
  });

  final GoRouterState routeState;

  final LdMonkeyRouteConfig<T, IdType> routeConfig;

  final List<LdMonkeyAction<T, IdType>> actions;

  final LdMonkeyFiltersBuilder<T, IdType> filtersBuilder;

  final LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder;

  final LdMonkeyRouteDefinitionsLoadingTextBuilder? routeDefinitionsLoadingText;

  final LdMonkeyReorderHandler<T, IdType>? reorderHandler;

  final LdModel<T, IdType, Object?, Object?> Function(
    BuildContext context,
    GoRouterState routeState,
  ) modelBuilder;

  final Widget masterPage;

  final Widget child;

  final Widget Function(BuildContext context, GoRouterState state, Widget child)? shellBuilder;

  final LdMonkeyLayoutMode layoutMode;

  final double? reflowBreakpoint;

  final double? detailPanelFraction;

  final bool? allowMultipleSelection;

  final bool? immediateViewSelection;

  @override
  Widget build(BuildContext context) {
    return Provider<LdMonkeyRouteConfig<T, IdType>>.value(
      value: routeConfig,
      child: Provider<LdMonkeyReorderHandler<T, IdType>?>.value(
        value: reorderHandler,
        child: Provider<LdMonkeyActions<T, IdType>>.value(
          value: actions,
          child: Provider<LdMonkeyActionScope<T, IdType>>(
            create: (_) => LdMonkeyActionScope<T, IdType>(),
            child: LdMonkeyDataProvider<T, IdType, LdModel<T, IdType, Object?, Object?>>(
              modelBuilder: (context) => modelBuilder(context, routeState),
              child: LdMonkeyRouteDefinitionsResolver<T, IdType>(
                filtersBuilder: filtersBuilder,
                sortOptionsBuilder: sortOptionsBuilder,
                routeDefinitionsLoadingText: routeDefinitionsLoadingText,
                child: (context, resolved) => LdMonkeyRouterAdapter<T, IdType>(
                  routeConfig: routeConfig,
                  filters: resolved.filters.toList(),
                  sortOptions: resolved.sortOptions,
                  child: LdMonkeyActionHost<T, IdType>(
                    actions: actions,
                    child: shellBuilder?.call(context, routeState, child) ??
                        LdMonkeyShell<T, IdType>(
                          masterPage: masterPage,
                          layoutMode: layoutMode,
                          reflowBreakpoint: reflowBreakpoint ?? 600,
                          detailPanelFraction: detailPanelFraction ?? 0.3,
                          allowMultipleSelection: allowMultipleSelection ?? true,
                          immediateViewSelection: immediateViewSelection,
                          child: child,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
