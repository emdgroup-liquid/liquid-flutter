import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class MacOSWindowControls extends StatelessWidget {
  const MacOSWindowControls({
    super.key,
  });

  static bool canShow(BuildContext context) {
    if (!context.mounted) return false;

    if (LdTheme.of(context).platform != LdPlatform.macos) return false;

    final parentShows = LdAppBarImpliedFeature.windowControls.shownByParent(context);
    if (parentShows) return false;

    if (context.isInLdModal) return false;

    if (!context.isInTopAppBar) return false;

    return true;
  }

  static bool isShowing(BuildContext context) {
    if (!canShow(context)) return false;

    final slot = context.watch<LdDrawerSlot?>();
    final drawerState = context.watch<LdDrawerState?>();

    if (drawerState == null) return true;

    if (slot == LdDrawerSlot.drawer && drawerState.isOpen) return true;
    if (slot == LdDrawerSlot.body && !drawerState.isOpen) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!canShow(context)) {
      return const SizedBox.shrink();
    }

    final show = isShowing(context);

    return LdReveal.quick(
      revealed: show,
      initialRevealed: show,
      axes: const {Axis.horizontal},
      child: ExcludeFocus(
        excluding: !show,
        child: Row(
          children: [
            Tooltip(
              message: LiquidLocalizations.of(context).close,
              child: LdButton.ghost(
                size: LdSize.xs,
                color: LdTheme.of(context).error,
                child: const Icon(Icons.circle, size: 14),
                onPressed: () {
                  LdAppBarWidget.callbacks?.onClose?.call();
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
                  LdAppBarWidget.callbacks?.onMinimize?.call();
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
                  LdAppBarWidget.callbacks?.onMaximize?.call();
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
