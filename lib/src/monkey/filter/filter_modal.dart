import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdModalRoute ldFilterModal<T extends Identifiable<IdType>, IdType>(BuildContext context) {
  final repository = LdRepository.of<T, IdType>(context);
  return LdModalRoute(
    context: context,
    pageBuilder: (context) => LdScaffold(
      appBars: [
        LdAppBar(
          title: Text(LiquidLocalizations.of(context).filter),
        ),
      ],
      body: LdScaffoldBody(
        children: [
          ListenableProvider<LdRepository<T, IdType>>.value(
            value: repository,
            child: LdFilterModal<T, IdType>(),
          ),
        ],
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
    final activeFilters = repository.activeFilters.length;
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
    final repository = LdRepository.of<T, IdType>(context);
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
                            selectionControl: LdSelectionControl.radio,
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
                child: LdText.caption(LiquidLocalizations.of(context).filter),
              ),
            LdReveal.quick(
              revealed: inactiveFilters.isNotEmpty,
              child: Wrap(
                children: asyncSnapshot.data!
                    .map(
                      (e) => LdReveal.quick(
                        revealed: !e.isOn,
                        initialRevealed: !e.isOn,
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
              child: LdText.caption(LiquidLocalizations.of(context).activeFilters),
            ),
            Column(children: [
              ...asyncSnapshot.data!.map((e) => LdReveal.quick(
                    revealed: e.isOn,
                    initialRevealed: e.isOn,
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
    final repository = LdRepository.of<T, IdType>(context);
    return filter.build(context, repository);
  }
}
