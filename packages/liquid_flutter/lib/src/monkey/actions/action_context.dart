import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Snapshot of monkey action state at build or trigger time.
///
/// Use [selectedIds], [selection], and [repository] for monkey data.
/// Use [appContext] for app-level [Provider] lookups, modals, and navigation.
class LdMonkeyActionContext<T extends Identifiable<IdType>, IdType> {
  /// Full route/app tree — app [Provider] lookups, modals, navigation side-effects.
  final BuildContext appContext;

  /// IDs this action operates on (same rules as [LdMonkeySelection.adaptive]).
  final Set<IdType> selectedIds;

  /// Full selection snapshot at snapshot time.
  final LdMonkeySelection<T, IdType> selection;

  /// Where the user triggered (app bar, context menu, …).
  final LdMonkeyActionLocation location;

  final LdMonkeyEffectiveLayoutMode layoutMode;

  /// Set when [location] is [LdMonkeyActionLocation.context].
  final LdPaginatorItem<T>? contextItem;

  /// Repository for this monkey route.
  final LdRepository<T, IdType> repository;

  const LdMonkeyActionContext({
    required this.appContext,
    required this.selectedIds,
    required this.selection,
    required this.location,
    required this.layoutMode,
    required this.repository,
    this.contextItem,
  });

  /// Reads monkey state from [triggerContext] and pairs it with [appContext].
  static LdMonkeyActionContext<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext triggerContext, {
    required BuildContext appContext,
  }) {
    final location = triggerContext.read<LdMonkeyActionLocation>();
    final selection = LdMonkeySelection.of<T, IdType>(triggerContext);
    final layoutMode = triggerContext.read<LdMonkeyEffectiveLayoutMode>();
    final repository = LdRepository.of<T, IdType>(triggerContext);
    LdPaginatorItem<T>? contextItem;
    try {
      contextItem = triggerContext.read<LdPaginatorItem<T>>();
    } on ProviderNotFoundException {
      contextItem = null;
    }

    return LdMonkeyActionContext<T, IdType>(
      appContext: appContext,
      selectedIds: LdMonkeySelection.adaptive<T, IdType>(triggerContext, location: location),
      selection: selection,
      location: location,
      layoutMode: layoutMode,
      repository: repository,
      contextItem: contextItem,
    );
  }

  Future<List<T>> getSelectedItems() {
    return Future.wait(selectedIds.map(repository.getById));
  }

  void updateViewing(Set<IdType> viewing) {
    LdMonkeySelection.updateViewing<T, IdType>(appContext, viewing);
  }

  void updateSelection(Set<IdType> selectionIds) {
    LdMonkeySelection.updateSelection<T, IdType>(appContext, selectionIds);
  }

  void updateShowSelectionControls(bool showSelectionControls) {
    LdMonkeySelection.updateShowSelectionControls<T, IdType>(appContext, showSelectionControls);
  }
}
