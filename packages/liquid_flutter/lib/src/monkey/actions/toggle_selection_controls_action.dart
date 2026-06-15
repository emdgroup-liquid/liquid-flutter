import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showSelectionControlsAction<T extends Identifiable<IdType>, IdType>() {
  return LdMonkeyBareChildAction<T, IdType>(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterAppBar,
        minSelectionCount: 0,
        maxSelectionCount: null,
        visibleWhenShowingSelectionControls: false,
      ),
    },
    onTrigger: (ctx) async {
      ctx.updateShowSelectionControls(true);
    },
    builder: (ctx, trigger) {
      return LdAppBarAction(
        key: const Key('show_selection_controls'),
        leading: const Icon(LucideIcons.pen),
        active: ctx.selection.showSelectionControls,
        onPressed: () async {
          trigger();
        },
        child: Text(
          LiquidLocalizations.of(ctx.appContext).select,
        ),
      );
    },
  );
}
