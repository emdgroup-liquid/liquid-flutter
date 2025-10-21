import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterAnyOf<T extends Identifiable<IdType>, IdType, E> extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  final Set<E> selectedValues;
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
  LdFilterAnyOf<T, IdType, E> marshalSerialized(String value) {
    if (value.isEmpty) {
      return copyWith(isOn: false, selectedValues: {});
    }

    final selectedValues = allValues.keys.where((e) => value.contains(e.toString())).cast<E>().toSet();

    return copyWith(
      selectedValues: selectedValues,
      isOn: selectedValues.isNotEmpty,
    );
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, selectedValues.toList());
  }

  @override
  LdFilterAnyOf<T, IdType, E> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    Map<E, Widget Function(BuildContext)>? allValues,
    Set<E>? selectedValues,
    bool Function(T item, List<E> selected)? optimisticFilter,
  }) {
    return LdFilterAnyOf<T, IdType, E>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      allValues: allValues ?? this.allValues,
      initialSelected: selectedValues ?? this.selectedValues,
      optimisticFilter: optimisticFilter ?? _optimisticFilter,
    );
  }
}
