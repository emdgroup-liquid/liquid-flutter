import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdSortOptionDirection {
  asc,
  desc,
}

class LdSortOption<T extends Identifiable<IdType>, IdType> {
  final String Function(BuildContext context) label;
  final Widget Function(BuildContext context) icon;

  // Serialize the sort option to a string which will be used
  // to create the query string
  String serialize() => "$name-${direction.name}";

  LdSortOption<T, IdType> marshalSerialized(String value) {
    final parts = value.split("-");

    if (parts.length != 2) {
      return copyWith(isOn: true);
    }

    return copyWith(
      isOn: true,
      direction: switch (parts[1]) {
        "desc" => LdSortOptionDirection.desc,
        _ => LdSortOptionDirection.asc,
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LdSortOption<T, IdType> &&
        other.isOn == isOn &&
        other.name == name &&
        other.direction == direction &&
        other.supportsReorder == supportsReorder;
  }

  @override
  int get hashCode => Object.hash(name, isOn, direction, supportsReorder);

  @override
  String toString() {
    return "LdSortOption(name: $name, isOn: $isOn, direction: $direction, serialize: $serialize())";
  }

  final bool isOn;

  final LdSortOptionDirection direction;

  final String name;

  /// When [isOn], drag-to-reorder is enabled for lists using this sort option.
  final bool supportsReorder;

  /// Whether an item update may change sort order for this sort option.
  ///
  /// Used for cache invalidation and paginator layout decisions.
  final LdAffectedByUpdate<T>? affectedByUpdate;

  LdSortOption({
    required this.label,
    required this.icon,
    required this.name,
    this.isOn = false,
    this.direction = LdSortOptionDirection.asc,
    this.supportsReorder = false,
    this.affectedByUpdate,
  });

  LdSortOption<T, IdType> copyWith({
    bool? isOn,
    LdSortOptionDirection? direction,
    bool? supportsReorder,
    LdAffectedByUpdate<T>? affectedByUpdate,
  }) {
    return LdSortOption<T, IdType>(
      name: name,
      label: label,
      icon: icon,
      isOn: isOn ?? this.isOn,
      direction: direction ?? this.direction,
      supportsReorder: supportsReorder ?? this.supportsReorder,
      affectedByUpdate: affectedByUpdate ?? this.affectedByUpdate,
    );
  }
}
