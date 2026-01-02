import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/drawer_state.dart';
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

    bool show = false;

    final registry = AppBarRegistry.maybeStateOf(context);

    final appBarKey = context.maybeAppBarRegistryKey();

    int level = 1;

    if (appBarKey != null && registry != null) {
      final appBarInfo = registry.getAppBarInfo(appBarKey);

      if (appBarInfo != null && appBarInfo.position == LdAppBarPosition.top) {
        level = registry.getLevel(appBarKey, LdAppBarPosition.top);
      }
    }

    final drawerSlot = context.watch<LdDrawerSlot?>();
    final drawerState = context.watch<LdDrawerState?>();

    if (level == 0) {
      if (drawerSlot == LdDrawerSlot.body) {
        if (!(drawerState?.isOpen ?? false)) {
          show = true;
        }
      } else if (drawerSlot == LdDrawerSlot.drawer) {
        if (drawerState?.isOpen ?? false) {
          show = true;
        }
      }
    }

    return LdReveal.quick(
      revealed: show,
      initialRevealed: show,
      axes: const {Axis.horizontal},
      child: Row(
        children: [
          Tooltip(
            message: LiquidLocalizations.of(context).close,
            child: LdButton.ghost(
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
            child: LdButton.ghost(
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
            child: LdButton.ghost(
              size: LdSize.xs,
              color: LdTheme.of(context).success,
              child: const Icon(Icons.circle, size: 14),
              onPressed: () {
                LdAppBar.callbacks?.onMaximize?.call();
              },
            ),
          ),
          ldSpacerM,
        ],
      ),
    );
  }
}
