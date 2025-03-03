import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

typedef LdMasterDetailOnSelect<T> = Future<bool> Function(T item);
typedef LdMasterDetailOnSelectCallback<T> = void Function(T? item);

extension GoRouterExt on GoRouter {
  /// Shortcut to get the current URI from the [GoRouter].
  Uri get uri => routeInformationProvider.value.uri;
}

abstract class LdMasterDetailBuilder<T> {
  Widget buildDetailTitle(
    BuildContext context,
    T item,
    bool isSeparatePage,
    Function() deselect,
  );

  Widget buildMasterTitle(
    BuildContext context,
    LdMasterDetailOnSelect<T> onSelect,
    T? selectedItem,
    bool isSeparatePage,
  );

  Widget buildDetail(
    BuildContext context,
    T item,
    bool isSeparatePage,
    Function() deselect,
  );

  Widget buildMaster(
    BuildContext context,
    LdMasterDetailOnSelect<T> onSelect,
    T? selectedItem,
    bool isSeparatePage,
  );

  List<Widget> buildMasterActions(
    BuildContext context,
    LdMasterDetailOnSelect<T> onSelect,
    T? selectedItem,
    bool isSeparatePage,
  ) {
    return [];
  }

  List<Widget> buildDetailActions(
    BuildContext context,
    T item,
    bool isSeparatePage,
    Function() deselect,
  ) {
    return [];
  }
}

enum MasterDetailPresentationMode { page, dialog }

enum MasterDetailLayoutMode { auto, split, compact }

/// A master detail view that shows a list of items on the left and a detail view on the right.
/// The detail view is shown as a page or a dialog if the screen is small.
class LdMasterDetail<T> extends StatefulWidget {
  final T? selectedItem;

  final double masterDetailFlex;

  final LdMasterDetailBuilder<T> builder;

  final NavigatorState? navigator;

  final MasterDetailPresentationMode detailPresentationMode;

  final MasterDetailLayoutMode layoutMode;

  final LdMasterDetailOnSelectCallback<T>? onSelectionChange;

  final bool Function(SizingInformation size)? customSplitPredicate;

  final Uri Function({T? item, required Uri uri})? detailsUrlBuilder;

  final T? Function(Uri uri)? detailsUrlParser;

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

    /// A function to build the query parameters for the URL.
    this.detailsUrlBuilder,

    /// A function to parse the URL path into an item.
    this.detailsUrlParser,
    super.key,
  });

  @override
  State<LdMasterDetail<T>> createState() => _LdMasterDetailState<T>();
}

class _LdMasterDetailState<T> extends State<LdMasterDetail<T>>
    with SingleTickerProviderStateMixin {
  T? _selectedItem;

  @override
  initState() {
    super.initState();
    unawaited(_selectInitialItem());
  }

  Future<void> _selectInitialItem() async {
    await Future.delayed(Duration.zero);
    if (widget.selectedItem != null) {
      _onSelect(widget.selectedItem!);
      return;
    }

    if (widget.detailsUrlParser != null) {
      final Uri uri = GoRouter.of(context).uri;
      final T item = widget.detailsUrlParser!(uri) as T;
      if (item != null) {
        _onSelect(item);
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

    if (widget.detailsUrlBuilder != null) {
      Uri uri = GoRouter.of(context).uri;
      GoRouter.of(context).go(widget.detailsUrlBuilder!(uri: uri).toString());
    }

    widget.onSelectionChange?.call(null);
  }

  Future<bool> _onSelect(T item) async {
    setState(() {
      _selectedItem = item;
    });

    widget.onSelectionChange?.call(item);
    if (widget.detailsUrlBuilder != null) {
      Uri uri = GoRouter.of(context).uri;
      GoRouter.of(context)
          .go(widget.detailsUrlBuilder!(item: item, uri: uri).toString());
    }

    if (!useSplitView) {
      _inDetailView = true;

      if (widget.detailPresentationMode == MasterDetailPresentationMode.page) {
        await _navigator.push(
          MaterialPageRoute(
            builder: (context) {
              return _DetailPage(
                builder: widget.builder,
                item: item,
                deselect: _onDeselect,
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
            _onDeselect,
          ),
          title: widget.builder.buildDetailTitle(
            context,
            item,
            true,
            _onDeselect,
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
        scrolledUnderElevation: isSeparatePage ? 4 : 0,
        context: context,
        title: widget.builder.buildMasterTitle(
          context,
          _onSelect,
          _selectedItem,
          true,
        ),
        actions: widget.builder.buildMasterActions(
          context,
          _onSelect,
          _selectedItem,
          true,
        ),
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.builder.buildMaster(
        context,
        onSelect,
        selectedItem,
        isSeparatePage,
      ),
    );
  }

  Widget buildDetail(BuildContext context, T item, bool isSeparatePage) {
    return Scaffold(
      appBar: LdAppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: isSeparatePage ? 4 : 0,
        context: context,
        title: widget.builder.buildDetailTitle(
          context,
          item,
          isSeparatePage,
          _onDeselect,
        ),
        actions: widget.builder.buildDetailActions(
          context,
          item,
          isSeparatePage,
          _onDeselect,
        ),
      ),
      backgroundColor: LdTheme.of(context).background,
      body: widget.builder.buildDetail(
        context,
        item,
        isSeparatePage,
        _onDeselect,
      ),
    );
  }

  Widget buildContent(BuildContext context, bool isLarge) {
    final theme = LdTheme.of(context, listen: true);

    final detail = _selectedItem != null
        ? buildDetail(context, _selectedItem!, !isLarge)
        : null;

    final master = buildMaster(
      context,
      _onSelect,
      _selectedItem,
      !isLarge,
    );

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

    return buildMaster(
      context,
      _onSelect,
      _selectedItem,
      false,
    );
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
  Widget build(BuildContext _) {
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
  final LdMasterDetailBuilder builder;
  final T item;
  final VoidCallback deselect;

  const _DetailPage({
    required this.builder,
    required this.item,
    required this.deselect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        backgroundColor: LdTheme.of(context).background,
        appBar: LdAppBar(
          context: context,
          title: builder.buildDetailTitle(context, item, true, deselect),
          actions: builder.buildDetailActions(context, item, true, deselect),
        ),
        body: builder.buildDetail(context, item, true, deselect),
      ),
    );
  }
}
