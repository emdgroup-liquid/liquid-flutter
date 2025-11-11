import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

/// The page rendered by [LdMonkey] to show the detail of the selected
/// items
class LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget? primaryAppBar;
  final Widget? secondaryAppBar;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;

  const LdMonkeyDetailPage({
    this.primaryAppBar,
    this.secondaryAppBar,
    required this.buildDetail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shellState = LdMonkeyShellState.of<T, IdType>(context);
    final repository = LdRepository.of<T, IdType>(context);

    return LdScaffold(
      appBar: primaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailAppBar),
      secondaryAppBar: secondaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailSecondary),
      body: LdMonkeyScrollableDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
    );
  }
}

class LdMonkeyAppBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget? title;
  final LdMonkeyActionLocation location;

  final List<Widget> additionalActions;
  const LdMonkeyAppBar({super.key, this.title, this.additionalActions = const [], required this.location});

  LdFilterSearchOption<T, IdType, dynamic>? _getSearchFilter(BuildContext context) {
    final repository = LdRepository.of<T, IdType>(context);
    final searchFilter = repository.filters.values.firstWhereOrNull((filter) => filter is LdFilterSearchOption)
        as LdFilterSearchOption<T, IdType, dynamic>?;
    return searchFilter;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdMonkeyShellState<T, IdType>>();

    print("building ld monkey app bar ${location}");
    final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();
    final repository = LdRepository.of<T, IdType>(context);
    final searchFilter = _getSearchFilter(context);
    final actions = ldMonkeyAppBarActionsForLocation<T, IdType>(
      context,
      location,
    ).map((e) => e.build(context));
    if (searchFilter == null && actions.isEmpty && additionalActions.isEmpty && title == null) {
      return const SizedBox.shrink();
    }
    return LdAppBar(
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

class LdMonkeyStreamSelection<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  const LdMonkeyStreamSelection({super.key, required this.builder});

  @override
  State<LdMonkeyStreamSelection<T, IdType>> createState() => _LdMonkeyStreamSelectionState<T, IdType>();
}

class _LdMonkeyStreamSelectionState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyStreamSelection<T, IdType>> {
  late final StreamSubscription<Set<IdType>> _selectionSubscription;
  StreamSubscription<List<LdPaginatorItem<T>>>? _itemsSubscription;
  List<LdPaginatorItem<T>> _items = [];

  void _onSelectionChanged(Set<IdType> selection) {
    _itemsSubscription?.cancel();
    _itemsSubscription = LdRepository.of<T, IdType>(context).watchListOfItems(selection).listen(_onItemsChanged);
  }

  void _onItemsChanged(List<LdPaginatorItem<T>> items) {
    setState(() {
      _items = items;
    });
  }

  @override
  void dispose() {
    _selectionSubscription.cancel();
    _itemsSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _selectionSubscription = LdMonkeyShellState.of<T, IdType>(context).selectedItemsStream.listen(_onSelectionChanged);
    _onSelectionChanged(LdMonkeyShellState.of<T, IdType>(context).selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _items);
  }
}

class LdMonkeyScrollableDetailView<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;
  const LdMonkeyScrollableDetailView({super.key, required this.buildDetail});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyStreamSelection<T, IdType>(
      builder: (context, items) => LdScaffoldBody(
        children: [
          ...items.map((e) => KeyedSubtree(key: ValueKey(e.value?.id), child: buildDetail(context, e))),
        ],
      ),
    );
  }
}

class LdMonkeyStackDetailView<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;
  const LdMonkeyStackDetailView({super.key, required this.buildDetail});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyStreamSelection<T, IdType>(
      builder: (context, items) => Stack(children: [
        ...items.mapIndexed(
          (index, e) => LdSpring(
              initialPosition: 0,
              builder: (context, state, child) {
                final position = max(0, state.position);
                return Transform.scale(
                    scale: 1 - (position * 0.02),
                    child: Transform.rotate(
                      angle: index % 3 * 0.02,
                      child: Transform.translate(
                        offset: Offset(0, position * 5),
                        child: child,
                      ),
                    ));
              },
              child: switch (e.state) {
                LdPaginatorItemState.deleting ||
                LdPaginatorItemState.filteredOut ||
                LdPaginatorItemState.deleted =>
                  LdReveal.quick(
                    revealed: false,
                    initialRevealed: true,
                    child: buildDetail(context, e),
                  ),
                _ => buildDetail(context, e),
              }),
        ),
      ]),
    );
  }
}
