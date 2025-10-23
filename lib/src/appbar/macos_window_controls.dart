import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class MacOSWindowControls extends StatelessWidget {
  const MacOSWindowControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (LdTheme.of(context).platform != LdPlatform.macos) {
      return const SizedBox.shrink();
    }

    final layoutState = context.watch<LdScaffoldLayoutState?>();
    final level = layoutState?.level;

    final isAppBar = layoutState?.slot == LdScaffoldSlot.appBar;
    final isDrawer = layoutState?.parentLayoutState?.slot == LdScaffoldSlot.drawer;

    final isDrawerOpen = layoutState?.isDrawerOpen ?? false;
    final isParentDrawerOpen = layoutState?.parentLayoutState?.isDrawerOpen ?? false;

    final showWindowControls =
        isAppBar && (isDrawer && isParentDrawerOpen && level == 1 || !isDrawer && !isDrawerOpen && level == 0);

    if (!showWindowControls) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Tooltip(
          message: LiquidLocalizations.of(context).close,
          child: LdButtonGhost(
            size: LdSize.xs,
            color: LdTheme.of(context).error,
            child: const Icon(Icons.circle, size: 14),
            onPressed: () {
              LdAppBar.callbacks?.onClose?.call();
            },
          ),
        ),
        Tooltip(
          message: LiquidLocalizations.of(context).minimize,
          child: LdButtonGhost(
            size: LdSize.xs,
            color: LdTheme.of(context).warning,
            child: const Icon(Icons.circle, size: 14),
            onPressed: () {
              LdAppBar.callbacks?.onMinimize?.call();
            },
          ),
        ),
        Tooltip(
          message: LiquidLocalizations.of(context).maximize,
          child: LdButtonGhost(
            size: LdSize.xs,
            color: LdTheme.of(context).success,
            child: const Icon(Icons.circle, size: 14),
            onPressed: () {
              LdAppBar.callbacks?.onMaximize?.call();
            },
          ),
        ),
      ],
    );
  }
}
