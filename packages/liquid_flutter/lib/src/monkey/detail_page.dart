import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

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
  final Widget Function(BuildContext context, List<Widget> itemWidgets) builder;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildItem;
  final bool showLoaderWhileEmpty;

  const LdMonkeyStreamSelection({
    super.key,
    required this.builder,
    required this.buildItem,
    this.showLoaderWhileEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final viewing = LdMonkeySelection.of<T, IdType>(context, listen: true).viewing;

    return _RepositoryWatchItems<T, IdType>(
      viewing: viewing,
      builder: (context) {
        final listController = LdListController.of<T, IdType>(context);
        final itemWidgets = viewing.map((id) {
          final item = listController.getItemById(id);
          if (item != null) {
            return KeyedSubtree(
              key: ValueKey(id),
              child: buildItem(context, item),
            );
          }

          return KeyedSubtree(
            key: ValueKey(id),
            child: _LdMonkeyViewingItemLoader<T, IdType>(
              id: id,
              buildItem: buildItem,
            ),
          );
        }).toList();

        if (showLoaderWhileEmpty && viewing.isNotEmpty && itemWidgets.isEmpty) {
          return LdScaffold(
            body: LdScaffoldBodyCentered(child: const Center(child: LdLoader())),
          );
        }

        return builder(context, itemWidgets);
      },
    );
  }
}

class _LdMonkeyViewingItemLoader<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final IdType id;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildItem;

  const _LdMonkeyViewingItemLoader({
    required this.id,
    required this.buildItem,
  });

  @override
  Widget build(BuildContext context) {
    final existing = LdListController.of<T, IdType>(context).getItemById(id);
    if (existing != null) {
      return buildItem(context, existing);
    }

    final l10n = LiquidLocalizations.of(context);

    return LdSubmit<T, IdType>(
      arg: id,
      config: LdSubmitConfig<T, IdType>(
        autoTrigger: true,
        allowResubmit: true,
        loadingText: l10n.detailItemLoading,
        action: (loadId) {
          if (loadId == null) {
            throw StateError('Missing item id');
          }
          return LdListController.of<T, IdType>(context).loadViewingItem(context, loadId);
        },
      ),
      child: _LdMonkeyViewingItemSubmitBuilder<T, IdType>(
        buildItem: buildItem,
        loadErrorMessage: l10n.detailItemLoadError,
      ),
    );
  }
}

class _LdMonkeyViewingItemSubmitBuilder<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildItem;
  final String loadErrorMessage;

  const _LdMonkeyViewingItemSubmitBuilder({
    required this.buildItem,
    required this.loadErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<T, IdType>>();
    final state = controller.state;

    return switch (state.type) {
      LdSubmitStateType.loading || LdSubmitStateType.idle => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LdLoader(size: 32),
              ldSpacerS,
              LdText.p(LiquidLocalizations.of(context).detailItemLoading),
            ],
          ),
        ),
      LdSubmitStateType.error => Center(
          child: LdExceptionView(
            exception: LdLocalizedException.fromLdException(
              exception: state.error!,
              message: loadErrorMessage,
            ),
            direction: Axis.vertical,
            retryController: controller.retryController,
          ),
        ),
      LdSubmitStateType.result => buildItem(
          context,
          LdPaginatorItem<T>(
            value: state.result as T,
            state: LdPaginatorItemState.loaded,
          ),
        ),
    };
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
