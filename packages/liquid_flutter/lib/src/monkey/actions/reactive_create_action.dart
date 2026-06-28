import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pushes the named create route for this monkey level.
LdMonkeyAction<T, IdType> reactiveCreateAction<T extends Identifiable<IdType>, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  String? tooltip,
}) =>
    LdMonkeyBareChildAction<T, IdType>(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: 0,
        ),
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterSecondary,
          minSelectionCount: 0,
          maxSelectionCount: 0,
        ),
      },
      onTrigger: (ctx) async {
        GoRouter.of(ctx.appContext).pushNamed(routeConfig.createRouteName);
      },
      builder: (ctx, trigger) => LdAppBarAction(
        leading: Icon(LucideIcons.plus),
        onPressed: trigger,
        child: Text(tooltip ?? LiquidLocalizations.of(ctx.appContext).createNew),
      ),
    );
