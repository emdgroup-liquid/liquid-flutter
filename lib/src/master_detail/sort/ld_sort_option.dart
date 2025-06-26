import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

abstract class LdSortOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  final int Function(T a, T b)? optimisticSort;

  // Serialize the sort option to a string which will be used
  // to create the query string
  String serialize();

  final bool isOn;

  final String name;

  // Apply the sort option to the LdSortOption
  void marshalSerialized(MapEntry<String, String> entry);

  LdSortOption({
    required this.label,
    required this.icon,
    this.optimisticSort,
    required this.name,
    this.isOn = false,
  });
}
