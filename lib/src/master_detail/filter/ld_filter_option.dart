import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

abstract class LdFilterOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  // Serialize the filter to a string which will be used
  // to create the query string
  String serialize();

  final String name;

  final bool isOn;

  // Apply the filter to the LdFilterOption
  void marshalSerialized(MapEntry<String, String> entry);

  /// Returns true if the item should be included in the list, is called
  /// before the list is re-fetched
  bool optimisticFilter(T item);

  LdFilterOption({
    required this.label,
    required this.icon,
    required this.name,
    this.isOn = false,
  });
}
