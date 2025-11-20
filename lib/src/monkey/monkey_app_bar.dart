import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyAppBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget? title;
  final LdMonkeyActionLocation location;
  final String? debugName;
  final List<Widget> additionalActions;
  const LdMonkeyAppBar({
    super.key,
    this.title,
    this.additionalActions = const [],
    required this.location,
    this.debugName,
  });

  LdFilterSearchOption<T, IdType, dynamic>? _getSearchFilter(BuildContext context) {
    final repository = LdRepository.of<T, IdType>(context);
    final searchFilter = repository.filters.values.firstWhereOrNull((filter) => filter is LdFilterSearchOption)
        as LdFilterSearchOption<T, IdType, dynamic>?;
    return searchFilter;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdMonkeyShellState<T, IdType>>();

    final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();
    final repository = LdRepository.of<T, IdType>(context);
    final searchFilter = _getSearchFilter(context);
    final showSearch = searchFilter != null && location == LdMonkeyActionLocation.masterSecondary;
    final actions = ldMonkeyAppBarActionsForLocation<T, IdType>(
      context,
      location,
    ).map((e) => e.build(context));
    if (showSearch == false && actions.isEmpty && additionalActions.isEmpty && title == null) {
      return const SizedBox.shrink();
    }
    return LdAppBar(
        debugName: debugName,
        shadowMode: location == LdMonkeyActionLocation.masterAppBar
            ? LdAppBarShadowMode.hidden
            : LdAppBarShadowMode.whenScrolled,
        implyLeading: switch (location) {
          LdMonkeyActionLocation.detailAppBar => effectiveLayout == LdMonkeyEffectiveLayoutMode.detail,
          _ => false,
        },
        searchConfig: switch (location) {
          LdMonkeyActionLocation.masterSecondary => searchFilter?.searchConfig((query) {
              repository.updateFilter(searchFilter.name, (filter) {
                filter as LdFilterSearchOption<T, IdType, dynamic>;
                return filter.copyWith(
                  isOn: query.isNotEmpty,
                  searchText: query,
                );
              });
            }),
          _ => null,
        },
        title: title,
        actions: [
          ...actions,
          ...additionalActions,
        ]);
  }
}
