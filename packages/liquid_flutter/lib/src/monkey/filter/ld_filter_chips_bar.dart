import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

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
    final children = <Widget>[];

    for (final config in configs) {
      final chips = switch (config) {
        LdFilterChipBoolConfig<T, IdType> c => _buildBoolChips(context, c),
        LdFilterChipRangeConfig<T, IdType> c => _buildRangeChips(context, c),
        LdFilterChipOneOfConfig<T, IdType> c => _buildOneOfChips(context, c),
        LdFilterChipAnyOfConfig<T, IdType> c => _buildAnyOfChips(context, c),
      };

      if (chips.isEmpty) {
        continue;
      }

      if (children.isNotEmpty) {
        children.add(const _FilterChipGroupDivider());
      }

      final groupLabel = config.groupLabel?.call(context);
      if (groupLabel != null) {
        children.add(_FilterChipGroupLabel(text: groupLabel));
      }

      children.addAll(chips);
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LdHorizontalScroll(
      //hint: LdHorizontalScrollHint.none,
      edgeBleed: EdgeInsets.symmetric(
        horizontal: LdTheme.of(context).pad(size: LdSize.m).horizontal,
      ),
      children: children,
    );
  }
}
