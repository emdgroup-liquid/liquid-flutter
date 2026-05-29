import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterOneOf<T extends Identifiable<IdType>, IdType, E> extends LdFilterOption<T, IdType> {
  final Map<E, Widget Function(BuildContext)> allValues;
  final E? selectedValue;

  LdFilterOneOf({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.allValues,
    E? initialSelected,
    super.isEnabled,
  }) : selectedValue = initialSelected;

  @override
  String serialize() {
    if (!isOn || selectedValue == null) return '';
    return selectedValue!.toString();
  }

  @override
  LdFilterOneOf<T, IdType, E> marshalSerialized(String value) {
    if (value.isEmpty) {
      // Keep empty query values as an active-but-unselected filter so users can
      // open and choose a value from the modal.
      return copyWith(
        isOn: true,
        clearSelectedValue: true,
      );
    }

    final values = value.split(',');
    final selectedValue = allValues.keys
        .where((e) => values.contains(e.toString()))
        .cast<E?>()
        .firstWhere((e) => e != null, orElse: () => null);

    return copyWith(
      selectedValue: selectedValue,
      clearSelectedValue: selectedValue == null,
      isOn: selectedValue != null,
    );
  }

  @override
  LdFilterOneOf<T, IdType, E> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    Map<E, Widget Function(BuildContext)>? allValues,
    E? selectedValue,
    bool clearSelectedValue = false,
    bool Function(BuildContext context)? isEnabled,
  }) {
    return LdFilterOneOf<T, IdType, E>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      allValues: allValues ?? this.allValues,
      initialSelected: clearSelectedValue ? null : (selectedValue ?? this.selectedValue),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdFilterOneOfWidget<T, IdType, E>(filter: this);
  }
}
