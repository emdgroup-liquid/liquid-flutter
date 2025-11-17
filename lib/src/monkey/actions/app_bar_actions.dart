import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

List<LdMonkeyAction<T, IdType>> ldMonkeyAppBarActionsForLocation<T extends Identifiable<IdType>, IdType>(
    BuildContext context, LdMonkeyActionLocation location) {
  final actions = context.read<LdMonkeyActions<T, IdType>>();

  final visibleActions = actions.where((e) => e.isVisible(context, location: location)).toList();
  return visibleActions;
}
