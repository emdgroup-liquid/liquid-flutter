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
}
