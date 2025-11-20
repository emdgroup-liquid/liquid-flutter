import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_app_bar.dart';
import 'package:liquid_flutter/src/monkey/monkey_scrollable_detail_view.dart';

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
    return LdScaffold(
      appBar: primaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailAppBar),
      secondaryAppBar: secondaryAppBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.detailSecondary),
      body: LdMonkeyScrollableDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
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

    final shellState = LdMonkeyShellState.of<T, IdType>(context);

    _selectionSubscription = shellState.selectedItemsStream.listen(_onSelectionChanged);
    _onSelectionChanged(shellState.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _items);
  }
}
