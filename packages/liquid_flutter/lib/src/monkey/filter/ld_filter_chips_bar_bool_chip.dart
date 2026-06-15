part of 'ld_filter_chips_bar.dart';

class _BoolChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _BoolChip({required this.config});

  final LdFilterChipBoolConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterBool<T, IdType>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    final label = config.chipLabel?.call(context) ?? filter.label(context);
    return ldFilterChipButton(
      selected: filter.isOn,
      onPressed: () {
        filter.update(context, filter.copyWith(isOn: !filter.isOn));
      },
      child: Text(label),
    );
  }
}
