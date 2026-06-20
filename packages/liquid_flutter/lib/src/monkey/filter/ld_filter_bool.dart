import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterBool<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  LdFilterBool({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    super.isEnabled,
    super.affectedByUpdate,
    @Deprecated('Use affectedByUpdate') super.mutationAffectsCache,
  });

  @override
  String serialize() {
    return "true";
  }

  @override
  LdFilterBool<T, IdType> marshalSerialized(String value) {
    return copyWith(isOn: true);
  }

  @override
  LdFilterBool<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    bool Function(BuildContext context)? isEnabled,
    String? name,
    bool? isOn,
    LdAffectedByUpdate<T>? affectedByUpdate,
    @Deprecated('Use affectedByUpdate') LdAffectedByUpdate<T>? mutationAffectsCache,
  }) {
    return LdFilterBool<T, IdType>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      isEnabled: isEnabled ?? this.isEnabled,
      affectedByUpdate: affectedByUpdate ?? mutationAffectsCache ?? this.affectedByUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isOn) {
      return LdListItem(
        leading: LdAvatar(child: icon(context)),
        title: Text(label(context)),
        trailing: LdButton.ghost(
          child: const Icon(LucideIcons.x),
          onPressed: () {
            update(context, copyWith(isOn: false));
          },
        ),
      );
    }
    return Container();
  }
}
