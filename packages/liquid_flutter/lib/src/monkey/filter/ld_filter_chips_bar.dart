import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'ld_filter_chips_bar_any_of_chip.dart';
part 'ld_filter_chips_bar_bool_chip.dart';
part 'ld_filter_chips_bar_group.dart';
part 'ld_filter_chips_bar_one_of_chip.dart';
part 'ld_filter_chips_bar_range_chip.dart';

/// Horizontal chip bar for monkey filters (presentation only).
class LdFilterChipsBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdFilterChipsBar({
    super.key,
    required this.configs,
  });

  final List<LdFilterChipConfig<T, IdType>> configs;

  @override
  Widget build(BuildContext context) {
    final groups = <Widget>[];
    for (final config in configs) {
      final group = switch (config) {
        LdFilterChipBoolConfig<T, IdType> c => _BoolChip<T, IdType>(config: c),
        LdFilterChipRangeConfig<T, IdType> c => _RangeChip<T, IdType>(config: c),
        LdFilterChipOneOfConfig<T, IdType> c => _OneOfChip<T, IdType>(config: c),
        LdFilterChipAnyOfConfig<T, IdType> c => _AnyOfChip<T, IdType>(config: c),
      };
      if (!isEmptyFilterChipGroup(group)) {
        groups.add(
          _FilterChipGroup<T, IdType>(
            config: config,
            child: group,
          ),
        );
      }
    }

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < groups.length; i++) {
      if (i > 0) {
        children.add(const _FilterChipGroupDivider());
      }
      children.add(groups[i]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ).spaceS(),
    );
  }
}
