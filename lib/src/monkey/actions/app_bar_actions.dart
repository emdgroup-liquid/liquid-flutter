import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

List<LdMonkeyAction<T, IdType>> ldMonkeyAppBarActionsForLocation<T extends Identifiable<IdType>, IdType>(
    BuildContext context, LdMonkeyActionLocation location) {
  final shell = LdMonkeyShellState.of<T, IdType>(context);

  final actions = shell.actions.where((e) => e.isVisible(context, location: location)).toList();
  return actions;
}
