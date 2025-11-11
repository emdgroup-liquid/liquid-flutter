import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> toggleSelectionControls<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      onShortcutTrigger: (context) async {
        final shellState = LdMonkeyShellState.of<T, IdType>(context);
        shellState.setShowSelectionControls(!shellState.showSelectionControls);
      },
      builder: (context) {
        final shellState = LdMonkeyShellState.of<T, IdType>(context);
        return LdButton(
          child: const Icon(LucideIcons.pen),
          active: shellState.showSelectionControls,
          onPressed: () async {
            final currentlyShowing = shellState.showSelectionControls;
            final selectedItemCount = shellState.selectedItems.length;

            if (currentlyShowing && selectedItemCount > 1) {
              if (await ldConfirmModal(
                context: context,
                title: Text(LiquidLocalizations.of(context).clearSelection),
                description: LiquidLocalizations.of(context).clearSelectionBody(selectedItemCount),
                positive: Text(LiquidLocalizations.of(context).confirm),
                negative: Text(LiquidLocalizations.of(context).cancel),
                useRootNavigator: true,
              )) {
                shellState.setShowSelectionControls(false);
              }
              return;
            }
            shellState.setShowSelectionControls(!shellState.showSelectionControls);
          },
        );
      },
    );
