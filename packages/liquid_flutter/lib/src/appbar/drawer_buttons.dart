import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class OpenDrawerButton extends StatelessWidget {
  const OpenDrawerButton({super.key, this.drawerParent});

  final LdScaffoldState? drawerParent;

  bool _shouldShow(BuildContext context) {
    if (!context.mounted) return false;
    // Check if drawer slot is body (implies we're inside a drawer layout)
    final drawerSlot = context.watch<LdDrawerSlot?>();

    if (drawerSlot != LdDrawerSlot.body) return false;

    final drawerState = context.watch<LdDrawerState?>();
    if (drawerState == null) return false;
    if (drawerState.isOpen && drawerState.isSideBySide) return false;

    // Show only in the outermost top bar (level 0, position top).
    final metrics = context.read<LdAppBarMetrics?>();
    if (metrics == null) return false;
    return metrics.level == 0 && metrics.position == LdAppBarPosition.top;
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
    // Check if drawer slot is drawer (implies we're inside a drawer layout)
    final drawerSlot = context.watch<LdDrawerSlot?>();
    if (drawerSlot != LdDrawerSlot.drawer) return false;

    final drawerState = context.watch<LdDrawerState?>();
    if (drawerState == null) return false;
    if (!drawerState.isOpen) return false;

    // Show only in the outermost top bar (level 0, position top).
    final metrics = context.read<LdAppBarMetrics?>();
    if (metrics == null) return false;
    return metrics.level == 0 && metrics.position == LdAppBarPosition.top;
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
