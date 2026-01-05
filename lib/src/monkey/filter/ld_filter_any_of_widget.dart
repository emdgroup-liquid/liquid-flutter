import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterAnyOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterAnyOf<T, IdType, E> filter;

  const LdFilterAnyOfWidget({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final repository = LdRepository.of<T, IdType>(context);

    List<LdSelectItem<E>> items = filter.allValues.entries
        .map<LdSelectItem<E>>((e) => LdSelectItem<E>(
              value: e.key,
              child: e.value(context),
            ))
        .toList();

    return LdAutoSpace(
      children: [
        Row(
          children: [
            Expanded(child: LdText.l(filter.label(context))),
            LdButton.vague(
              child: const Icon(LucideIcons.x),
              size: LdSize.s,
              onPressed: () {
                repository.updateFilter(
                  filter.name,
                  (filter) => (filter as LdFilterAnyOf<T, IdType, E>).copyWith(
                    isOn: false,
                  ),
                );
              },
            ),
          ],
        ),
        if (items.isNotEmpty)
          LdChoose.fromSelectItems<E>(
            items: items,
            multiple: true,
            value: filter.selectedValues,
            placeholder: Text(filter.label(context)),
            onChanged: (Set<E> values) {
              repository.updateFilter(
                filter.name,
                (filter) => (filter as LdFilterAnyOf<T, IdType, E>).copyWith(
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
