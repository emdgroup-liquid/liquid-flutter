import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterOneOf<T extends Identifiable<IdType>, IdType, E> extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  final E? selectedValue;
  final bool Function(T item, E? selected) _optimisticFilter;

  LdFilterOneOf({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.allValues,
    E? initialSelected,
    required bool Function(T item, E? selected) optimisticFilter,
  })  : _optimisticFilter = optimisticFilter,
        selectedValue = initialSelected;

  @override
  String serialize() {
    if (!isOn || selectedValue == null) return '';
    return selectedValue!.toString();
  }

  @override
  LdFilterOneOf<T, IdType, E> marshalSerialized(String value) {
    if (value.isEmpty) {
      return copyWith(isOn: false);
    }

    final values = value.split(',');
    final selectedValue = allValues.keys
        .where((e) => values.contains(e.toString()))
        .cast<E?>()
        .firstWhere((e) => e != null, orElse: () => null);

    return copyWith(
      selectedValue: selectedValue,
      isOn: selectedValue != null,
    );
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, selectedValue);
  }

  @override
  LdFilterOneOf<T, IdType, E> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    Map<E, Widget Function(BuildContext)>? allValues,
    E? selectedValue,
    bool Function(T item, E? selected)? optimisticFilter,
  }) {
    return LdFilterOneOf<T, IdType, E>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      allValues: allValues ?? this.allValues,
      initialSelected: selectedValue ?? this.selectedValue,
      optimisticFilter: optimisticFilter ?? _optimisticFilter,
    );
  }

  @override
  Widget build(BuildContext context, LdRepository<T, IdType> repository) {
    return LdFilterOneOfWidget<T, IdType, E>(filter: this);
  }
}
