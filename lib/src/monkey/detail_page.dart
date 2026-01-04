import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// The page rendered by [LdMonkey] to show the detail of the selected
/// items
class LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget? primaryAppBar;
  final Widget? secondaryAppBar;
  final Widget body;

  const LdMonkeyDetailPage({
    this.primaryAppBar,
    this.secondaryAppBar,
    required this.body,
    super.key,
  });

  factory LdMonkeyDetailPage.scrollable({
    Widget? primaryAppBar,
    Widget? secondaryAppBar,
    required Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail,
  }) {
    return LdMonkeyDetailPage(
      primaryAppBar: primaryAppBar,
      secondaryAppBar: secondaryAppBar,
      body: LdMonkeyScrollableDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
    );
  }

  factory LdMonkeyDetailPage.stacked({
    Widget? primaryAppBar,
    Widget? secondaryAppBar,
    required Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail,
  }) {
    return LdMonkeyDetailPage(
      primaryAppBar: primaryAppBar,
      secondaryAppBar: secondaryAppBar,
      body: LdMonkeyStackDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      appBars: [
        primaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailAppBar),
        secondaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailSecondary),
      ],
      body: body,
    );
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
  late final StreamSubscription<Set<IdType>> _viewingSubscription;
  StreamSubscription<List<LdPaginatorItem<T>>>? _itemsSubscription;
  List<LdPaginatorItem<T>> _items = [];

  void _onSelectionChanged(Set<IdType> viewing) {
    _itemsSubscription?.cancel();
    _itemsSubscription = LdRepository.of<T, IdType>(context).watchListOfItems(viewing).listen(_onItemsChanged);
  }

  void _onItemsChanged(List<LdPaginatorItem<T>> items) {
    setState(() {
      _items = items;
    });
  }

  @override
  void dispose() {
    _viewingSubscription.cancel();
    _itemsSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final shellState = LdMonkeyShellState.of<T, IdType>(context);

    _viewingSubscription = shellState.viewingItemsStream.listen(_onSelectionChanged);
    _onSelectionChanged(shellState.viewingItems);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _items);
  }
}
