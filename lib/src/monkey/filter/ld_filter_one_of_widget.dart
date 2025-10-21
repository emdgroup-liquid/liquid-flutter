import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LdFilterOneOfWidget<T extends Identifiable<IdType>, IdType, E> extends StatelessWidget {
  final LdFilterOneOf<T, IdType, E> filter;

  const LdFilterOneOfWidget({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<LdMonkey<T, IdType>>().repository;
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
                  repository.updateFilter<LdFilterOneOf<T, IdType, E>>(
                    filter.name,
                    (filter) => filter.copyWith(isOn: false),
                  );
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
                repository.updateFilter<LdFilterOneOf<T, IdType, E>>(
                  filter.name,
                  (filter) => filter.copyWith(selectedValue: value, isOn: true),
                );
              },
            ),
        ],
      ),
    );
  }
}
