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
        final selection = LdMonkeySelection.of<T, IdType>(context);
        MonkeyRouterAdapter.updateShowSelectionControls<T, IdType>(context, !selection.showSelectionControls);
      },
      builder: (context) {
        final selection = LdMonkeySelection.of<T, IdType>(context, listen: true);
        return LdAppBarAction(
          key: const Key('toggle_selection_controls'),
          leading: const Icon(LucideIcons.pen),
          active: selection.showSelectionControls,
          onPressed: () async {
            final locale = LiquidLocalizations.of(context);

            if (selection.selection.isNotEmpty && selection.showSelectionControls) {
              final confirmation = await ldConfirmModal(
                context: context,
                description: locale.clearSelectionBody(selection.selection.length),
                positive: Text(locale.clearSelection),
                negative: Text(locale.cancel),
                useRootNavigator: true,
              );

              if (!confirmation) {
                return;
              }
              if (selection.selection.isNotEmpty && selection.showSelectionControls && context.mounted) {
                MonkeyRouterAdapter.updateViewingItems<T, IdType>(context, {});
                MonkeyRouterAdapter.updateSelection<T, IdType>(context, {});
              }
            }

            await Future.delayed(Duration(milliseconds: 300));

            if (!context.mounted) {
              return;
            }

            MonkeyRouterAdapter.updateShowSelectionControls<T, IdType>(context, !selection.showSelectionControls);
          },
          child: Builder(builder: (context) {
            final showingSelectionControls =
                LdMonkeySelection.of<T, IdType>(context, listen: true).showSelectionControls;
            return Text(showingSelectionControls
                ? LiquidLocalizations.of(context).done
                : LiquidLocalizations.of(context).select);
          }),
        );
      },
    );
