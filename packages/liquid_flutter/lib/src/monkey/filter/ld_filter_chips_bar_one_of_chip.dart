part of 'ld_filter_chips_bar.dart';

class _OneOfChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfChip({required this.config});

  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterOneOf<T, IdType, dynamic>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    return switch (config.presentation) {
      LdFilterChipPresentation.sheet => _OneOfSheetChip<T, IdType>(filter: filter, config: config),
      LdFilterChipPresentation.inline => _OneOfInlineChips<T, IdType>(filter: filter, config: config),
    };
  }
}

class _OneOfSheetChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfSheetChip({required this.filter, required this.config});

  final LdFilterOneOf<T, IdType, dynamic> filter;
  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter.isOn && filter.selectedValue != null) {
      true => filter.selectedValue.toString(),
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

class _OneOfInlineChips<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfInlineChips({required this.filter, required this.config});

  final LdFilterOneOf<T, IdType, dynamic> filter;
  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final options = filter.allValues.keys.toList();
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    if (config.showAllOption) {
      final allLabel = config.allLabel?.call(context) ?? 'All';
      chips.add(
        ldFilterChipButton(
          selected: !filter.isOn,
          showClearIcon: false,
          onPressed: () {
            filter.update(
              context,
              filter.copyWith(isOn: false, clearSelectedValue: true),
            );
          },
          child: Text(allLabel),
        ),
      );
    }

    for (final value in options) {
      final isSelected = filter.isOn && filter.selectedValue == value;
      final child =
          config.optionChild?.call(context, value) ?? filter.allValues[value]?.call(context) ?? Text(value.toString());
      chips.add(
        ldFilterChipButton(
          selected: isSelected,
          onPressed: () {
            filter.update(
              context,
              filter.copyWith(selectedValue: value, isOn: true),
            );
          },
          child: child,
        ),
      );
    }

    return Row(children: chips).spaceS();
  }
}
