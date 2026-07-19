import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyScrollableDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final List<Widget> Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  const LdMonkeyScrollableDetailPage({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
        body: LdMonkeyDetailAppBars<T, IdType>(
      child: LdMonkeyViewingBuilder<T, IdType>(
        builder: (context, items) => LdScaffoldBody(children: builder(context, items)),
      ),
    ));
  }
}

class LdMonkeySingleDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) builder;

  const LdMonkeySingleDetailPage({
    required this.builder,
    this.titleBuilder,
    super.key,
  });

  final Widget? Function(BuildContext, LdPaginatorItem<T> item)? titleBuilder;

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdMonkeyViewingBuilder<T, IdType>(
        builder: (context, items) => LdWrapConditional(
          condition: titleBuilder != null,
          builder: (context, child) {
            final existingConfig = context.watch<LdMonkeyDetailAppbarConfig?>() ??
                LdMonkeyDetailAppbarConfig(appbarConfig: LdAppBarConfig());

            return Provider.value(
              value: LdMonkeyDetailAppbarConfig(
                  appbarConfig: existingConfig.appbarConfig?.copyWith(title: titleBuilder!(context, items.first))),
              child: child,
            );
          },
          child: LdMonkeyDetailAppBars<T, IdType>(
            child: builder(context, items.first),
          ),
        ),
      ),
    );
  }
}

/// Appplies the [LdMonkeyAppBar]s to the [child].
class LdMonkeyDetailAppBars<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget child;

  const LdMonkeyDetailAppBars({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdMonkeyAppBar<T, IdType>(
      location: LdMonkeyActionLocation.detailAppBar,
      child: LdMonkeyAppBar<T, IdType>(
        location: LdMonkeyActionLocation.detailSecondary,
        child: child,
      ),
    );
  }
}

class LdMonkeyViewingBuilder<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  final bool loadItems;
  final bool showLoaderWhileEmpty;

  const LdMonkeyViewingBuilder({
    super.key,
    required this.builder,
    this.showLoaderWhileEmpty = false,
    this.loadItems = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewing = LdMonkeySelection.of<T, IdType>(context, listen: true).viewing;

    return LdWrapConditional(
      condition: loadItems,
      builder: (context, child) {
        return _LdMonkeyViewingItemLoader<T, IdType>(
          ids: viewing,
          builder: (context, items) => child,
        );
      },
      child: _RepositoryWatchItems<T, IdType>(
        viewing: viewing,
        builder: (context) {
          final listController = LdListController.of<T, IdType>(context);

          if (viewing.isEmpty) {
            return const SizedBox.shrink();
          }

          return builder(context, viewing.map((id) => listController.getItemById(id)).nonNulls.toList());
        },
      ),
    );
  }
}

class _LdMonkeyViewingItemLoader<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Set<IdType> ids;
  final Widget Function(BuildContext context, List<LdPaginatorItem<T>> items) builder;

  const _LdMonkeyViewingItemLoader({
    required this.ids,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);

    return LdSubmit<List<LdPaginatorItem<T>>, Set<IdType>>(
      arg: ids,
      argEquals: (a, b) => setEquals(a, b),
      config: LdSubmitConfig(
        autoTrigger: true,
        allowResubmit: true,
        loadingText: l10n.detailItemLoading,
        action: (ids) async {
          if (ids == null) {
            throw StateError('Missing item id');
          }

          await Future.wait(
            ids.map((id) => LdListController.of<T, IdType>(context).loadViewingItem(context, id)).toList(),
          );

          return ids.map((id) => LdListController.of<T, IdType>(context).getItemById(id)).nonNulls.toList();
        },
      ),
      child: LdSubmitCenteredBuilder<List<LdPaginatorItem<T>>, Set<IdType>>(
        resultBuilder: (context, items, _) => builder(context, items),
      ),
    );
  }
}

class _RepositoryWatchItems<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Set<IdType> viewing;
  final Widget Function(BuildContext context) builder;

  const _RepositoryWatchItems({required this.viewing, required this.builder});

  @override
  State<_RepositoryWatchItems<T, IdType>> createState() => _RepositoryWatchItemsState<T, IdType>();
}

class _RepositoryWatchItemsState<T extends Identifiable<IdType>, IdType>
    extends State<_RepositoryWatchItems<T, IdType>> {
  StreamSubscription<List<LdPaginatorItem<T>>>? _itemsSubscription;

  void _onItemsChanged(List<LdPaginatorItem<T>> items) {
    setState(() {});
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _itemsSubscription =
        LdListController.of<T, IdType>(context).watchListOfItems(widget.viewing).listen(_onItemsChanged);
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.viewing, oldWidget.viewing)) {
      _itemsSubscription?.cancel();
      _itemsSubscription =
          LdListController.of<T, IdType>(context).watchListOfItems(widget.viewing).listen(_onItemsChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
