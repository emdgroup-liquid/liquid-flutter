import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSortOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  final int Function(T a, T b)? optimisticSort;

  // Serialize the sort option to a string which will be used
  // to create the query string
  String serialize() => name;

  final bool isOn;

  final String name;

  LdSortOption({
    required this.label,
    required this.icon,
    this.optimisticSort,
    required this.name,
    this.isOn = false,
  });

  LdSortOption<T, IdType> copyWith({
    bool? isOn,
  }) {
    return LdSortOption<T, IdType>(
      name: name,
      label: label,
      icon: icon,
      optimisticSort: optimisticSort,
      isOn: isOn ?? this.isOn,
    );
  }
}
