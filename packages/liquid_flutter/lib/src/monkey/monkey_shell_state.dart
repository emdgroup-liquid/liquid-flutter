import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyShellState<T extends Identifiable<IdType>, IdType> with ChangeNotifier {
  bool _immediateViewSelection = false;
  bool _allowMultipleSelection = true;
  String basePath;

  LdMonkeyShellState({required this.basePath});

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
  bool get immediateViewSelection => _immediateViewSelection;
  bool get allowMultipleSelection => _allowMultipleSelection;

  LdMonkeyEffectiveLayoutMode? get effectiveLayout => _effectiveLayout;

  void setSelectedItems(Set<IdType> selectedItems) {
    Set<IdType> newSelectedItems = {};
    Set<IdType>? newViewingItems;
    // Prevent multiple selection if not allowed
    if (!_allowMultipleSelection && selectedItems.length > 1) {
      selectedItems = selectedItems.toList().take(1).toSet();
    }
    if (_immediateViewSelection || (selectedItems.length == 1 && !showSelectionControls)) {
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

  void setImmediateViewSelection(bool immediateViewSelection) {
    _immediateViewSelection = immediateViewSelection;
    notifyListeners();
  }

  void setAllowMultipleSelection(bool allowMultipleSelection) {
    _allowMultipleSelection = allowMultipleSelection;
    notifyListeners();
  }

  void setViewingItems(Set<IdType> viewingItems) {
    if (setEquals(viewingItems, _viewingItems)) return;
    _viewingItems = viewingItems;
    _viewingItemsStreamController.add(viewingItems);
    notifyListeners();
  }

  void setShowSelectionControls(bool showSelectionControls) {
    _showSelectionControls = showSelectionControls;

    notifyListeners();
  }

  void setEffectiveLayout(LdMonkeyEffectiveLayoutMode effectiveLayout) {
    _effectiveLayout = effectiveLayout;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    return other is LdMonkeyShellState<T, IdType> &&
        setEquals(selectedItems, other.selectedItems) &&
        setEquals(viewingItems, other.viewingItems) &&
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
