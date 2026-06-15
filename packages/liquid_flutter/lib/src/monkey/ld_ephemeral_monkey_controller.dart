import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Set<LdFilterOption<T, IdType>> _replaceFilterByName<T extends Identifiable<IdType>, IdType>(
  Iterable<LdFilterOption<T, IdType>> filters,
  LdFilterOption<T, IdType> filter,
) {
  final byName = <String, LdFilterOption<T, IdType>>{
    for (final current in filters) current.name: current,
  };
  byName[filter.name] = filter;
  return byName.values.toSet();
}

/// In-memory monkey navigation state for ephemeral scopes (pickers, tests).
///
/// Does not read or write [GoRouter] URLs. Use [controllerDelegate] with
/// [Provider] — this class is a [ChangeNotifier] and must not be provided as
/// [LdMonkeyRouterController] directly.
class LdEphemeralMonkeyController<T extends Identifiable<IdType>, IdType> extends ChangeNotifier {
  LdEphemeralMonkeyController({
    Set<LdFilterOption<T, IdType>>? filters,
    List<LdSortOption<T, IdType>>? sortOptions,
    Set<IdType>? initialSelection,
    bool showSelectionControls = true,
  })  : _filters = filters ?? {},
        _sortOptions = sortOptions ?? [],
        _selection = {...?initialSelection},
        _showSelectionControls = showSelectionControls;

  Set<LdFilterOption<T, IdType>> _filters;
  List<LdSortOption<T, IdType>> _sortOptions;
  Set<IdType> _selection;
  bool _showSelectionControls;

  Set<LdFilterOption<T, IdType>> get filters => _filters;

  List<LdSortOption<T, IdType>> get sortOptions => _sortOptions;

  Set<IdType> get selection => _selection;

  bool get showSelectionControls => _showSelectionControls;

  LdMonkeySortAndFilterState<T, IdType> get sortAndFilterState => LdMonkeySortAndFilterState<T, IdType>(
        filters: _filters,
        sortOptions: _sortOptions,
      );

  LdMonkeySelection<T, IdType> get monkeySelection => LdMonkeySelection<T, IdType>(
        selection: _selection,
        viewing: const {},
        showSelectionControls: _showSelectionControls,
      );

  /// Non-listenable [LdMonkeyRouterController] for [Provider].
  LdMonkeyRouterController<T, IdType> get controllerDelegate =>
      _LdEphemeralMonkeyControllerDelegate<T, IdType>(this);

  void replaceDefinitions({
    required Set<LdFilterOption<T, IdType>> filters,
    required List<LdSortOption<T, IdType>> sortOptions,
  }) {
    _filters = filters;
    _sortOptions = sortOptions;
    notifyListeners();
  }

  void updateSelection(Set<IdType> selection) {
    _selection = selection;
    notifyListeners();
  }

  void updateViewing(Set<IdType> viewingItems) {
    // Ephemeral pickers do not navigate to detail.
  }

  void updateShowSelectionControls(bool showSelectionControls) {
    _showSelectionControls = showSelectionControls;
    notifyListeners();
  }

  void updateFilter(LdFilterOption<T, IdType> filter) {
    _filters = _replaceFilterByName(_filters, filter);
    notifyListeners();
  }

  void updateSortOptions(List<LdSortOption<T, IdType>> sortOptions) {
    _sortOptions = sortOptions;
    notifyListeners();
  }
}

class _LdEphemeralMonkeyControllerDelegate<T extends Identifiable<IdType>, IdType>
    implements LdMonkeyRouterController<T, IdType> {
  const _LdEphemeralMonkeyControllerDelegate(this._delegate);

  final LdEphemeralMonkeyController<T, IdType> _delegate;

  @override
  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter) =>
      _delegate.updateFilter(filter);

  @override
  void updateSelection(BuildContext context, Set<IdType> selection) =>
      _delegate.updateSelection(selection);

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) =>
      _delegate.updateShowSelectionControls(showSelectionControls);

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<T, IdType>> sortOptions) =>
      _delegate.updateSortOptions(sortOptions);

  @override
  void updateViewing(BuildContext context, Set<IdType> viewingItems) =>
      _delegate.updateViewing(viewingItems);
}
