import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterBoolOption<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  final bool Function(T item) _optimisticFilter;

  LdFilterBoolOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required bool Function(T item) optimisticFilter,
  }) : _optimisticFilter = optimisticFilter;

  @override
  String serialize() {
    return "true";
  }

  @override
  LdFilterBoolOption<T, IdType> marshalSerialized(String value) {
    return copyWith(isOn: true);
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item);
  }

  @override
  LdFilterBoolOption<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    bool Function(T item)? optimisticFilter,
  }) {
    return LdFilterBoolOption<T, IdType>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      optimisticFilter: optimisticFilter ?? _optimisticFilter,
    );
  }

  @override
  Widget build(BuildContext context, LdRepository<T, IdType> repository) {
    if (isOn) {
      return LdListItem(
        leading: LdAvatar(child: icon(context)),
        title: Text(label(context)),
        trailing: LdButton.outline(
          child: const Icon(LucideIcons.x),
          onPressed: () {
            repository.updateFilter(name, (filter) => filter!.copyWith(isOn: false));
          },
        ),
      );
    }
    return Container();
  }
}
