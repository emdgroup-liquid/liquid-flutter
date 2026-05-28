import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_route_state_parser.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdModalRoute ldFilterModal<T extends Identifiable<IdType>, IdType>(BuildContext sourceContext) {
  final routerDelegate = GoRouter.of(sourceContext).routerDelegate;
  final routeConfig = sourceContext.read<LdMonkeyRouteConfig<T, IdType>>();
  final routerController = sourceContext.read<LdMonkeyRouterController<T, IdType>>();
  final repository = sourceContext.read<LdRepository<T, IdType>>();
  final baseSortAndFilterState = sourceContext.read<LdMonkeySortAndFilterState<T, IdType>>();
  final baseFilters = baseSortAndFilterState.filters.toList(growable: false);
  final baseSortOptions = baseSortAndFilterState.sortOptions.toList(growable: false);

  return LdModalRoute(
    context: sourceContext,
    // Rebuild modal state from router changes while the sheet is still open.
    pageBuilder: (modalContext) => ListenableBuilder(
      listenable: routerDelegate,
      builder: (modalContext, _) {
        final state = routerDelegate.state;
        final query = state.uri.queryParameters;

        // Keep selection/viewing in sync with the URL-backed router state.
        final selection = LdMonkeyRouteStateParser.parseSelection<T, IdType>(
          routeConfig: routeConfig,
          query: query,
          pathParameters: state.pathParameters,
        );

        final sortAndFilterState = LdMonkeyRouteStateParser.parseSortAndFilter<T, IdType>(
          routeConfig: routeConfig,
          baseFilters: baseFilters,
          baseSortOptions: baseSortOptions,
          query: query,
        );

        return LdScaffold(
          body: LdAppBar(
            title: Text(LiquidLocalizations.of(modalContext).filter),
            child: LdScaffoldBody(
              children: [
                MultiProvider(
                  providers: [
                    Provider<LdMonkeyRouteConfig<T, IdType>>.value(
                      value: routeConfig,
                    ),
                    Provider<LdMonkeyRouterController<T, IdType>>.value(
                      value: routerController,
                    ),
                    Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                      value: sortAndFilterState,
                    ),
                    Provider<LdMonkeySelection<T, IdType>>.value(value: selection),
                    ListenableProvider<LdRepository<T, IdType>>.value(
                      value: repository,
                    ),
                  ],
                  child: LdFilterModal<T, IdType>(),
                ),
              ],
            ),
          ),
        );
      },
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
        // This callback can run outside a normal build, so we must not listen here.
        Provider.value(value: LdMonkeySortAndFilterState.of<T, IdType>(context, listen: false)),
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
