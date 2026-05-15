import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdModalRoute ldFilterModal<T extends Identifiable<IdType>, IdType>(BuildContext context) {
  return LdModalRoute(
    context: context,
    pageBuilder: (_) => LdScaffold(
      body: LdAppBar(
        title: Text(LiquidLocalizations.of(context).filter),
        child: LdScaffoldBody(
          children: [
            MultiProvider(
              providers: [
                Provider<LdMonkeyRouteConfig<T, IdType>>.value(
                  value: context.watch<LdMonkeyRouteConfig<T, IdType>>(),
                ),
                Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                  value: context.watch<LdMonkeySortAndFilterState<T, IdType>>(),
                ),
                Provider<LdMonkeySelection<T, IdType>>.value(value: context.watch<LdMonkeySelection<T, IdType>>()),
                ListenableProvider<LdRepository<T, IdType>>.value(
                  value: context.watch<LdRepository<T, IdType>>(),
                ),
              ],
              child: LdFilterModal<T, IdType>(),
            ),
          ],
        ),
      ),
    ),
  );
}

class LdFilterContextMenu<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdFilterContextMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final repository = LdRepository.of<T, IdType>(context);
    final activeFilters = LdMonkeySortAndFilterState.of<T, IdType>(context).activeFilters.length;
    return LdContextMenu(
      builder: (context, isShuttle, open, isOpen, child) => LdAppBarAction(
        active: activeFilters > 0,
        leading: const Icon(LucideIcons.listFilter),
        child: Text(LiquidLocalizations.of(context).filter),
        onPressed: () {
          open();
        },
      ),
      menuProviders: (context) => [
        ListenableProvider.value(value: repository),
        Provider.value(value: LdMonkeySortAndFilterState.of<T, IdType>(context, listen: true)),
      ],
      menuBuilder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: LdFilterModal<T, IdType>().padM(),
      ),
    );
  }
}

class LdFilterModal<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdFilterModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortAndFilterState = context.watch<LdMonkeySortAndFilterState<T, IdType>>();

    final filters = sortAndFilterState.filters;
    final sortOptions = sortAndFilterState.sortOptions;

    final activeFilters = filters.where((e) => e.isOn).toList();
    final inactiveFilters = filters.where((e) => !e.isOn).toList();

    return LdAutoSpace(children: [
      if (sortOptions.isNotEmpty) ...[
        LdMute(child: LdText(LiquidLocalizations.of(context).sort)).insetLeft(size: LdSize.s),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...sortAndFilterState.sortOptions.map(
              (e) => LdListItem(
                borderRadius: LdTheme.of(context).radius(LdSize.s),
                active: e.isOn,
                title: Text(e.label(context)),
                trailing: switch (e.isOn) {
                  true => Row(
                      children: [
                        LdSwitch(
                          children: {
                            "asc": Text("Asc"),
                            "desc": Text("Desc"),
                          },
                          value: e.direction.name,
                          onChanged: (value) {
                            final newSortOptions = sortOptions.map((i) {
                              if (i.name == e.name) {
                                return e.copyWith(
                                    direction: value == "asc" ? LdSortOptionDirection.asc : LdSortOptionDirection.desc,
                                    isOn: true);
                              }
                              return i;
                            }).toList();
                            LdMonkeySortAndFilterState.updateSortOptions(
                              context,
                              newSortOptions,
                            );
                          },
                        ),
                        LdButton.vague(
                          circular: false,
                          onPressed: () {
                            final newSortOptions = sortOptions.map((i) {
                              if (i.name == e.name) {
                                return e.copyWith(isOn: false);
                              }
                              return i;
                            }).toList();
                            LdMonkeySortAndFilterState.updateSortOptions(
                              context,
                              newSortOptions,
                            );
                          },
                          child: Icon(LucideIcons.x),
                        ),
                      ],
                    ).spaceS(),
                  false => LdButton.vague(
                      circular: false,
                      child: Icon(LucideIcons.plus),
                      onPressed: () {
                        final newSortOptions = sortOptions.map((i) {
                          if (i.name == e.name) {
                            return e.copyWith(isOn: true);
                          }
                          return i;
                        }).toList();
                        LdMonkeySortAndFilterState.updateSortOptions(
                          context,
                          newSortOptions,
                        );
                      }),
                },
                onSelectionChanged: (selected) {
                  final newSortOptions = sortOptions.map((i) {
                    if (i.name == e.name) {
                      return e.copyWith(isOn: false);
                    }
                    return i;
                  }).toList();
                  LdMonkeySortAndFilterState.updateSortOptions(
                    context,
                    newSortOptions,
                  );
                },
              ),
            ),
          ],
        ),
        const LdDivider(),
      ],
      LdReveal.quick(
        revealed: activeFilters.isNotEmpty,
        child: LdAutoSpace(
          children: [
            LdText.caption(LiquidLocalizations.of(context).activeFilters),
            LdCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                ...activeFilters.map((e) => LdReveal.quick(
                      revealed: e.isOn,
                      initialRevealed: e.isOn,
                      child: e.build(context),
                    )),
              ]),
            ),
          ],
        ),
      ),
      if (inactiveFilters.isNotEmpty)
        LdReveal.quick(
          revealed: inactiveFilters.isNotEmpty,
          child: LdText.caption(LiquidLocalizations.of(context).filter),
        ),
      LdReveal.quick(
        revealed: inactiveFilters.isNotEmpty,
        child: Wrap(
          children: inactiveFilters.map((e) {
            final isEnabled = e.isEnabled?.call(context) ?? true;

            return LdReveal.quick(
              revealed: !e.isOn,
              initialRevealed: !e.isOn,
              child: LdButton.outline(
                  leading: e.icon(context),
                  disabled: !isEnabled,
                  child: Text(e.label(context)),
                  onPressed: () {
                    LdMonkeySortAndFilterState.updateFilter(context, e.copyWith(isOn: true));
                  }),
            );
          }).toList(),
        ).spaceS().padS(),
      ),
    ]).padVertical();
  }
}
