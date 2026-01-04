import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<T extends Identifiable<IdType>, IdType> {
  final Set<IdType> selection;
  final Set<IdType> viewing;

  LdMonkeySelection({
    required this.selection,
    required this.viewing,
  });

  static LdMonkeySelection<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeySelection<T, IdType>>() : context.read<LdMonkeySelection<T, IdType>>();
  }

  static Set<IdType> adaptive<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
    LdMonkeyActionLocation? location,
  }) {
    location ??= context.read<LdMonkeyActionLocation>();

    final selection =
        listen ? context.watch<LdMonkeySelection<T, IdType>>() : context.read<LdMonkeySelection<T, IdType>>();

    return switch (location) {
      LdMonkeyActionLocation.detailAppBar => selection.viewing,
      LdMonkeyActionLocation.detailSecondary => selection.viewing,
      LdMonkeyActionLocation.context => selection.selection,
      LdMonkeyActionLocation.masterAppBar => selection.selection,
      LdMonkeyActionLocation.masterSecondary => selection.selection,
    };
  }

  static Future<List<T>> getSelectedItems<T extends Identifiable<IdType>, IdType>(BuildContext context) async {
    final selection = of<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);

    return Future.wait(selection.selection.map((id) => (repository.getById(id))));
  }

  static Future<List<T>> getViewingItems<T extends Identifiable<IdType>, IdType>(BuildContext context) async {
    final selection = of<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);

    return Future.wait(selection.viewing.map((id) => (repository.getById(id))));
  }

  @override
  bool operator ==(Object other) {
    if (other is LdMonkeySelection<T, IdType>) {
      return setEquals(selection, other.selection) && setEquals(viewing, other.viewing);
    }
    return false;
  }

  @override
  int get hashCode => selection.hashCode ^ viewing.hashCode;
}
