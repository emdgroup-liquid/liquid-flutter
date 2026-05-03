import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterOneOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterOneOf<T, IdType, E> filter;

  const LdFilterOneOfWidget({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
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
          if (filter.allValues.keys.isNotEmpty)
            LdSwitch<E>(
              children: Map.fromEntries(
                filter.allValues.entries.map(
                  (e) => MapEntry(e.key, e.value(context)),
                ),
              ),
              value: filter.selectedValue ?? filter.allValues.keys.first,
              onChanged: (E value) {
                filter.update(
                  context,
                  filter.copyWith(
                    selectedValue: value,
                    isOn: true,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
