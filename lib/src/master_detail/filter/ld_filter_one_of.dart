import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterOneOf<T extends Identifiable<IdType>, IdType, E> extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  E? selectedValue;
  final bool Function(T item, E? selected) _optimisticFilter;

  LdFilterOneOf({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.allValues,
    dynamic initialSelected,
    required bool Function(T item, dynamic selected) optimisticFilter,
  })  : _optimisticFilter = optimisticFilter,
        selectedValue = initialSelected;

  @override
  String serialize() {
    if (!isOn || selectedValue == null) return '';
    return selectedValue!.toString();
  }

  @override
  void marshalSerialized(String value) {
    isOn = false;
    if (value.isEmpty) {
      selectedValue = null;
      return;
    }
    final values = value.split(',');
    selectedValue = allValues.keys
        .where((e) => values.contains(e.toString()))
        .cast<E?>()
        .firstWhere((e) => e != null, orElse: () => null);
    isOn = selectedValue != null;
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, selectedValue);
  }
}
