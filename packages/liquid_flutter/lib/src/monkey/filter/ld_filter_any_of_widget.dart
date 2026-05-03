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
              size: LdSize.s,
              onPressed: () {
                filter.update(
                  context,
                  filter.copyWith(
                    isOn: false,
                  ),
                );
              },
              child: const Icon(LucideIcons.x),
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
              filter.update(
                context,
                filter.copyWith(
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
