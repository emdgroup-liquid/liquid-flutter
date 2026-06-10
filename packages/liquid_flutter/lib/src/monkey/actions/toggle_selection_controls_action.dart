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
      onTrigger: (ctx) async {
        ctx.updateShowSelectionControls(!ctx.selection.showSelectionControls);
      },
      builder: (ctx, trigger) {
        return LdAppBarAction(
          key: const Key('toggle_selection_controls'),
          leading: const Icon(LucideIcons.pen),
          active: ctx.selection.showSelectionControls,
          onPressed: () async {
            final locale = LiquidLocalizations.of(ctx.appContext);

            if (ctx.selection.selection.isNotEmpty && ctx.selection.showSelectionControls) {
              final confirmation = await ldConfirmModal(
                context: ctx.appContext,
                description: locale.clearSelectionBody(ctx.selection.selection.length),
                positive: Text(locale.clearSelection),
                negative: Text(locale.cancel),
                useRootNavigator: true,
              );

              if (!confirmation) {
                return;
              }
              if (ctx.selection.selection.isNotEmpty &&
                  ctx.selection.showSelectionControls &&
                  ctx.appContext.mounted) {
                ctx.updateViewing({});
                ctx.updateSelection({});
              }
            }

            await Future.delayed(const Duration(milliseconds: 300));

            if (!ctx.appContext.mounted) {
              return;
            }

            ctx.updateShowSelectionControls(!ctx.selection.showSelectionControls);
          },
          child: Text(
            ctx.selection.showSelectionControls
                ? LiquidLocalizations.of(ctx.appContext).done
                : LiquidLocalizations.of(ctx.appContext).select,
          ),
        );
      },
    );
