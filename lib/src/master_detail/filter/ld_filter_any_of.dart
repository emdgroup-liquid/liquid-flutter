import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterAnyOf<T extends Identifiable<IdType>, IdType, E> extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  Set<E> selectedValues;
  final bool Function(T item, List<E> selected) _optimisticFilter;

  LdFilterAnyOf({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.allValues,
    Set<E>? initialSelected,
    required bool Function(T item, List<E> selected) optimisticFilter,
  })  : _optimisticFilter = optimisticFilter,
        selectedValues = initialSelected ?? {};

  @override
  String serialize() {
    if (!isOn || selectedValues.isEmpty) return '';
    return selectedValues.map((e) => e.toString()).join(',');
  }

  @override
  void marshalSerialized(String value) {
    isOn = false;
    if (value.isEmpty) {
      selectedValues.clear();
      return;
    }
    selectedValues = allValues.keys.where((e) => value.contains(e.toString())).cast<E>().toSet();
    isOn = selectedValues.isNotEmpty;
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, selectedValues.toList());
  }
}
