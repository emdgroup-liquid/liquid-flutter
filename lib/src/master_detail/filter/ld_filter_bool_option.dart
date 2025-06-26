import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterBoolOption<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  @override
  String serialize() {
    return isOn.toString();
  }

  @override
  void marshalSerialized(MapEntry<String, String> entry) {
    filterValue = entry.value == "true";
  }

  bool filterValue;

  LdFilterBoolOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    this.filterValue = false,
    required bool Function(T item, bool filterValue) optimisticFilter,
  }) : _optimisticFilter = optimisticFilter;

  final bool Function(T item, bool filterValue) _optimisticFilter;

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, filterValue);
  }
}
