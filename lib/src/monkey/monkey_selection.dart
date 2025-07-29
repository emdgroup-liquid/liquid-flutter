import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final Set<IdType> items;

  LdMonkeySelection({required this.items});

  factory LdMonkeySelection.fromRoute(BuildContext context) {
    final route = LdMonkey.of<T, IdType, GroupingCriterion>(context);
    return LdMonkeySelection(items: route.state.selectedItems);
  }

  static LdMonkeySelection<T, IdType, GroupingCriterion> of<T extends Identifiable<IdType>, IdType, GroupingCriterion>(
      BuildContext context,
      {bool listen = true}) {
    return listen
        ? context.watch<LdMonkeySelection<T, IdType, GroupingCriterion>>()
        : context.read<LdMonkeySelection<T, IdType, GroupingCriterion>>();
  }
}
