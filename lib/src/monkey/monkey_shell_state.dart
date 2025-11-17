import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyShellState<T extends Identifiable<IdType>, IdType> with ChangeNotifier {
  Set<IdType> _selectedItems = {};

  final StreamController<Set<IdType>> _selectedItemsStreamController = StreamController.broadcast();
  Stream<Set<IdType>> get selectedItemsStream => _selectedItemsStreamController.stream;

  bool _showSelectionControls = false;

  Set<IdType> _deletedItems = {};

  LdMonkeyEffectiveLayoutMode? _effectiveLayout;

  Set<IdType> get selectedItems => _selectedItems;

  bool get showSelectionControls => _showSelectionControls;

  Set<IdType> get deletedItems => _deletedItems;

  LdMonkeyEffectiveLayoutMode? get effectiveLayout => _effectiveLayout;

  void setSelectedItems(Set<IdType> selectedItems) {
    print('setSelectedItems: $selectedItems');
    _selectedItems = selectedItems;
    _selectedItemsStreamController.add(selectedItems);
    notifyListeners();
  }

  void setShowSelectionControls(bool showSelectionControls) {
    _showSelectionControls = showSelectionControls;
    notifyListeners();
  }

  void setDeletedItems(Set<IdType> deletedItems) {
    _deletedItems = deletedItems;
    notifyListeners();
  }

  void setEffectiveLayout(LdMonkeyEffectiveLayoutMode effectiveLayout) {
    _effectiveLayout = effectiveLayout;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    return other is LdMonkeyShellState<T, IdType> &&
        other.selectedItems == selectedItems &&
        other.showSelectionControls == showSelectionControls &&
        other.deletedItems == deletedItems &&
        other.effectiveLayout == effectiveLayout;
  }

  @override
  int get hashCode =>
      selectedItems.hashCode ^ showSelectionControls.hashCode ^ deletedItems.hashCode ^ effectiveLayout.hashCode;

  @override
  String toString() {
    return 'LdMonkeyShellState(selectedItems: $selectedItems, showSelectionControls: $showSelectionControls, deletedItems: $deletedItems, effectiveLayout: $effectiveLayout)';
  }

  static LdMonkeyShellState<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool watch = false,
  }) {
    return watch ? context.watch<LdMonkeyShellState<T, IdType>>() : context.read<LdMonkeyShellState<T, IdType>>();
  }

  static LdMonkeyShellState<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeyShellState<T, IdType>>() : context.read<LdMonkeyShellState<T, IdType>>();
  }
}
