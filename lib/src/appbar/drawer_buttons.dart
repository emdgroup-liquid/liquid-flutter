import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class OpenDrawerButton extends StatelessWidget {
  const OpenDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<LdScaffoldLayoutState?>();

    final icon = layoutState?.isSideBySide ?? false ? LucideIcons.panelLeftOpen : LucideIcons.menu;
    final scaffold = context.findAncestorStateOfType<LdScaffoldState>();
    return Tooltip(
      message: LiquidLocalizations.of(context).showDrawer,
      child: LdButtonGhost(
        size: LdSize.s,
        child: Icon(icon),
        onPressed: () => scaffold?.openDrawer(),
      ),
    );
  }
}

class CloseDrawerButton extends StatelessWidget {
  const CloseDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<LdScaffoldLayoutState?>();

    final icon = layoutState?.isSideBySide ?? false ? LucideIcons.panelLeftClose : LucideIcons.chevronRight;
    return Tooltip(
      message: LiquidLocalizations.of(context).hideDrawer,
      child: LdButtonGhost(
        size: LdSize.s,
        child: Icon(icon),
        onPressed: () {
          Navigator.of(context).maybePop();
        },
      ),
    );
  }
}
