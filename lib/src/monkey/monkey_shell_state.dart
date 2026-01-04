import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyShellState<T extends Identifiable<IdType>, IdType> with ChangeNotifier {
  final bool immediateViewSelection = false;
  final bool allowMultipleSelection = true;

  Set<IdType> _selectedItems = {};

  final StreamController<Set<IdType>> _selectedItemsStreamController = StreamController.broadcast();
  Stream<Set<IdType>> get selectedItemsStream => _selectedItemsStreamController.stream;

  Set<IdType> _viewingItems = {};

  final StreamController<Set<IdType>> _viewingItemsStreamController = StreamController.broadcast();
  Stream<Set<IdType>> get viewingItemsStream => _viewingItemsStreamController.stream;

  bool _showSelectionControls = false;

  LdMonkeyEffectiveLayoutMode? _effectiveLayout;

  Set<IdType> get selectedItems => _selectedItems;

  Set<IdType> get viewingItems => _viewingItems;

  bool get showSelectionControls => _showSelectionControls;

  LdMonkeyEffectiveLayoutMode? get effectiveLayout => _effectiveLayout;

  Future<void> setSelectedItems(Set<IdType> selectedItems) async {
    await Future.delayed(Duration.zero);

    Set<IdType> newSelectedItems = {};
    Set<IdType>? newViewingItems = null;
    // Prevent multiple selection if not allowed
    if (!allowMultipleSelection && selectedItems.length > 1) {
      selectedItems = selectedItems.toList().take(1).toSet();
    }
    if (immediateViewSelection || (selectedItems.length == 1 && !showSelectionControls)) {
      newViewingItems = selectedItems;

      selectedItems = {};
    }

    newSelectedItems = selectedItems;

    if (!setEquals(newSelectedItems, _selectedItems)) {
      _selectedItems = newSelectedItems;
      _selectedItemsStreamController.add(newSelectedItems);
      notifyListeners();
    }

    if (newViewingItems != null && !setEquals(newViewingItems, _viewingItems)) {
      _viewingItems = newViewingItems;
      _viewingItemsStreamController.add(newViewingItems);
      notifyListeners();
    }

    if (newSelectedItems.length > 1 && !showSelectionControls) {
      _showSelectionControls = true;
      notifyListeners();
    }
  }

  Future<void> setViewingItems(Set<IdType> viewingItems) async {
    await Future.delayed(Duration.zero);
    if (viewingItems == _viewingItems) return;
    _viewingItems = viewingItems;
    _viewingItemsStreamController.add(viewingItems);
    notifyListeners();
  }

  void setShowSelectionControls(bool showSelectionControls) async {
    await Future.delayed(Duration.zero);
    _showSelectionControls = showSelectionControls;

    notifyListeners();
  }

  Future<void> setEffectiveLayout(LdMonkeyEffectiveLayoutMode effectiveLayout) async {
    _effectiveLayout = effectiveLayout;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    return other is LdMonkeyShellState<T, IdType> &&
        other.selectedItems == selectedItems &&
        other.viewingItems == viewingItems &&
        other.showSelectionControls == showSelectionControls &&
        other.effectiveLayout == effectiveLayout;
  }

  @override
  int get hashCode =>
      selectedItems.hashCode ^ viewingItems.hashCode ^ showSelectionControls.hashCode ^ effectiveLayout.hashCode;

  @override
  String toString() {
    return 'LdMonkeyShellState(selectedItems: $selectedItems, viewingItems: $viewingItems, showSelectionControls: $showSelectionControls, effectiveLayout: $effectiveLayout)';
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
