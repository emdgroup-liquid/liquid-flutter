part of 'ld_filter_chips_bar.dart';

List<Widget> _buildAnyOfChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterChipAnyOfConfig<T, IdType> config,
) {
  final filter = findMonkeyFilterByName<T, IdType, LdFilterAnyOf<T, IdType, dynamic>>(
    context,
    filterName: config.filterName,
    listen: true,
  );
  if (filter == null) {
    return const [];
  }

  return switch (config.presentation) {
    LdFilterChipChoicePresentation.choose => _buildAnyOfChooseChips(context, filter, config),
    LdFilterChipChoicePresentation.inline => _buildAnyOfInlineChips(context, filter, config),
  };
}

List<Widget> _buildAnyOfChooseChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterAnyOf<T, IdType, dynamic> filter,
  LdFilterChipAnyOfConfig<T, IdType> config,
) {
  final options = filter.allValues.keys.toList();
  if (options.isEmpty) {
    return const [];
  }

  final chooseItems = options
      .map(
        (value) => LdSelectItem<dynamic>(
          value: value,
          child: config.optionChild?.call(context, value) ??
              filter.allValues[value]?.call(context) ??
              Text(value.toString()),
        ),
      )
      .toList();
  final count = filter.selectedValues.length;
  final label = switch (filter.isOn && count > 0) {
    true => '${filter.label(context)} ($count)',
    false => filter.label(context),
  };

  return [
    LdChoose.fromSelectItems<dynamic>(
      items: chooseItems,
      mode: LdChooseMode.auto,
      multiple: true,
      allowEmpty: true,
      label: config.chooseTitle?.call(context) ?? filter.label(context),
      value: filter.selectedValues.toSet(),
      onChanged: (selection) {
        filter.update(
          context,
          filter.copyWith(selectedValues: selection, isOn: selection.isNotEmpty),
        );
      },
      triggerBuilder: (context, triggerConfig) {
        return ldFilterChipButton(
          selected: filter.isOn,
          showChevron: true,
          onPressed: triggerConfig.onTap,
          child: Text(label),
        );
      },
    ),
  ];
}

List<Widget> _buildAnyOfInlineChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterAnyOf<T, IdType, dynamic> filter,
  LdFilterChipAnyOfConfig<T, IdType> config,
) {
  final options = filter.allValues.keys.toList();
  if (options.isEmpty) {
    return const [];
  }

  return [
    for (final value in options)
      ldFilterChipButton(
        selected: filter.selectedValues.contains(value),
        onPressed: () => filter.toggleSelectedValue(context, value),
        child: config.optionChild?.call(context, value) ??
            filter.allValues[value]?.call(context) ??
            Text(value.toString()),
      ),
  ];
}
