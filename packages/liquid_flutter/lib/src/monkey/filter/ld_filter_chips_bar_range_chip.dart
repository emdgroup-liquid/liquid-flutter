part of 'ld_filter_chips_bar.dart';

List<Widget> _buildRangeChips<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdFilterChipRangeConfig<T, IdType> config,
) {
  final filter = findMonkeyFilterByName<T, IdType, LdFilterRange<T, IdType>>(
    context,
    filterName: config.filterName,
    listen: true,
  );
  if (filter == null) {
    return const [];
  }

  String label = filter.label(context);

  if (filter.isOn) {
    if (config.summaryLabel != null) {
      label = config.summaryLabel!(context, filter);
    } else {
      final start = filter.range.start;
      final end = filter.range.end;
      final double step = filter.step;
      String formatValue(num value) {
        if (step % 1 == 0) {
          // Integer-step: display without decimals
          return value.toStringAsFixed(0);
        } else {
          // Otherwise, display as regular (keep decimals where applicable)
          return value.toString();
        }
      }

      label = "${filter.label(context)}(${formatValue(start)} to ${formatValue(end)})";
    }
  }

  final router = GoRouter.maybeOf(context);
  final routerDelegate = router?.routerDelegate;
  final routeConfig = router != null ? context.read<LdMonkeyRouteConfig<T, IdType>>() : null;
  final routerController = context.read<LdMonkeyRouterController<T, IdType>>();
  final repository = LdRepository.of<T, IdType>(context);
  final baseSortAndFilterState = LdMonkeySortAndFilterState.of<T, IdType>(context);
  final baseFilters = baseSortAndFilterState.filters.toList(growable: false);
  final baseSortOptions = baseSortAndFilterState.sortOptions.toList(growable: false);

  return [
    LdContextMenu(
      menuProviders: routerDelegate == null
          ? (_) => [
                Provider<LdMonkeyRouterController<T, IdType>>.value(value: routerController),
                Provider<LdMonkeySortAndFilterState<T, IdType>>.value(value: baseSortAndFilterState),
                ListenableProvider<LdRepository<T, IdType>>.value(value: repository),
              ]
          : null,
      builder: (context, isShuttle, open, isOpen, child) {
        return ldFilterChipButton(
          selected: filter.isOn,
          showChevron: true,
          onPressed: open,
          child: Text(label),
        );
      },
      menuBuilder: (menuContext) {
        Widget menuContent = _LdFilterRangeChipMenuContent<T, IdType>(
          filterName: config.filterName,
          menuTitle: config.menuTitle,
        );

        if (routerDelegate != null && routeConfig != null) {
          menuContent = ldFilterStateScope<T, IdType>(
            routerDelegate: routerDelegate,
            routeConfig: routeConfig,
            routerController: routerController,
            repository: repository,
            baseFilters: baseFilters,
            baseSortOptions: baseSortOptions,
            child: menuContent,
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: menuContent,
        );
      },
    ),
  ];
}

class _LdFilterRangeChipMenuContent<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _LdFilterRangeChipMenuContent({
    required this.filterName,
    this.menuTitle,
  });

  final String filterName;
  final String Function(BuildContext context)? menuTitle;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterRange<T, IdType>>(
      context,
      filterName: filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    return LdFilterRangeWidget<T, IdType>(
      filter: filter,
      title: menuTitle?.call(context),
    );
  }
}
