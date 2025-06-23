import 'package:liquid_flutter/liquid_flutter.dart';

LdMasterDetailAction<T, IdType, GroupingCriterion>
    toggleSelectionControls<T extends Identifiable<IdType>, IdType, GroupingCriterion>() =>
        LdMasterDetailAction<T, IdType, GroupingCriterion>(
          visibility: {
            LdMasterDetailActionVisibility(
              location: LdMasterDetailActionLocation.masterAppBar,
              minSelectionCount: 0,
              maxSelectionCount: null,
            ),
          },
          buildLabel: (context, selection) {
            final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);
            return route.state.showSelectionControls
                ? LiquidLocalizations.of(context).done
                : LiquidLocalizations.of(context).select;
          },
          submitType: LdLabeledActionSubmitType.none,
          action: (context, selection) {
            final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);
            route.setShowSelectionControls(!route.state.showSelectionControls);
          },
        );
