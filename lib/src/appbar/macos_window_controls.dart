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
    final drawerSlot = context.watch<LdDrawerSlot?>();
    final drawerState = context.watch<LdDrawerState?>();

    bool show = false;

    final level = layoutState?.levelForEffectivePosition();

    if (level == 0) {
      if (drawerSlot == null) {
        show = true;
      } else if (drawerSlot == LdDrawerSlot.body) {
        if (!(drawerState?.isOpen ?? false)) {
          show = true;
        }
      } else if (drawerSlot == LdDrawerSlot.drawer) {
        if (drawerState?.isOpen ?? false) {
          show = true;
        }
      }
    }

    if (!show) {
      return const SizedBox.shrink();
    }

    return Row(
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
        ldSpacerL,
      ],
    );
  }
}
