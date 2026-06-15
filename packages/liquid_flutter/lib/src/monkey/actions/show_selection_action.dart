import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showSelection<T extends Identifiable<IdType>, IdType>() => LdMonkeyBareChildAction<T, IdType>(
      appBarOverflowMode: LdAppBarActionOverflowMode.pinned,
      onTrigger: (ctx) async {
        if (ctx.selection.selection.isNotEmpty) {
          ctx.updateViewing(ctx.selection.selection);
        }
      },
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterSecondary,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
      },
      builder: (ctx, trigger) {
        final shouldShow =
            ctx.selection.selection.isNotEmpty && !setEquals(ctx.selection.selection, ctx.selection.viewing);

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return LdAppBarAction(
          key: const Key('show_selection'),
          buttonMode: LdButtonMode.filled,
          leading: const Icon(LucideIcons.eye),
          compactMode: LdAppBarActionCompactMode.never,
          onPressed: trigger,
          child: Text(LiquidLocalizations.of(ctx.appContext).showSelection),
        );
      },
    );
