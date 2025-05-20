import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

part 'crud_master_detail.dart';

typedef LdMasterDetailOnOpenItem<T> = Future<bool> Function(T item);
typedef LdMasterDetailOnOpenItemChange<T> = void Function(T? item);
typedef LdMasterBuilder<T, W> = W Function(
  BuildContext context,
  T? openItem,
  bool isSeparatePage,
  LdMasterDetailController<T> controller,
);
typedef LdDetailBuilder<T, W> = W Function(
  BuildContext context,
  T item,
  bool isSeparatePage,
  LdMasterDetailController<T> controller,
);

class LdMasterDetailBuilders<T> {
  final LdDetailBuilder<T, Widget>? buildDetailTitle;
  final LdMasterBuilder<T, Widget>? buildMasterTitle;
  final LdDetailBuilder<T, Widget> buildDetail;
  final LdMasterBuilder<T, Widget> buildMaster;
  final LdMasterBuilder<T, List<Widget>>? buildMasterActions;
  final LdDetailBuilder<T, List<Widget>>? buildDetailActions;
  final bool Function(T? openItem)? isMasterAppBarLoading;
  final bool Function(T? openItem)? isDetailAppBarLoading;
  final List<InheritedProvider> Function(BuildContext context)? injectables;

  const LdMasterDetailBuilders({
    this.buildDetailTitle,
    this.buildMasterTitle,
    required this.buildDetail,
    required this.buildMaster,
    this.buildMasterActions,
    this.buildDetailActions,
    this.isMasterAppBarLoading,
    this.isDetailAppBarLoading,
    this.injectables,
  });
}

enum MasterDetailPresentationMode { page, dialog }

enum MasterDetailLayoutMode { auto, split, compact }

/// A master detail view that shows a list of items on the left and a detail view on the right.
/// The detail view is shown as a page or a dialog if the screen is small.
class LdMasterDetail<T> extends StatefulWidget {
  final String? routeConfigId;

  final T? openItem;

  final double masterDetailFlex;

  final NavigatorState? navigator;

  final MasterDetailPresentationMode detailPresentationMode;

  final MasterDetailLayoutMode layoutMode;

  final LdMasterDetailOnOpenItemChange<T>? onOpenItemChange;

  final bool Function(SizingInformation size)? customSplitPredicate;

  final bool Function(T? openItem)? isMasterAppBarLoading;
  final bool Function(T? openItem)? isDetailAppBarLoading;

  // Callback functions to replace the builder class
  final LdDetailBuilder<T, Widget>? buildDetailTitle;
  final LdMasterBuilder<T, Widget>? buildMasterTitle;
  final LdDetailBuilder<T, Widget> buildDetail;
  final LdMasterBuilder<T, Widget> buildMaster;
  final LdMasterBuilder<T, List<Widget>>? buildMasterActions;
  final LdDetailBuilder<T, List<Widget>>? buildDetailActions;
  final List<InheritedProvider> Function(BuildContext context)? injectables;

  const LdMasterDetail({
    this.routeConfigId,
    this.buildDetailTitle,
    this.buildMasterTitle,
    required this.buildDetail,
    required this.buildMaster,
    this.buildMasterActions,
    this.buildDetailActions,
    this.detailPresentationMode = MasterDetailPresentationMode.page,
    this.layoutMode = MasterDetailLayoutMode.auto,

    /// The initial item to show in the detail widget.
    this.openItem,
    this.navigator,

    /// Called when an item is opened or closed.
    this.onOpenItemChange,

    /// The flex value for the detail widget. Defaults to 3.
    this.masterDetailFlex = 3,

    /// A custom predicate to determine if the split view should be used.
    this.customSplitPredicate,
    this.isMasterAppBarLoading,
    this.isDetailAppBarLoading,

    /// A list of providers to be injected to provide context to the [LdMasterDetail] widget.
    ///
    /// This is useful to provide dependencies to the detail widget, such as a repository or a service.
    ///
    /// Simply wrapping the [LdMasterDetail] widget with a [Provider] is not enough, as [LdMasterDetail] can open
    /// the detail widget in a separate page or dialog, and the provider would not be available in that context.
    this.injectables,
    super.key,
  });

  /// Convenience constructor to create a [LdMasterDetail] with a [LdMasterDetailBuilders] object.
  /// This is useful to avoid boilerplate code when creating the master and detail widgets.
  factory LdMasterDetail.builders({
    required LdMasterDetailBuilders<T> builders,
    T? openItem,
    double masterDetailFlex = 3,
    NavigatorState? navigator,
    MasterDetailPresentationMode detailPresentationMode = MasterDetailPresentationMode.page,
    MasterDetailLayoutMode layoutMode = MasterDetailLayoutMode.auto,
    LdMasterDetailOnOpenItemChange<T>? onOpenItemChange,
    bool Function(SizingInformation size)? customSplitPredicate,
    String? routeConfigId,
  }) {
    return LdMasterDetail<T>(
      buildDetailTitle: builders.buildDetailTitle,
      buildMasterTitle: builders.buildMasterTitle,
      buildDetail: builders.buildDetail,
      buildMaster: builders.buildMaster,
      buildMasterActions: builders.buildMasterActions,
      buildDetailActions: builders.buildDetailActions,
      openItem: openItem,
      navigator: navigator,
      detailPresentationMode: detailPresentationMode,
      layoutMode: layoutMode,
      onOpenItemChange: onOpenItemChange,
      masterDetailFlex: masterDetailFlex,
      customSplitPredicate: customSplitPredicate,
      isMasterAppBarLoading: builders.isMasterAppBarLoading,
      isDetailAppBarLoading: builders.isDetailAppBarLoading,
      injectables: builders.injectables,
      routeConfigId: routeConfigId,
    );
  }

  /// Helper function to create a router configuration that uses this component
  /// as a shell route.
  static ShellRoute createShellRoute<T>({
    required Widget child,
    required String basePath,
    required LdMasterDetailShellRouteConfig<T> routeConfig,
    Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
  }) {
    return createMasterDetailShellRoute<T>(
      child: child,
      basePath: basePath,
      routeConfig: routeConfig,
      pageBuilder: pageBuilder,
    );
  }

  /// Helper function to create a router configuration that handles multiple master-detail
  /// components, each with its own sub-route.
  static ShellRoute createCompositeShellRoute({
    required Widget child,
    required String basePath,
    required List<LdMasterDetailShellRouteConfig> routeConfigs,
    Page Function(BuildContext context, GoRouterState state, Widget child)? pageBuilder,
  }) {
    return createMasterDetailCompositeShellRoute(
      child: child,
      basePath: basePath,
      routeConfigs: routeConfigs,
      pageBuilder: pageBuilder,
    );
  }

  @override
  State<LdMasterDetail<T>> createState() => _LdMasterDetailState<T>();
}

class _LdMasterDetailState<T> extends State<LdMasterDetail<T>> with SingleTickerProviderStateMixin {
  T? _openItem;

  late final LdMasterDetailRouteConfig? _routeConfig = Provider.of<LdMasterDetailRouteConfig?>(context, listen: false);
  LdMasterDetailShellRouteConfig<T>? get _detailRouteConfig =>
      _routeConfig?.value[widget.routeConfigId ?? T.toString()] as LdMasterDetailShellRouteConfig<T>?;

  late final LdMasterDetailController<T> _controller = LdMasterDetailController<T>(
    getOpenItem: () => _openItem,
    onOpenItem: _onOpenItem,
    onCloseItem: _onCloseItem,
  );
  bool get isMasterAppBarLoading => widget.isMasterAppBarLoading?.call(_openItem) ?? false;
  bool get isDetailsAppBarLoading => widget.isDetailAppBarLoading?.call(_openItem) ?? false;

  Widget? _getInjectables(BuildContext context, Widget? child) {
    final List<InheritedProvider> injectables = [
      ...widget.injectables?.call(context) ?? [],
      ChangeNotifierProvider<LdMasterDetailController<T>>.value(
        value: _controller,
      ),
    ];
    return MultiProvider(
      providers: injectables,
      child: child,
    );
  }

  @override
  initState() {
    super.initState();
    unawaited(_openInitialItem());
  }

  Future<void> _openInitialItem() async {
    await Future.delayed(Duration.zero);
    if (widget.openItem != null) {
      _onOpenItem(widget.openItem!);
      return;
    }
    _handleInitialRoute();
  }

  /// Try to open an item from the route parameters.
  void _handleInitialRoute() async {
    if (_detailRouteConfig != null && _openItem == null) {
      final router = GoRouter.of(context);
      final itemId = router.state.pathParameters[_detailRouteConfig!.detailPathParam];
      final openItem = itemId != null ? await _detailRouteConfig!.pathToItem(itemId) : null;
      _openItem = openItem;
    }
  }

  @override
  didUpdateWidget(LdMasterDetail<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openItem != widget.openItem) {
      setState(() {
        _openItem = widget.openItem;
      });
    }
  }

  NavigatorState get _navigator => widget.navigator ?? Navigator.of(context);

  void _onCloseItem() async {
    setState(() {
      _openItem = null;
    });

    if (_inDetailView) {
      _navigator.maybePop();
    }

    if (_routeConfig?.basePath != null) {
      // Go back to the base path if the detail view is closed
      GoRouter.of(context).go(_routeConfig!.basePath!);
    }

    widget.onOpenItemChange?.call(null);
  }

  Future<bool> _onOpenItem(T item) async {
    if (_routeConfig?.basePath != null && _detailRouteConfig != null) {
      // get the current route configuration of GoRouter
      final router = GoRouter.of(context);
      final pathParams = router.state.pathParameters;
      pathParams[_detailRouteConfig!.detailPathParam] = _detailRouteConfig!.itemToPath(item);
      final path = _routeConfig!.compositePathWithParams(pathParams);
      router.go(path);
    }

    bool isSameItem = false;
    if (_openItem is CrudItemMixin && item is CrudItemMixin) {
      isSameItem = const DeepCollectionEquality().equals(
        (_openItem as CrudItemMixin).id,
        (item as CrudItemMixin).id,
      );
    }
    setState(() {
      _openItem = item;
    });

    widget.onOpenItemChange?.call(item);

    if (!useSplitView) {
      _inDetailView = true;

      Route? route;
      if (widget.detailPresentationMode == MasterDetailPresentationMode.page) {
        route = MaterialPageRoute(
          builder: (context) {
            return _getInjectables(context, _buildDetailPage(item))!;
          },
        );
      } else if (widget.detailPresentationMode == MasterDetailPresentationMode.dialog) {
        route = LdModal(
          injectables: widget.injectables,
          onDismiss: _onDialogDismiss,
          modalContent: (context) => widget.buildDetail(context, item, true, _controller),
          title: widget.buildDetailTitle?.call(context, item, true, _controller),
          actions: (context) => widget.buildDetailActions?.call(context, item, true, _controller) ?? [],
        ).asRoute(const RouteSettings(), context);
      }

      isSameItem ? _navigator.pushReplacement(route!) : _navigator.push(route!);
      widget.onOpenItemChange?.call(null);
    }

    return Future.value(true);
  }

  bool _inDetailView = false;

  void _onDialogDismiss() {
    _onCloseItem();
  }

  void onPop(bool onPop) {
    setState(() {
      _openItem = null;
    });
    widget.onOpenItemChange?.call(null);
  }

  void _didChangeSize(bool isLarge) async {
    await Future.delayed(Duration.zero);

    bool wasLarge = this.useSplitView;

    setState(() {
      this.useSplitView = isLarge;
    });

    final _previousOpenItem = _openItem;

    if (!wasLarge && isLarge && _inDetailView) {
      _navigator.maybePop();
    }

    await Future.delayed(Duration.zero);

    if (_previousOpenItem != null) {
      _onOpenItem(_previousOpenItem);
    }
  }

  bool useSplitView = false;

  Widget buildMaster(
    BuildContext context,
    LdMasterDetailOnOpenItem<T> onOpenItem,
    T? openItem,
    bool isSeparatePage,
  ) {
    return Scaffold(
      appBar: LdAppBar(
        loading: isMasterAppBarLoading,
        scrolledUnderElevation: isSeparatePage ? 4 : 0,
        context: context,
        title: widget.buildMasterTitle?.call(
          context,
          openItem,
          isSeparatePage,
          _controller,
        ),
        actions: buildMasterActions(
          context,
          openItem,
          isSeparatePage,
        ),
        actionsDisabled: isMasterAppBarLoading,
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.buildMaster(
        context,
        openItem,
        isSeparatePage,
        _controller,
      ),
    );
  }

  List<Widget> buildMasterActions(
    BuildContext context,
    T? openItem,
    bool isSeparatePage,
  ) {
    return widget.buildMasterActions?.call(
          context,
          openItem,
          isSeparatePage,
          _controller,
        ) ??
        [];
  }

  Widget buildDetail(
    BuildContext context,
    T item,
    bool isSeparatePage,
  ) {
    return Scaffold(
      appBar: LdAppBar(
        context: context,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: isSeparatePage ? 4 : 0,
        title: widget.buildDetailTitle?.call(
          context,
          item,
          isSeparatePage,
          _controller,
        ),
        actions: buildDetailActions(
          context,
          item,
          isSeparatePage,
        ),
        actionsDisabled: isDetailsAppBarLoading,
        loading: isDetailsAppBarLoading,
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.buildDetail(
        context,
        item,
        isSeparatePage,
        _controller,
      ),
    );
  }

  List<Widget> buildDetailActions(
    BuildContext context,
    T item,
    bool isSeparatePage,
  ) {
    return widget.buildDetailActions?.call(
          context,
          item,
          isSeparatePage,
          _controller,
        ) ??
        [];
  }

  Widget buildContent(
    BuildContext context,
    bool isLarge,
  ) {
    final theme = LdTheme.of(context, listen: true);

    if (isLarge) {
      return MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 2,
        ),
        child: MultiSplitView(
          initialAreas: [
            Area(
              flex: 1,
              builder: (context, area) => FocusTraversalGroup(
                child: buildMaster(context, _onOpenItem, _openItem, !isLarge),
              ),
            ),
            Area(
              flex: widget.masterDetailFlex,
              builder: (context, area) {
                final detail = _openItem != null ? buildDetail(context, _openItem!, !isLarge) : null;
                return FocusTraversalGroup(
                  child: detail ?? Container(),
                );
              },
            )
          ],
          dividerBuilder: (
            axis,
            index,
            resizable,
            dragging,
            highlighted,
            themeData,
          ) =>
              Center(
            child: Container(color: theme.border, width: 2),
          ),
        ),
      );
    }

    return buildMaster(context, _onOpenItem, _openItem, false);
  }

  bool _useSplitView(SizingInformation size) {
    if (widget.customSplitPredicate != null) {
      return widget.customSplitPredicate!(size) && widget.layoutMode != MasterDetailLayoutMode.compact;
    }
    return ((size.isTablet && size.screenSize.width > size.screenSize.height) || size.isDesktop) &&
        widget.layoutMode != MasterDetailLayoutMode.compact;
  }

  @override
  Widget build(BuildContext context) {
    return _getInjectables(context, ResponsiveBuilder(
      builder: (context, size) {
        bool useSplit = _useSplitView(size);

        if (this.useSplitView != useSplit) {
          _didChangeSize(useSplit);
        }

        return buildContent(context, useSplit);
      },
    ))!;
  }

  Widget _buildDetailPage(T item) {
    return _DetailPage(
      buildDetailTitle: widget.buildDetailTitle,
      buildDetail: widget.buildDetail,
      buildDetailActions: (context, item, isSeparatePage, controller) =>
          buildDetailActions(context, item, isSeparatePage),
      item: item,
      controller: _controller,
      isDetailsAppBarLoading: isDetailsAppBarLoading,
    );
  }
}

class _DetailPage<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item, bool isSeparatePage, LdMasterDetailController<T> controller)?
      buildDetailTitle;
  final Widget Function(BuildContext context, T item, bool isSeparatePage, LdMasterDetailController<T> controller)
      buildDetail;
  final List<Widget> Function(
      BuildContext context, T item, bool isSeparatePage, LdMasterDetailController<T> controller)? buildDetailActions;
  final T item;
  final LdMasterDetailController<T> controller;
  final bool isDetailsAppBarLoading;
  const _DetailPage({
    this.buildDetailTitle,
    required this.buildDetail,
    required this.buildDetailActions,
    required this.item,
    required this.controller,
    required this.isDetailsAppBarLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        backgroundColor: LdTheme.of(context).background,
        appBar: LdAppBar(
          context: context,
          title: buildDetailTitle?.call(
            context,
            item,
            true,
            controller,
          ),
          actions: buildDetailActions?.call(
                context,
                item,
                true,
                controller,
              ) ??
              [],
          actionsDisabled: isDetailsAppBarLoading,
          loading: isDetailsAppBarLoading,
        ),
        body: buildDetail(context, item, true, controller),
      ),
    );
  }
}
