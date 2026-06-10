import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

Future<void> ldFilterChipSheet<T extends Identifiable<IdType>, IdType>(
  BuildContext sourceContext, {
  required LdFilterOption<T, IdType> filter,
  required String title,
}) {
  final routerDelegate = GoRouter.of(sourceContext).routerDelegate;
  final routeConfig = sourceContext.read<LdMonkeyRouteConfig<T, IdType>>();
  final routerController = sourceContext.read<LdMonkeyRouterController<T, IdType>>();
  final repository = sourceContext.read<LdRepository<T, IdType>>();
  final baseSortAndFilterState = sourceContext.read<LdMonkeySortAndFilterState<T, IdType>>();
  final baseFilters = baseSortAndFilterState.filters.toList(growable: false);
  final baseSortOptions = baseSortAndFilterState.sortOptions.toList(growable: false);

  return LdModalRoute<void>(
    context: sourceContext,
    modalTypeMode: LdModalTypeMode.sheet,
    pageBuilder: (modalContext) => LdScaffold(
      body: LdAppBar.top(
        title: Text(title),
        child: LdScaffoldBody(
          children: [
            ldFilterStateScope<T, IdType>(
              routerDelegate: routerDelegate,
              routeConfig: routeConfig,
              routerController: routerController,
              repository: repository,
              baseFilters: baseFilters,
              baseSortOptions: baseSortOptions,
              child: _LdFilterChipSheetContent<T, IdType>(
                filterName: filter.name,
              ),
            ),
          ],
        ),
      ),
    ),
  ).show(sourceContext);
}

/// Resolves the filter from [LdMonkeySortAndFilterState] on each build so sheet
/// controls (e.g. [RangeSlider]) stay in sync after router-driven updates.
class _LdFilterChipSheetContent<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _LdFilterChipSheetContent({required this.filterName});

  final String filterName;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterOption<T, IdType>>(
      context,
      filterName: filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }
    return filter.build(context).padM();
  }
}
