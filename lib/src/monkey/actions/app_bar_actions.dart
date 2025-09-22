import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class LdMonkeyAppBarActions<T extends Identifiable<IdType>, IdType> {
  static ({
    List<LdMonkeyAction<T, IdType>> actions,
    List<SingleChildWidget> Function(BuildContext context) menuProviders,
    bool hasActions,
  }) getActionsAndProviders<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    LdMonkeyActionLocation location,
  ) {
    final route = LdMonkey.of<T, IdType>(context, watch: true);
    final selection = LdMonkeySelection.of<T, IdType>(context, listen: true);

    final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();
    final hasActions = actions.any((e) => e.isVisible(context, location: location));

    List<Provider<Object>> menuProviders(BuildContext context) => [
          Provider<LdMonkey<T, IdType>>.value(value: route),
          Provider<LdMonkeySelection<T, IdType>>.value(value: selection),
          Provider<LdMonkeyContext<T, IdType>>.value(value: LdMonkeyContext.of(context)),
          Provider<LdMonkeyActionLocation>.value(value: location),
        ];

    return (
      actions: actions,
      menuProviders: menuProviders,
      hasActions: hasActions,
    );
  }
}
