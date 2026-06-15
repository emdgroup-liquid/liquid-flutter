import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeySelection<T extends Identifiable<IdType>, IdType> {
  final Set<IdType> selection;
  final Set<IdType> viewing;
  final bool showSelectionControls;

  LdMonkeySelection({
    required this.selection,
    required this.viewing,
    required this.showSelectionControls,
  });

  static LdMonkeySelection<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeySelection<T, IdType>>() : context.read<LdMonkeySelection<T, IdType>>();
  }

  /// Updates the selection in the URL via the central router controller.
  static void updateSelection<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    Set<IdType> selection,
  ) =>
      LdMonkeyRouterController.of<T, IdType>(context).updateSelection(context, selection);

  /// Maybe clear selection if the user confirms
  static void maybeClearSelection<T extends Identifiable<IdType>, IdType>(BuildContext context) async {
    final selection = of<T, IdType>(context);
    if (selection.selection.isNotEmpty) {
      final confirmation = await ldConfirmModal(
        context: context,
        description: LiquidLocalizations.of(context).clearSelectionBody(selection.selection.length),
      );
      if (confirmation && context.mounted) {
        updateSelection<T, IdType>(context, {});
      }
    }
    if (context.mounted) {
      updateShowSelectionControls<T, IdType>(context, false);
    }
  }

  /// Updates the viewing items in the URL via the central router controller.
  static void updateViewing<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    Set<IdType> viewing,
  ) =>
      LdMonkeyRouterController.of<T, IdType>(context).updateViewing(context, viewing);

  /// Toggles the selection controls visibility in the URL via the central
  /// router controller.
  static void updateShowSelectionControls<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
    bool showSelectionControls,
  ) =>
      LdMonkeyRouterController.of<T, IdType>(context).updateShowSelectionControls(context, showSelectionControls);

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
    final selection = adaptive<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);

    return Future.wait(selection.map((id) => (repository.getById(id))));
  }

  static Future<List<T>> getViewingItems<T extends Identifiable<IdType>, IdType>(BuildContext context) async {
    final selection = of<T, IdType>(context).viewing;
    final repository = LdRepository.of<T, IdType>(context);

    return Future.wait(selection.map((id) => (repository.getById(id))));
  }

  @override
  bool operator ==(Object other) {
    if (other is LdMonkeySelection<T, IdType>) {
      return setEquals(selection, other.selection) &&
          setEquals(viewing, other.viewing) &&
          showSelectionControls == other.showSelectionControls;
    }
    return false;
  }

  @override
  int get hashCode => selection.hashCode ^ viewing.hashCode;
}
