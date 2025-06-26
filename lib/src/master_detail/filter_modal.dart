import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/filter/ld_filter_any_of.dart';
import 'package:liquid_flutter/src/master_detail/filter/ld_filter_any_of_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:liquid_flutter/src/master_detail/filter/ld_filter_one_of.dart';
import 'package:liquid_flutter/src/master_detail/filter/ld_filter_one_of_widget.dart';
import 'package:liquid_flutter/src/master_detail/filter/ld_filter_range.dart';

LdModal ldFilterModal<T extends Identifiable<IdType>, IdType, GroupBy>(
    BuildContext context, LdMasterDetailRoute<T, IdType, GroupBy> route) {
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

class LdFilterModal<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  final LdMasterDetailRoute<T, IdType, GroupBy> route;

  const LdFilterModal({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final repository = route.repository;
    final filter = repository.filterStream;

    return StreamBuilder(
        stream: filter,
        initialData: repository.filters,
        builder: (context, asyncSnapshot) {
          return LdAutoSpace(children: [
            LdMute(child: LdText(LiquidLocalizations.of(context).filter)),
            Wrap(
              children: asyncSnapshot.data!
                  .where((e) => !e.isOn)
                  .map(
                    (e) => LdButtonOutline(
                        leading: e.icon(context),
                        child: Text(e.label(context)),
                        onPressed: () {
                          e.isOn = true;
                          repository.updateFilter(e);
                        }),
                  )
                  .toList(),
            ).spaceS(),
            LdMute(child: LdText(LiquidLocalizations.of(context).activeFilters)),
            ...asyncSnapshot.data!.where((e) => e.isOn).map((e) => _Filter(
                filter: e,
                onFilterChanged: (filter) {
                  repository.updateFilter(filter);
                })),
          ]);
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
      return Row(
        children: [
          Expanded(
            child: LdListItem(
              borderRadius: LdTheme.of(context).radius(LdSize.m),
              title: Text(filter.label(context)),
              leading: filter.icon(context),
            ),
          ),
          ldSpacerM,
          LdButtonVague(
            child: const Icon(LucideIcons.x),
            onPressed: () {
              filter.isOn = false;
              onFilterChanged(filter);
            },
          ),
        ],
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
    return LdText(filter.label(context));
  }
}
