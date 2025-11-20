import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyShellState<T extends Identifiable<IdType>, IdType> with ChangeNotifier {
  Set<IdType> _selectedItems = {};

  final StreamController<Set<IdType>> _selectedItemsStreamController = StreamController.broadcast();
  Stream<Set<IdType>> get selectedItemsStream => _selectedItemsStreamController.stream;

  bool _showSelectionControls = false;

  LdMonkeyEffectiveLayoutMode? _effectiveLayout;

  Set<IdType> get selectedItems => _selectedItems;

  bool get showSelectionControls => _showSelectionControls;

  LdMonkeyEffectiveLayoutMode? get effectiveLayout => _effectiveLayout;

  Future<void> setSelectedItems(Set<IdType> selectedItems) async {
    await Future.delayed(Duration.zero);
    if (selectedItems == _selectedItems) return;
    _selectedItems = selectedItems;
    _selectedItemsStreamController.add(selectedItems);
    notifyListeners();
  }

  void setShowSelectionControls(bool showSelectionControls) async {
    await Future.delayed(Duration.zero);
    _showSelectionControls = showSelectionControls;
    notifyListeners();
  }

  Future<void> setEffectiveLayout(LdMonkeyEffectiveLayoutMode effectiveLayout) async {
    await Future.delayed(Duration.zero);
    _effectiveLayout = effectiveLayout;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    return other is LdMonkeyShellState<T, IdType> &&
        other.selectedItems == selectedItems &&
        other.showSelectionControls == showSelectionControls &&
        other.effectiveLayout == effectiveLayout;
  }

  @override
  int get hashCode => selectedItems.hashCode ^ showSelectionControls.hashCode ^ effectiveLayout.hashCode;

  @override
  String toString() {
    return 'LdMonkeyShellState(selectedItems: $selectedItems, showSelectionControls: $showSelectionControls, effectiveLayout: $effectiveLayout)';
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
