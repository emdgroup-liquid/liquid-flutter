import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterAnyOf<T extends Identifiable<IdType>, IdType, E>
    extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  final Set<E> selectedValues;

  LdFilterAnyOf({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.allValues,
    Set<E>? initialSelected,
    super.isEnabled,
  }) : selectedValues = Set<E>.from(initialSelected ?? {});

  @override
  String serialize() {
    if (!isOn || selectedValues.isEmpty) return '';
    return selectedValues.map((e) => e.toString()).join(',');
  }

  @override
  LdFilterAnyOf<T, IdType, E> marshalSerialized(String value) {
    if (value.isEmpty) {
      // Keep empty query values as an active filter with no preselection so
      // users can select values from the modal.
      return copyWith(isOn: true, selectedValues: {});
    }

    final selectedValues = allValues.keys
        .where((e) => value.contains(e.toString()))
        .cast<E>()
        .toSet();

    return copyWith(
      selectedValues: selectedValues,
      isOn: selectedValues.isNotEmpty,
    );
  }

  @override
  LdFilterAnyOf<T, IdType, E> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    Map<E, Widget Function(BuildContext)>? allValues,
    Set<E>? selectedValues,
    bool Function(BuildContext context)? isEnabled,
  }) {
    return LdFilterAnyOf<T, IdType, E>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      allValues: allValues ?? this.allValues,
      initialSelected: selectedValues ?? this.selectedValues,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdFilterAnyOfWidget<T, IdType, E>(filter: this);
  }
}
