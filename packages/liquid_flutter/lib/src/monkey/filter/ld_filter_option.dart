import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

abstract class LdFilterOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  final String name;
  final bool isOn;

  // Serialize the filter to a string which will be used
  // to create the query string
  String serialize();

  // Apply the filter to the LdFilterOption and return a new instance
  LdFilterOption<T, IdType> marshalSerialized(String entry);

  /// Returns true if the item should be included in the list, is called
  /// before the list is re-fetched
  bool optimisticFilter(T item);

  /// Create a copy of this filter option with the given fields replaced
  LdFilterOption<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
  });

  LdFilterOption({
    required this.label,
    required this.icon,
    required this.name,
    this.isOn = false,
  });

  Widget build(BuildContext context, LdRepository<T, IdType> repository);
}
