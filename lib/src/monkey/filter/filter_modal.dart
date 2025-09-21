import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';

LdModal ldFilterModal<T extends Identifiable<IdType>, IdType, GroupBy>(
    BuildContext context, LdMonkey<T, IdType, GroupBy> route) {
  return LdModal(
    showDismissButton: false,
    modalContent: (context) {
      return LdFilterModal(route: route);
    },
    actionBar: (context) => LdButtonVague(
      child: Text(LiquidLocalizations.of(context).apply),
      size: LdSize.l,
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}

class LdFilterContext<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  const LdFilterContext({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.read<LdMonkey<T, IdType, GroupBy>>();
    return LdContextMenu(
      builder: (context, isOpen, open, child) => LdButtonGhost(
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

class LdFilterModal<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  final LdMonkey<T, IdType, GroupBy> route;

  const LdFilterModal({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final repository = route.repository;
    final filter = repository.filterStream;

    return StreamBuilder(
        stream: filter,
        initialData: repository.filters,
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
                            showSelectionControls: true,
                            radioSelection: true,
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
                        child: LdButtonOutline(
                            leading: e.icon(context),
                            child: Text(e.label(context)),
                            onPressed: () {
                              e.isOn = true;
                              repository.updateFilter(e);
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
                      onFilterChanged: (filter) {
                        repository.updateFilter(filter);
                      },
                    ),
                  )),
            ]),
          ]).padVertical();
        });
  }
}

class _Filter<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  final LdFilterOption<T, IdType> filter;
  final void Function(LdFilterOption<T, IdType>) onFilterChanged;

  const _Filter({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (filter is LdFilterBoolOption) {
      return LdListItem(
        title: Text(filter.label(context)),
        leading: LdAvatar(child: filter.icon(context)),
        trailing: LdButtonVague(
          child: const Icon(LucideIcons.x),
          size: LdSize.s,
          onPressed: () {
            filter.isOn = false;
            onFilterChanged(filter);
          },
        ),
      );
    }
    if (filter is LdFilterRange<T, IdType>) {
      return LdFilterRangeWidget(filter: filter as LdFilterRange<T, IdType>, onFilterChanged: onFilterChanged);
    }
    if (filter is LdFilterOneOf<T, IdType, dynamic>) {
      final selectFilter = filter as LdFilterOneOf<T, IdType, dynamic>;
      return LdFilterOneOfWidget<T, IdType, dynamic>(
        filter: selectFilter,
        onFilterChanged: (f) => onFilterChanged(f),
      );
    }
    if (filter is LdFilterAnyOf<T, IdType, dynamic>) {
      final selectFilter = filter as LdFilterAnyOf<T, IdType, dynamic>;
      return LdFilterAnyOfWidget<T, IdType, dynamic>(
        filter: selectFilter,
        onFilterChanged: (f) => onFilterChanged(f),
      );
    }
    if (filter is LdFilterSearchOption<T, IdType, dynamic>) {
      final searchFilter = filter as LdFilterSearchOption<T, IdType, dynamic>;
      return Row(
        children: [
          Expanded(
            child: LdFilterSearchWidget(
              filter: searchFilter,
              onFilterChanged: (f) => onFilterChanged(f),
            ),
          ),
          LdButtonVague(
            child: const Icon(LucideIcons.x),
            size: LdSize.s,
            onPressed: () {
              searchFilter.isOn = false;
              onFilterChanged(searchFilter);
            },
          ),
        ],
      ).padM();
    }
    return LdText(filter.label(context));
  }
}
