part of 'ld_filter_chips_bar.dart';

List<Widget> _buildOneOfChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterChipOneOfConfig<T, IdType> config,
) {
  final filter =
      findMonkeyFilterByName<T, IdType, LdFilterOneOf<T, IdType, dynamic>>(
    context,
    filterName: config.filterName,
    listen: true,
  );
  if (filter == null) {
    return const [];
  }

  return switch (config.presentation) {
    LdFilterChipChoicePresentation.choose =>
      _buildOneOfChooseChips(context, filter, config),
    LdFilterChipChoicePresentation.inline =>
      _buildOneOfInlineChips(context, filter, config),
  };
}

List<Widget> _buildOneOfChooseChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterOneOf<T, IdType, dynamic> filter,
  LdFilterChipOneOfConfig<T, IdType> config,
) {
  final options = filter.allValues.keys.toList();
  if (options.isEmpty) {
    return const [];
  }

  final chooseItems = <LdSelectItem<dynamic>>[];
  if (config.showAllOption) {
    final allLabel = config.allLabel?.call(context) ?? 'All';
    chooseItems.add(
      LdSelectItem<dynamic>(
        value: null,
        child: Text(allLabel),
      ),
    );
  }
  for (final value in options) {
    chooseItems.add(
      LdSelectItem<dynamic>(
        value: value,
        child: config.optionChild?.call(context, value) ??
            filter.allValues[value]?.call(context) ??
            Text(value.toString()),
      ),
    );
  }

  final label = switch (filter.isOn && filter.selectedValue != null) {
    true => filter.selectedValue.toString(),
    false => filter.label(context),
  };

  return [
    LdChoose.fromSelectItems<dynamic>(
      items: chooseItems,
      mode: LdChooseMode.auto,
      label: config.chooseTitle?.call(context) ?? filter.label(context),
      allowEmpty: true,
      value: filter.isOn ? {filter.selectedValue} : <dynamic>{},
      onChanged: (selection) {
        final next = selection.isEmpty ? null : selection.first;
        if (next == null) {
          filter.update(
            context,
            filter.copyWith(isOn: false, clearSelectedValue: true),
          );
          return;
        }
        filter.update(
          context,
          filter.copyWith(selectedValue: next, isOn: true),
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

List<Widget> _buildOneOfInlineChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterOneOf<T, IdType, dynamic> filter,
  LdFilterChipOneOfConfig<T, IdType> config,
) {
  final options = filter.allValues.keys.toList();
  if (options.isEmpty) {
    return const [];
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
    final child = config.optionChild?.call(context, value) ??
        filter.allValues[value]?.call(context) ??
        Text(value.toString());
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

  return chips;
}
