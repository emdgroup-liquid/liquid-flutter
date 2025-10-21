import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LdFilterAnyOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterAnyOf<T, IdType, E> filter;

  const LdFilterAnyOfWidget({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<LdMonkey<T, IdType>>().repository;
    final items = filter.allValues.entries
        .map((e) => LdSelectItem<E>(
              value: e.key,
              child: e.value(context),
            ))
        .toList();

    return LdAutoSpace(
      children: [
        Row(
          children: [
            Expanded(child: LdTextL(filter.label(context))),
            LdButtonVague(
              child: const Icon(LucideIcons.x),
              size: LdSize.s,
              onPressed: () {
                repository.updateFilter<LdFilterAnyOf<T, IdType, E>>(
                  filter.name,
                  (filter) => filter.copyWith(isOn: false, selectedValues: {}),
                );
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
            onChanged: (Set<E> values) {
              repository.updateFilter<LdFilterAnyOf<T, IdType, E>>(
                filter.name,
                (filter) => filter.copyWith(
                  selectedValues: values,
                  isOn: values.isNotEmpty,
                ),
              );
            },
            allowEmpty: true,
          ),
      ],
    ).padM();
  }
}
