import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<T extends Identifiable<IdType>, IdType> {
  final Set<IdType> items;

  LdMonkeySelection({required this.items});

  static LdMonkeySelection<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeySelection<T, IdType>>() : context.read<LdMonkeySelection<T, IdType>>();
  }

  static Future<List<T>> getSelectedItems<T extends Identifiable<IdType>, IdType>(BuildContext context) async {
    final selection = of<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);

    return Future.wait(selection.items.map((id) => (repository.getById(id))));
  }

  @override
  bool operator ==(Object other) {
    if (other is LdMonkeySelection<T, IdType>) {
      return setEquals(items, other.items);
    }
    return false;
  }

  @override
  int get hashCode => items.hashCode;
}
