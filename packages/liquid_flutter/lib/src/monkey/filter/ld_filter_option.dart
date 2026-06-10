import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

abstract class LdFilterOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  final bool Function(BuildContext context)? isEnabled;

  final LdMutationAffectsCache<T>? mutationAffectsCache;

  final String name;
  final bool isOn;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LdFilterOption<T, IdType> && other.serialize() == serialize() && other.name == name;
  }

  @override
  String toString() {
    return "LdFilterOption(name: $name, isOn: $isOn, serialize: ${serialize()})";
  }

  @override
  int get hashCode => Object.hash(isOn, serialize().hashCode, name);

  // Serialize the filter to a string which will be used
  // to create the query string
  String serialize();

  // Apply the filter to the LdFilterOption and return a new instance
  LdFilterOption<T, IdType> marshalSerialized(String entry);

  /// Create a copy of this filter option with the given fields replaced
  LdFilterOption<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    LdMutationAffectsCache<T>? mutationAffectsCache,
  });

  LdFilterOption({
    required this.label,
    required this.icon,
    required this.name,
    this.isOn = false,
    this.isEnabled,
    this.mutationAffectsCache,
  });

  void update(BuildContext context, LdFilterOption<T, IdType> filter) {
    LdMonkeySortAndFilterState.updateFilter(context, filter);
  }

  Widget build(BuildContext context);
}
