import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<T extends Identifiable<IdType>, IdType> {
  final Set<IdType> items;

  LdMonkeySelection({required this.items});

  factory LdMonkeySelection.fromRoute(BuildContext context) {
    final route = LdMonkey.of<T, IdType>(context);
    return LdMonkeySelection(items: route.state.selectedItems);
  }

  static LdMonkeySelection<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeySelection<T, IdType>>() : context.read<LdMonkeySelection<T, IdType>>();
  }
}
