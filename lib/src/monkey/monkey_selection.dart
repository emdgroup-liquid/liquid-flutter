import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<IdType> {
  final Set<IdType> items;

  LdMonkeySelection({required this.items});

  static LdMonkeySelection<IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeySelection<IdType>>() : context.read<LdMonkeySelection<IdType>>();
  }

  @override
  bool operator ==(Object other) {
    if (other is LdMonkeySelection<IdType>) {
      return setEquals(items, other.items);
    }
    return false;
  }

  @override
  int get hashCode => items.hashCode;
}
