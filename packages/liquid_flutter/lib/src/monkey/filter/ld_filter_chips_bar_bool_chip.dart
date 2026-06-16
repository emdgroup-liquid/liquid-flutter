part of 'ld_filter_chips_bar.dart';

List<Widget> _buildBoolChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterChipBoolConfig<T, IdType> config,
) {
  final filter = findMonkeyFilterByName<T, IdType, LdFilterBool<T, IdType>>(
    context,
    filterName: config.filterName,
    listen: true,
  );
  if (filter == null) {
    return const [];
  }

  final label = config.chipLabel?.call(context) ?? filter.label(context);
  return [
    ldFilterChipButton(
      selected: filter.isOn,
      onPressed: () {
        filter.update(context, filter.copyWith(isOn: !filter.isOn));
      },
      child: Text(label),
    ),
  ];
}
