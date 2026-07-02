import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

enum LdDrawerButtonType {
  open,
  close,
}

class LdDrawerButton extends StatelessWidget {
  const LdDrawerButton({super.key, required this.type});

  final LdDrawerButtonType type;

  static bool isShowing(BuildContext context, LdDrawerButtonType type) {
    if (!context.mounted) return false;

    if (!canShow(context, type)) return false;

    final drawerState = context.watch<LdDrawerState?>();
    if (drawerState == null) return false;

    // in stacked mode the button is always shown since there is overlap between the buttons
    if (!drawerState.isSideBySide) return true;

    return switch (type) {
      LdDrawerButtonType.open => !drawerState.isOpen,
      // the close button is always shown if the drawer is open
      LdDrawerButtonType.close => drawerState.isOpen,
    };
  }

  static bool canShow(BuildContext context, LdDrawerButtonType type) {
    if (!context.mounted) return false;

    final parentShows = LdAppBarImpliedFeature.drawerToggle.shownByParent(context);
    if (parentShows) return false;

    // Check if drawer slot is body (implies we're inside a drawer layout)
    final drawerState = context.watch<LdDrawerState?>();
    final drawerSlot = context.watch<LdDrawerSlot?>();

    if (drawerState == null || drawerSlot == null) return false;

    final slot = switch (type) {
      LdDrawerButtonType.open => LdDrawerSlot.body,
      LdDrawerButtonType.close => LdDrawerSlot.drawer,
    };

    if (drawerSlot != slot) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!canShow(context, type)) return const SizedBox.shrink();

    final drawerState = context.watch<LdDrawerState>();

    final icon = switch (type) {
      LdDrawerButtonType.open => switch (drawerState.isSideBySide) {
          true => LucideIcons.panelLeftOpen,
          _ => LucideIcons.menu,
        },
      LdDrawerButtonType.close => switch (drawerState.isSideBySide) {
          true => LucideIcons.panelLeftClose,
          _ => LucideIcons.chevronRight,
        },
    };

    final showing = isShowing(context, type);

    return LdReveal.quick(
      axes: const {Axis.horizontal},
      initialRevealed: showing,
      revealed: showing,
      child: ExcludeFocus(
        excluding: !showing,
        child: Row(
          children: [
            Tooltip(
              message: switch (type) {
                LdDrawerButtonType.open => LiquidLocalizations.of(context).openDrawer,
                LdDrawerButtonType.close => LiquidLocalizations.of(context).closeDrawer,
              },
              child: LdButton.ghost(
                child: Icon(icon),
                onPressed: () {
                  if (type == LdDrawerButtonType.open) {
                    LdDrawerLayout.openDrawer(context);
                  } else {
                    LdDrawerLayout.closeDrawer(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
