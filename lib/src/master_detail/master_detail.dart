import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

part 'crud_master_detail.dart';
part 'master_detail_builder.dart';

typedef LdMasterDetailOnSelect<T> = Future<bool> Function(T item);
typedef LdMasterDetailOnSelectCallback<T> = void Function(T? item);

extension GoRouterExt on GoRouter {
  /// Shortcut to get the current URI from the [GoRouter].
  Uri get uri => routeInformationProvider.value.uri;
}

class LdMasterDetailController<T> {
  final Future<bool> Function(T item) onSelect;
  final Function onDeselect;

  bool get isMasterAppBarLoading => false;
  bool isDetailsAppBarLoading(T item) => false;

  LdMasterDetailController({
    required this.onSelect,
    required this.onDeselect,
  });

  void dispose() {}
}

enum MasterDetailPresentationMode { page, dialog }

enum MasterDetailLayoutMode { auto, split, compact }

/// Configuration for a master detail shell route.
class LdMasterDetailShellRouteConfig<T> {
  final String basePath;
  final String detailPath;
  final String Function(T item) itemIdGetter;
  final T? Function(String id) itemProvider;

  String get detailPathParam => detailPath
      .split('/')
      .lastWhere((segment) => segment.startsWith(':'))
      .substring(1);

  LdMasterDetailShellRouteConfig({
    /// The base path for the master detail view.
    required this.basePath,

    /// The path, if the detail view is shown (either as a page, dialog, or in
    /// a separate view).
    required this.detailPath,

    /// A function to get the item ID from an item.
    required this.itemIdGetter,

    /// A function to retrieve an item from an ID.
    required this.itemProvider,
  });
}

/// A master detail view that shows a list of items on the left and a detail view on the right.
/// The detail view is shown as a page or a dialog if the screen is small.
class LdMasterDetail<T> extends StatefulWidget {
  final T? selectedItem;

  final double masterDetailFlex;

  final _LdMasterDetailBuilder<T, LdMasterDetailController<T>> builder;

  final NavigatorState? navigator;

  final MasterDetailPresentationMode detailPresentationMode;

  final MasterDetailLayoutMode layoutMode;

  final LdMasterDetailOnSelectCallback<T>? onSelectionChange;

  final bool Function(SizingInformation size)? customSplitPredicate;

  const LdMasterDetail({
    required this.builder,
    this.detailPresentationMode = MasterDetailPresentationMode.page,
    this.layoutMode = MasterDetailLayoutMode.auto,

    /// The initial item to show in the detail widget.
    this.selectedItem,
    this.navigator,

    /// Called when an item is selected or deselected.
    this.onSelectionChange,

    /// The flex value for the detail widget. Defaults to 3.
    this.masterDetailFlex = 3,

    /// A custom predicate to determine if the split view should be used.
    this.customSplitPredicate,
    super.key,
  });

  /// Helper function to create a router configuration that uses this component
  /// as a shell route.
  static ShellRoute createShellRoute<T>({
    required Widget child,
    required LdMasterDetailShellRouteConfig<T> routeConfig,
    Page Function(BuildContext context, GoRouterState state, Widget child)?
        pageBuilder,
  }) {
    pageBuilder ??= (context, state, child) => NoTransitionPage<void>(
          key: state.pageKey,
          child: child,
        );
    return ShellRoute(
      // _ is the placeholder from the dummy widgets of the routes
      pageBuilder: (context, state, _) => pageBuilder!(
        context,
        state,
        // We wrap the child in a provider to make the route configuration
        // available to LdMasterDetail
        Provider<LdMasterDetailShellRouteConfig<T>?>.value(
          value: routeConfig,
          child: child,
        ),
      ),

      // We just define the routes with a dummy builder, as the actual
      // building is done in the childBuilder
      routes: [
        // Dummy base route
        GoRoute(
          path: routeConfig.basePath,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        // Dummy detail route
        GoRoute(
          path: "/${routeConfig.basePath}/${routeConfig.detailPath}",
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  State<LdMasterDetail<T>> createState() => _LdMasterDetailState<T>();
}

class _LdMasterDetailState<T> extends State<LdMasterDetail<T>>
    with SingleTickerProviderStateMixin {
  T? _selectedItem;

  LdMasterDetailShellRouteConfig<T>? get _routeConfig =>
      Provider.of<LdMasterDetailShellRouteConfig<T>?>(context, listen: false);
  late final LdMasterDetailController<T> _controller;

  @override
  initState() {
    _initController();
    super.initState();
    unawaited(_selectInitialItem());
  }

  void _initController() {
    _controller = LdMasterDetailController(
      onSelect: _onSelect,
      onDeselect: _onDeselect,
    );
  }

  Future<void> _selectInitialItem() async {
    await Future.delayed(Duration.zero);
    if (widget.selectedItem != null) {
      _onSelect(widget.selectedItem!);
      return;
    }

    _handleInitialRoute();
  }

  /// Try to select an item from the route parameters.
  void _handleInitialRoute() {
    final routeConfig = _routeConfig;
    if (routeConfig != null && _selectedItem == null) {
      final router = GoRouter.of(context);
      final itemId = router.state.pathParameters[routeConfig.detailPathParam];
      final selectedItem =
          itemId != null ? routeConfig.itemProvider(itemId) : null;
      if (selectedItem != null) {
        _onSelect(selectedItem);
      }
    }
  }

  @override
  didUpdateWidget(LdMasterDetail<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      setState(() {
        _selectedItem = widget.selectedItem;
      });
    }
  }

  NavigatorState get _navigator => widget.navigator ?? Navigator.of(context);

  void _onDeselect() async {
    setState(() {
      _selectedItem = null;
    });

    if (_inDetailView) {
      _navigator.maybePop();
    }

    final routeConfig = _routeConfig;
    if (routeConfig != null) {
      // Go back to the base path if the detail view is closed
      GoRouter.of(context).go(routeConfig.basePath);
    }

    widget.onSelectionChange?.call(null);
  }

  Future<bool> _onSelect(T item) async {
    final routeConfig = _routeConfig;
    if (routeConfig != null) {
      final itemId = routeConfig.itemIdGetter(item);
      GoRouter.of(context).go(
        "${routeConfig.basePath}/${routeConfig.detailPath}".replaceFirst(
          ":${routeConfig.detailPathParam}",
          itemId,
        ),
      );
    }

    setState(() {
      _selectedItem = item;
    });

    widget.onSelectionChange?.call(item);

    if (!useSplitView) {
      _inDetailView = true;

      if (widget.detailPresentationMode == MasterDetailPresentationMode.page) {
        await _navigator.push(
          MaterialPageRoute(
            builder: (context) {
              return _DetailPage(
                builder: widget.builder,
                item: item,
                controller: _controller,
              );
            },
          ),
        );
        setState(() {
          _inDetailView = false;
          _selectedItem = null;
        });
        widget.onSelectionChange?.call(null);
      }

      if (widget.detailPresentationMode ==
          MasterDetailPresentationMode.dialog) {
        _inDetailView = true;
        await LdModal(
          onDismiss: _onDialogDismiss,
          modalContent: (context) => widget.builder.buildDetail(
            context,
            item,
            true,
            _controller,
          ),
          title: widget.builder.buildDetailTitle(
            context,
            item,
            true,
            _controller,
          ),
        ).show(context);
        setState(() {
          _inDetailView = false;
          _selectedItem = null;
        });
        widget.onSelectionChange?.call(null);
      }
    }

    return Future.value(true);
  }

  bool _inDetailView = false;

  void _onDialogDismiss() {
    _onDeselect();
  }

  void onPop(bool onPop) {
    setState(() {
      _selectedItem = null;
    });
    widget.onSelectionChange?.call(null);
  }

  void _didChangeSize(bool isLarge) async {
    await Future.delayed(Duration.zero);

    bool wasLarge = this.useSplitView;

    setState(() {
      this.useSplitView = isLarge;
    });

    final _previousSelectedItem = _selectedItem;

    if (!wasLarge && isLarge && _inDetailView) {
      _navigator.maybePop();
    }

    await Future.delayed(Duration.zero);

    if (_previousSelectedItem != null) {
      _onSelect(_previousSelectedItem);
    }
  }

  bool useSplitView = false;

  Widget buildMaster(
    BuildContext context,
    LdMasterDetailOnSelect<T> onSelect,
    T? selectedItem,
    bool isSeparatePage,
  ) {
    return Scaffold(
      appBar: LdAppBar(
        loading: _controller.isMasterAppBarLoading,
        scrolledUnderElevation: isSeparatePage ? 4 : 0,
        context: context,
        title: widget.builder.buildMasterTitle(
          context,
          _selectedItem,
          true,
          _controller,
        ),
        actions: widget.builder.buildMasterActions(
          context,
          _selectedItem,
          true,
          _controller,
        ),
        actionsDisabled: _controller.isMasterAppBarLoading,
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.builder.buildMaster(
        context,
        selectedItem,
        isSeparatePage,
        _controller,
      ),
    );
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
        title: widget.builder
            .buildDetailTitle(context, item, isSeparatePage, _controller),
        actions: widget.builder
            .buildDetailActions(context, item, isSeparatePage, _controller),
        actionsDisabled: _controller.isDetailsAppBarLoading(item),
        loading: _controller.isDetailsAppBarLoading(item),
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.builder.buildDetail(
        context,
        item,
        isSeparatePage,
        _controller,
      ),
    );
  }

  Widget buildContent(
    BuildContext context,
    bool isLarge,
  ) {
    final theme = LdTheme.of(context, listen: true);

    final detail = _selectedItem != null
        ? buildDetail(context, _selectedItem!, !isLarge)
        : null;

    final master = buildMaster(context, _onSelect, _selectedItem, !isLarge);

    if (isLarge) {
      return MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 2,
        ),
        child: MultiSplitView(
            initialAreas: [
              Area(weight: 1),
              Area(weight: widget.masterDetailFlex)
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
            children: [
              FocusTraversalGroup(child: master),
              FocusTraversalGroup(child: detail ?? Container()),
            ]),
      );
    }

    return buildMaster(context, _onSelect, _selectedItem, false);
  }

  bool _useSplitView(SizingInformation size) {
    if (widget.customSplitPredicate != null) {
      return widget.customSplitPredicate!(size) &&
          widget.layoutMode != MasterDetailLayoutMode.compact;
    }
    return ((size.isTablet && size.screenSize.width > size.screenSize.height) ||
            size.isDesktop) &&
        widget.layoutMode != MasterDetailLayoutMode.compact;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, size) {
        bool useSplit = _useSplitView(size);

        if (this.useSplitView != useSplit) {
          _didChangeSize(useSplit);
        }

        return buildContent(context, useSplit);
      },
    );
  }
}

class _DetailPage<T> extends StatelessWidget {
  final _LdMasterDetailBuilder<T, LdMasterDetailController<T>> builder;
  final T item;
  final LdMasterDetailController<T> controller;

  const _DetailPage({
    required this.builder,
    required this.item,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        backgroundColor: LdTheme.of(context).background,
        appBar: LdAppBar(
          context: context,
          title: builder.buildDetailTitle(context, item, true, controller),
          actions: builder.buildDetailActions(context, item, true, controller),
          actionsDisabled: controller.isDetailsAppBarLoading(item),
          loading: controller.isDetailsAppBarLoading(item),
        ),
        body: builder.buildDetail(context, item, true, controller),
      ),
    );
  }
}
