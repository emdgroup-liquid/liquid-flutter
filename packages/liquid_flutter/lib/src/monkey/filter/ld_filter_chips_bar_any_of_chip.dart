part of 'ld_filter_chips_bar.dart';

class _AnyOfChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfChip({required this.config});

  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterAnyOf<T, IdType, dynamic>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    return switch (config.presentation) {
      LdFilterChipPresentation.sheet => _AnyOfSheetChip<T, IdType>(filter: filter, config: config),
      LdFilterChipPresentation.inline => _AnyOfInlineChips<T, IdType>(filter: filter, config: config),
    };
  }
}

class _AnyOfSheetChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfSheetChip({required this.filter, required this.config});

  final LdFilterAnyOf<T, IdType, dynamic> filter;
  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final count = filter.selectedValues.length;
    final label = switch (filter.isOn && count > 0) {
      true => '${filter.label(context)} ($count)',
      false => filter.label(context),
    };

    return ldFilterChipButton(
      selected: filter.isOn,
      showChevron: true,
      onPressed: () => ldFilterChipModal<T, IdType>(
        context,
        filter: filter,
        title: config.sheetTitle?.call(context) ?? filter.label(context),
      ),
      child: Text(label),
    );
  }
}

class _AnyOfInlineChips<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfInlineChips({required this.filter, required this.config});

  final LdFilterAnyOf<T, IdType, dynamic> filter;
  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final options = filter.allValues.keys.toList();
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];
    for (final value in options) {
      final isSelected = filter.selectedValues.contains(value);
      final child =
          config.optionChild?.call(context, value) ?? filter.allValues[value]?.call(context) ?? Text(value.toString());
      chips.add(
        ldFilterChipButton(
          selected: isSelected,
          onPressed: () => filter.toggleSelectedValue(context, value),
          child: child,
        ),
      );
    }

    return Row(children: chips).spaceS();
  }
}
