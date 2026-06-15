import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// The page rendered by [LdMonkey] to show the detail of the selected
/// items
class LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget body;
  final LdAppBarConfig? secondaryAppBarConfig;
  final LdAppBarConfig? primaryAppBarConfig;

  const LdMonkeyDetailPage({
    required this.body,
    this.secondaryAppBarConfig,
    this.primaryAppBarConfig,
    super.key,
  });

  factory LdMonkeyDetailPage.scrollable({
    required Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail,
    LdAppBarConfig? secondaryAppBarConfig,
    LdAppBarConfig? primaryAppBarConfig,
  }) {
    return LdMonkeyDetailPage(
      body: LdMonkeyScrollableDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
      secondaryAppBarConfig: secondaryAppBarConfig,
      primaryAppBarConfig: primaryAppBarConfig,
    );
  }

  factory LdMonkeyDetailPage.stacked({
    required Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail,
    LdAppBarConfig? secondaryAppBarConfig,
    LdAppBarConfig? primaryAppBarConfig,
  }) {
    return LdMonkeyDetailPage(
      body: LdMonkeyStackDetailView<T, IdType>(
        buildDetail: buildDetail,
      ),
      secondaryAppBarConfig: secondaryAppBarConfig,
      primaryAppBarConfig: primaryAppBarConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdWrapConditional(
      condition: primaryAppBarConfig != null,
      builder: (context, child) => LdAppBarConfigProvider(config: primaryAppBarConfig!, child: child),
      child: LdMonkeyAppBar<T, IdType>(
        location: LdMonkeyActionLocation.detailAppBar,
        child: LdAppBarConfigProvider(
          config: secondaryAppBarConfig ?? const LdAppBarConfig(),
          ignoreParent: true,
          child: LdMonkeyAppBar<T, IdType>(
            location: LdMonkeyActionLocation.detailSecondary,
            child: body,
          ),
        ),
      ),
    );
  }
}

class LdMonkeyStreamSelection<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  const LdMonkeyStreamSelection({super.key, required this.builder});

  @override
  build(BuildContext context) {
    return _RepostoryWatchItems<T, IdType>(
      viewing: LdMonkeySelection.of<T, IdType>(context, listen: true).viewing,
      builder: builder,
    );
  }
}

class _RepostoryWatchItems<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Set<IdType> viewing;
  final Widget Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  const _RepostoryWatchItems({required this.viewing, required this.builder});

  @override
  State<_RepostoryWatchItems<T, IdType>> createState() => _RepostoryWatchItemsState<T, IdType>();
}

class _RepostoryWatchItemsState<T extends Identifiable<IdType>, IdType> extends State<_RepostoryWatchItems<T, IdType>> {
  StreamSubscription<List<LdPaginatorItem<T>>>? _itemsSubscription;
  List<LdPaginatorItem<T>> _items = [];

  void _onItemsChanged(List<LdPaginatorItem<T>> items) {
    setState(() {
      _items = items;
    });
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _itemsSubscription = LdRepository.of<T, IdType>(context).watchListOfItems(widget.viewing).listen(_onItemsChanged);
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.viewing, oldWidget.viewing)) {
      _itemsSubscription?.cancel();
      _itemsSubscription = LdRepository.of<T, IdType>(context).watchListOfItems(widget.viewing).listen(_onItemsChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _items);
  }
}
