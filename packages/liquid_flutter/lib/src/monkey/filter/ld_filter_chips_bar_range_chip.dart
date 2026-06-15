part of 'ld_filter_chips_bar.dart';

class _RangeChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _RangeChip({required this.config});

  final LdFilterChipRangeConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterRange<T, IdType>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    final label = switch (config.summaryLabel) {
      final builder? when filter.isOn => builder(context, filter),
      _ => filter.label(context),
    };

    return ldFilterChipButton(
      selected: filter.isOn,
      showChevron: config.presentation == LdFilterChipPresentation.sheet,
      onPressed: () => switch (config.presentation) {
        LdFilterChipPresentation.sheet => ldFilterChipModal<T, IdType>(
            context,
            filter: filter,
            title: config.sheetTitle?.call(context) ?? filter.label(context),
          ),
        LdFilterChipPresentation.inline => filter.update(
            context,
            filter.copyWith(isOn: !filter.isOn),
          ),
      },
      child: Text(label),
    );
  }
}
