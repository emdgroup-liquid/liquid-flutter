import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterOneOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterOneOf<T, IdType, E> filter;
  final void Function(LdFilterOneOf<T, IdType, E> filter) onFilterChanged;

  const LdFilterOneOfWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          Row(
            children: [
              Expanded(child: LdTextL(filter.label(context))),
              LdButtonVague(
                child: const Icon(LucideIcons.x),
                size: LdSize.s,
                onPressed: () {
                  filter.isOn = false;
                  filter.selectedValue = null;
                  onFilterChanged(filter);
                },
              ),
            ],
          ),
          if (filter.allValues.keys.isNotEmpty)
            LdSwitch<E>(
              children: Map.fromEntries(
                filter.allValues.entries.map(
                  (e) => MapEntry(e.key, e.value(context)),
                ),
              ),
              value: filter.selectedValue ?? filter.allValues.keys.first,
              onChanged: (E value) {
                filter.selectedValue = value;
                filter.isOn = true;
                onFilterChanged(filter);
              },
            ),
        ],
      ),
    );
  }
}
