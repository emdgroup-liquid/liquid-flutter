import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ld_filter_any_of.dart';

class LdFilterAnyOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterAnyOf<T, IdType, E> filter;
  final void Function(LdFilterAnyOf<T, IdType, E> filter) onFilterChanged;

  const LdFilterAnyOfWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = filter.allValues.entries
        .map((e) => LdSelectItem<E>(
              value: e.key,
              child: e.value(context),
            ))
        .toList();

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
                  filter.selectedValues.clear();
                  onFilterChanged(filter);
                },
              ),
            ],
          ),
          if (items.isNotEmpty)
            LdChoose<E>(
              items: items,
              multiple: true,
              value: filter.selectedValues,
              placeholder: Text(filter.label(context)),
              onChange: (Set<E> values) {
                if (values.isEmpty) {
                  filter.isOn = false;
                  onFilterChanged(filter);
                  return;
                }

                filter.selectedValues = values;
                filter.isOn = values.isNotEmpty;
                onFilterChanged(filter);
              },
              allowEmpty: true,
            ),
        ],
      ),
    );
  }
}
