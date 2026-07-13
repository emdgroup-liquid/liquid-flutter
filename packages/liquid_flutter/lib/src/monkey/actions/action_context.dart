import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Snapshot of monkey action state at build or trigger time.
///
/// Use [selectedIds], [selection], and [listController] for monkey data.
/// Use [model] for typed mutations.
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

  /// List controller for this monkey route.
  final LdListController<T, IdType> listController;

  const LdMonkeyActionContext({
    required this.appContext,
    required this.selectedIds,
    required this.selection,
    required this.location,
    required this.layoutMode,
    required this.listController,
    this.contextItem,
  });

  /// Reads monkey state from [triggerContext] and pairs it with [appContext].
  ///
  /// When [listen] is true the [triggerContext] subscribes to the selection and
  /// the [LdListController], so the surrounding widget rebuilds (and the context
  /// is re-evaluated) whenever the selection or the underlying items change. Use
  /// this when building a context for reactive evaluation such as visibility.
  static LdMonkeyActionContext<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext triggerContext, {
    required BuildContext appContext,
    bool listen = false,
  }) {
    final location = triggerContext.read<LdMonkeyActionLocation>();
    final selection = LdMonkeySelection.of<T, IdType>(triggerContext, listen: listen);
    final layoutMode = triggerContext.read<LdMonkeyEffectiveLayoutMode>();
    final listController =
        listen ? triggerContext.watch<LdListController<T, IdType>>() : LdListController.of<T, IdType>(triggerContext);
    LdPaginatorItem<T>? contextItem = triggerContext.read<LdPaginatorItem<T>?>();

    return LdMonkeyActionContext<T, IdType>(
      appContext: appContext,
      selectedIds: LdMonkeySelection.adaptive<T, IdType>(triggerContext, location: location, listen: listen),
      selection: selection,
      location: location,
      layoutMode: layoutMode,
      listController: listController,
      contextItem: contextItem,
    );
  }

  TModel model<TModel extends LdModel<T, IdType, Object?, Object?>>() =>
      appContext.read<LdListController<T, IdType>>().model as TModel;

  Future<List<T>> getSelectedItems() {
    return Future.wait(selectedIds.map((id) => listController.getById(appContext, id)));
  }

  void updateViewing(Set<IdType> viewing) {
    LdMonkeySelection.updateViewing<T, IdType>(appContext, viewing);
  }

  void updateSelection(Set<IdType> selectionIds) {
    LdMonkeySelection.updateSelection<T, IdType>(appContext, selectionIds);
  }

  void maybeClearSelection() {
    LdMonkeySelection.maybeClearSelection<T, IdType>(appContext);
  }

  void updateShowSelectionControls(bool showSelectionControls) {
    LdMonkeySelection.updateShowSelectionControls<T, IdType>(appContext, showSelectionControls);
  }
}
