import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';

LdModalRoute ldFilterModal<T extends Identifiable<IdType>, IdType>(BuildContext context, LdMonkey<T, IdType> route) {
  return LdModalRoute(
    context: context,
    pageBuilder: (context) => LdScaffold(
      appBar: LdAppBar(
        title: Text(LiquidLocalizations.of(context).filter),
      ),
      body: LdScaffoldBody(children: [LdFilterModal(route: route)]),
    ),
  );
}

class LdFilterContextMenu<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdFilterContextMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.read<LdMonkey<T, IdType>>();
    return LdContextMenu(
      builder: (context, isOpen, open, child) => LdButton.ghost(
        autoLoading: false,
        child: Text(LiquidLocalizations.of(context).filter),
        onPressed: () {
          open();
        },
      ),
      menuBuilder: (context, onDismiss) => LdFilterModal(route: route),
    );
  }
}

class LdFilterModal<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdMonkey<T, IdType> route;

  const LdFilterModal({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final repository = route.repository;
    final filter = repository.filterStream;

    return StreamBuilder(
        stream: filter,
        initialData: repository.filters.values.toList(),
        builder: (context, asyncSnapshot) {
          final filters = asyncSnapshot.data!;

          final activeFilters = filters.where((e) => e.isOn).toList();
          final inactiveFilters = filters.where((e) => !e.isOn).toList();

          return LdAutoSpace(children: [
            LdMute(child: LdText(LiquidLocalizations.of(context).sort)).insetLeft(size: LdSize.s),
            StreamBuilder(
                stream: repository.sortStream,
                builder: (context, asyncSnapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: repository.sortOptions
                        .map(
                          (e) => LdListItem(
                            borderRadius: LdTheme.of(context).radius(LdSize.s),
                            isSelected: e.isOn,
                            title: Text(e.label(context)),
                            trailing: e.icon(context),
                            onSelectionChanged: (selected) {
                              repository.setActiveSortOption(e.name);
                            },
                          ),
                        )
                        .toList(),
                  ).spaceS().padS();
                }),
            const LdDivider(),
            if (inactiveFilters.isNotEmpty)
              LdReveal.quick(
                revealed: inactiveFilters.isNotEmpty,
                child: LdMute(child: LdText(LiquidLocalizations.of(context).filter)).insetLeft(size: LdSize.s),
              ),
            LdReveal.quick(
              revealed: inactiveFilters.isNotEmpty,
              child: Wrap(
                children: asyncSnapshot.data!
                    .map(
                      (e) => LdReveal.quick(
                        revealed: !e.isOn,
                        child: LdButton.outline(
                            leading: e.icon(context),
                            child: Text(e.label(context)),
                            onPressed: () {
                              repository.updateFilter(
                                e.name,
                                (filter) => filter!.copyWith(isOn: true),
                              );
                            }),
                      ),
                    )
                    .toList(),
              ).spaceS().padS(),
            ),
            LdReveal.quick(
              revealed: activeFilters.isNotEmpty,
              child: LdMute(child: LdText(LiquidLocalizations.of(context).activeFilters)).insetLeft(size: LdSize.s),
            ),
            Column(children: [
              ...asyncSnapshot.data!.map((e) => LdReveal.quick(
                    revealed: e.isOn,
                    child: _Filter(
                      filter: e,
                    ),
                  )),
            ]),
          ]).padVertical();
        });
  }
}

class _Filter<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  final LdFilterOption<T, IdType> filter;

  const _Filter({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<LdMonkey<T, IdType>>().repository;
    if (filter is LdFilterBoolOption) {
      return LdListItem(
        title: Text(filter.label(context)),
        leading: LdAvatar(child: filter.icon(context)),
        trailing: LdButton.vague(
          child: const Icon(LucideIcons.x),
          size: LdSize.s,
          onPressed: () {
            repository.updateFilter(
              filter.name,
              (filter) => filter!.copyWith(isOn: false),
            );
          },
        ),
      );
    }
    if (filter is LdFilterRange<T, IdType>) {
      return LdFilterRangeWidget(
        filter: filter as LdFilterRange<T, IdType>,
      );
    }
    if (filter is LdFilterOneOf<T, IdType, dynamic>) {
      final selectFilter = filter as LdFilterOneOf<T, IdType, dynamic>;
      return LdFilterOneOfWidget<T, IdType, dynamic>(
        filter: selectFilter,
      );
    }
    if (filter is LdFilterAnyOf<T, IdType, dynamic>) {
      final selectFilter = filter as LdFilterAnyOf<T, IdType, dynamic>;
      return LdFilterAnyOfWidget<T, IdType, dynamic>(
        filter: selectFilter,
      );
    }
    if (filter is LdFilterSearchOption<T, IdType, dynamic>) {
      final searchFilter = filter as LdFilterSearchOption<T, IdType, dynamic>;
      return Row(
        children: [
          Expanded(
            child: Text(searchFilter.searchText),
          ),
          LdButton.vague(
            child: const Icon(LucideIcons.x),
            size: LdSize.s,
            onPressed: () {
              repository.updateFilter(
                filter.name,
                (filter) => filter!.copyWith(isOn: false),
              );
            },
          ),
        ],
      ).padM();
    }
    return LdText(filter.label(context));
  }
}
