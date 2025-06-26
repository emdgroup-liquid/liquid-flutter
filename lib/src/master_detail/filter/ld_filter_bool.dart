import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterBoolOption<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  @override
  String serialize() {
    return "true";
  }

  @override
  void marshalSerialized(MapEntry<String, String> entry) {
    // No oop
  }

  LdFilterBoolOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required bool Function(T item) optimisticFilter,
  }) : _optimisticFilter = optimisticFilter;

  final bool Function(
    T item,
  ) _optimisticFilter;

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item);
  }
}
