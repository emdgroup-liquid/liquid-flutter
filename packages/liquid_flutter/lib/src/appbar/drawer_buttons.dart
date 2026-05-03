import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class OpenDrawerButton extends StatelessWidget {
  const OpenDrawerButton({super.key, this.drawerParent});

  final LdScaffoldState? drawerParent;

  bool _shouldShow(BuildContext context) {
    if (!context.mounted) return false;
    // Check if there's a drawer layout above
    final drawerLayout = context.findAncestorWidgetOfExactType<LdDrawerLayout>();
    if (drawerLayout == null) return false;

    // Check if drawer slot is body
    final drawerSlot = context.watch<LdDrawerSlot?>();

    if (drawerSlot != LdDrawerSlot.body) return false;

    final drawerState = context.watch<LdDrawerState?>();
    if (drawerState == null) return false;
    if (drawerState.isOpen && drawerState.isSideBySide) return false;

    // Check if position is top - we need to get the app bar registry and check position
    final registry = AppBarRegistry.maybeStateOf(context);
    if (registry == null) return false;

    final appBarKey = context.maybeAppBarRegistryKey();
    if (appBarKey == null) return false;

    final appBarInfo = registry.getAppBarInfo(appBarKey);
    if (appBarInfo == null || appBarInfo.position != LdAppBarPosition.top) return false;

    // Get the drawer layout's element context to use as limit
    BuildContext? limitContext = context.findAncestorStateOfType<LdDrawerLayoutState>()?.context;

    if (limitContext == null || !limitContext.mounted) return false;

    final higherAppBars = registry.getHigherAppBars(appBarKey, limitToChildrenOf: limitContext);

    // Show button only if this is the app bar with the highest position (no higher app bars)
    return higherAppBars.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final drawerState = context.watch<LdDrawerState?>();
    final icon = drawerState?.isSideBySide ?? false ? LucideIcons.panelLeftOpen : LucideIcons.menu;
    final shouldShow = _shouldShow(context);
    return LdReveal.quick(
      axes: const {Axis.horizontal},
      initialRevealed: shouldShow,
      revealed: shouldShow,
      child: ExcludeFocus(
        excluding: !shouldShow,
        child: Row(
          children: [
            Tooltip(
              message: LiquidLocalizations.of(context).openDrawer,
              child: LdButton.ghost(
                child: Icon(icon),
                onPressed: () {
                  LdDrawerLayout.openDrawer(context);
                },
              ),
            ),
            ldSpacerM,
          ],
        ),
      ),
    );
  }
}

class CloseDrawerButton extends StatelessWidget {
  const CloseDrawerButton({super.key});

  bool _shouldShow(BuildContext context) {
    if (!context.mounted) return false;
    // Check if there's a drawer layout above
    final drawerLayout = context.findAncestorWidgetOfExactType<LdDrawerLayout>();
    if (drawerLayout == null) return false;

    // Check if drawer slot is drawer (not body)
    final drawerSlot = context.watch<LdDrawerSlot?>();
    if (drawerSlot != LdDrawerSlot.drawer) return false;

    final drawerState = context.watch<LdDrawerState?>();
    if (drawerState == null) return false;
    if (!drawerState.isOpen) return false;

    // Check if position is top - we need to get the app bar registry and check position
    final registry = AppBarRegistry.maybeStateOf(context);
    if (registry == null) return false;

    final appBarKey = context.maybeAppBarRegistryKey();
    if (appBarKey == null) return false;

    final appBarInfo = registry.getAppBarInfo(appBarKey);
    if (appBarInfo == null || appBarInfo.position != LdAppBarPosition.top) return false;

    final limitContext = context.findAncestorStateOfType<LdDrawerLayoutState>()?.context;

    if (limitContext == null || !limitContext.mounted) return false;

    // Get higher app bars, limiting to children of drawer layout
    final higherAppBars = registry.getHigherAppBars(appBarKey, limitToChildrenOf: limitContext);

    // Show button only if this is the app bar with the highest position (no higher app bars)
    return higherAppBars.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow(context)) {
      return const SizedBox.shrink();
    }

    final drawerState = context.watch<LdDrawerState?>();
    final icon = drawerState?.isSideBySide ?? false ? LucideIcons.panelLeftClose : LucideIcons.chevronRight;

    return Tooltip(
      message: LiquidLocalizations.of(context).closeDrawer,
      child: LdButton.ghost(
        child: Icon(icon),
        onPressed: () {
          LdDrawerLayout.closeDrawer(context);
        },
      ),
    );
  }
}
