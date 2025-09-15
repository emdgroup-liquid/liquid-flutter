import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class LdMonkeyAppBarActions<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  static ({
    List<LdMonkeyAction<T, IdType, GroupingCriterion>> actions,
    List<SingleChildWidget> Function(BuildContext context) menuProviders,
    bool hasActions,
  }) getActionsAndProviders<T extends Identifiable<IdType>, IdType, GroupingCriterion>(
    BuildContext context,
    LdMonkeyActionLocation location,
  ) {
    final route = LdMonkey.of<T, IdType, GroupingCriterion>(context, watch: true);
    final selection = LdMonkeySelection.of<T, IdType, GroupingCriterion>(context);

    final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();
    final hasActions = actions.any((e) => e.isVisible(context, location: location));

    List<Provider<Object>> menuProviders(BuildContext context) => [
          Provider<LdMonkey<T, IdType, GroupingCriterion>>.value(value: route),
          Provider<LdMonkeySelection<T, IdType, GroupingCriterion>>.value(value: selection),
          Provider<LdMonkeyContext<T, IdType, GroupingCriterion>>.value(value: LdMonkeyContext.of(context)),
          Provider<LdMonkeyActionLocation>.value(value: location),
        ];

    return (
      actions: actions,
      menuProviders: menuProviders,
      hasActions: hasActions,
    );
  }
}
