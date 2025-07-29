import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType, GroupingCriterion>
    toggleSelectionControls<T extends Identifiable<IdType>, IdType, GroupingCriterion>() =>
        LdMonkeyAction<T, IdType, GroupingCriterion>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              maxSelectionCount: null,
            ),
          },
          buildIcon: (context, selection) {
            final route = LdMonkey.of<T, IdType, GroupingCriterion>(
              context,
              watch: true,
            );
            return route.state.showSelectionControls ? const Icon(LucideIcons.check) : const Icon(LucideIcons.pen);
          },
          buildLabel: (context, selection) {
            final route = LdMonkey.of<T, IdType, GroupingCriterion>(context);
            return route.state.showSelectionControls
                ? LiquidLocalizations.of(context).done
                : LiquidLocalizations.of(context).select;
          },
          submitType: LdLabeledActionSubmitType.none,
          action: (context, selection) {
            final route = LdMonkey.of<T, IdType, GroupingCriterion>(context);
            route.setShowSelectionControls(!route.state.showSelectionControls);
          },
        );
