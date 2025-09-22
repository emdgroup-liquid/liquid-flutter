import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> toggleSelectionControls<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyAction<T, IdType>(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      buildIcon: (context) {
        final route = LdMonkey.of<T, IdType>(
          context,
          watch: true,
        );
        return route.state.showSelectionControls ? const Icon(LucideIcons.check) : const Icon(LucideIcons.pen);
      },
      buildLabel: (
        context,
      ) {
        final route = LdMonkey.of<T, IdType>(context);
        return route.state.showSelectionControls
            ? LiquidLocalizations.of(context).done
            : LiquidLocalizations.of(context).select;
      },
      submitType: LdLabeledActionType.none,
      action: (context) {
        final route = LdMonkey.of<T, IdType>(context);
        route.setShowSelectionControls(!route.state.showSelectionControls);
      },
    );
