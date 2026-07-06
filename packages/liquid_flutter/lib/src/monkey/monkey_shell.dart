import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';

import 'package:provider/provider.dart';

const monkeyShortcuts = {
  SingleActivator(LogicalKeyboardKey.keyF, meta: true): SearchIntent(),
  SingleActivator(LogicalKeyboardKey.keyR, meta: true): RefreshIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
};

typedef LdMonkeyActions<T extends Identifiable<IdType>, IdType> = List<LdMonkeyAction<T, IdType>>;

/// The shell route that is wrapped around the master and detail pages.
/// This widget expects to find an [LdListController<T, IdType>] in the context.
class LdMonkeyShell<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyShell({
    super.key,
    required this.child,
    required this.masterPage,
    this.actions = const [],
    this.allowMultipleSelection = true,
    this.detailPanelFraction = 0.3,
    this.immediateViewSelection,
    this.layoutMode = LdMonkeyLayoutMode.auto,
    this.reflowBreakpoint = 600,
  });

  /// Child route provided by navigator
  final Widget child;

  /// Whether multiple selection is allowed.
  final bool allowMultipleSelection;

  /// Controls the layout behavior of the master-detail interface.
  final LdMonkeyLayoutMode layoutMode;

  /// The actions that are available in the master and detail pages.
  ///
  final List<LdMonkeyAction<T, IdType>> actions;

  /// Breakpoint width in pixels for responsive layout switching.
  ///
  /// When the screen width is above this value and [layoutMode] is [LdMonkeyLayoutMode.auto],
  /// the component will display in side-by-side mode. Defaults to 600 pixels.
  final double reflowBreakpoint;

  /// How much of the screen width the detail panel should occupy in side-by-side layout.
  final double detailPanelFraction;

  /// The master page to display in the master panel. This parameter is not used
  /// if the the effective layout is not side by side.
  final Widget masterPage;

  /// When true, selection immediately updates viewing and URL (old behavior).
  /// When false, selection and viewing are decoupled when selection controls
  /// are enabled or multiple items are selected.
  final bool? immediateViewSelection;

  @override
  State<LdMonkeyShell<T, IdType>> createState() => _LdMonkeyShellState<T, IdType>();
}

class LdMonkeySearchFocusNode {
  final FocusNode focusNode;

  LdMonkeySearchFocusNode({required this.focusNode});
}

class _LdMonkeyShellState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyShell<T, IdType>> {
  final LdMonkeySearchFocusNode _searchFocusNode = LdMonkeySearchFocusNode(focusNode: FocusNode());
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode.focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Register for changes to the sort and filter state, as we will
    // need to update the repository with the new filters and sort options
    context.watch<LdMonkeySortAndFilterState<T, IdType>>();

    return Provider<LdMonkeySearchFocusNode>.value(
      value: _searchFocusNode,
      child: _MonkeyShellLayoutBuilder<T, IdType>(
        layoutMode: widget.layoutMode,
        reflowBreakpoint: widget.reflowBreakpoint,
        detailPanelFraction: widget.detailPanelFraction,
        masterPage: widget.masterPage,
        child: widget.child,
      ),
    );
  }
}

class _MonkeyShellLayoutBuilder<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdMonkeyLayoutMode layoutMode;
  final double reflowBreakpoint;
  final double detailPanelFraction;
  final Widget masterPage;
  final Widget child;

  const _MonkeyShellLayoutBuilder({
    required this.layoutMode,
    required this.reflowBreakpoint,
    required this.detailPanelFraction,
    required this.masterPage,
    required this.child,
  });

  LdMonkeyEffectiveLayoutMode _getEffectiveLayoutMode(bool showingDetail, BoxConstraints constraints) {
    final wouldBeSideBySide = constraints.maxWidth > reflowBreakpoint;

    return switch (layoutMode) {
      LdMonkeyLayoutMode.sideBySide => LdMonkeyEffectiveLayoutMode.sideBySide,
      LdMonkeyLayoutMode.auto => switch (wouldBeSideBySide) {
          true => LdMonkeyEffectiveLayoutMode.sideBySide,
          false => switch (showingDetail) {
              true => LdMonkeyEffectiveLayoutMode.detail,
              false => LdMonkeyEffectiveLayoutMode.master,
            },
        },
      LdMonkeyLayoutMode.neverSideBySide => switch (showingDetail) {
          true => LdMonkeyEffectiveLayoutMode.detail,
          false => LdMonkeyEffectiveLayoutMode.master,
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selection = context.watch<LdMonkeySelection<T, IdType>>();
        final showingDetail = selection.viewing.isNotEmpty;

        final effectiveLayout = _getEffectiveLayoutMode(showingDetail, constraints);

        final routeConfig = context.watch<LdMonkeyRouteConfig<T, IdType>>();

        final location = GoRouter.of(context).routerDelegate.state.name;

        final showingNew = routeConfig.createRouteName == location;

        final wrappedChild = Provider.value(
          value: LdListItemConfig(
            trailing: switch (effectiveLayout) {
              LdMonkeyEffectiveLayoutMode.master ||
              LdMonkeyEffectiveLayoutMode.detail =>
                LdListDefaultTrailingForward(),
              _ => null,
            },
          ),
          child: child,
        );

        return CallbackShortcuts(
          bindings: {
            SingleActivator(LogicalKeyboardKey.keyR, meta: true): () {
              context.read<LdListController<T, IdType>>().refreshList(context: context, reason: LdFetchReason.initial);
            },
            SingleActivator(LogicalKeyboardKey.escape): () {
              if (selection.showSelectionControls) {
                LdMonkeySelection.maybeClearSelection<T, IdType>(context);
                return;
              }
              if (showingDetail && effectiveLayout == LdMonkeyEffectiveLayoutMode.sideBySide) {
                LdMonkeySelection.updateViewing<T, IdType>(context, {});
              }
            },
            SingleActivator(LogicalKeyboardKey.keyF, meta: true): () {
              context.read<LdMonkeySearchFocusNode?>()?.focusNode.requestFocus();
            },
          },
          child: switch (effectiveLayout) {
            LdMonkeyEffectiveLayoutMode.sideBySide => Provider.value(
                value: effectiveLayout,
                child: Provider.value(
                  value: LdMonkeyEffectiveLayoutMode.sideBySide,
                  child: Provider.value(
                    value: LdDrawerState(
                      isOpen: showingDetail || showingNew,
                      isSideBySide: true,
                    ),
                    child: LdMultiPanelLayout(
                      mode: LdMultiPanelLayoutMode.sideBySide,
                      panelVisible: showingDetail || showingNew,
                      minPanelWidth: 350,
                      minBodyWidth: reflowBreakpoint - 351,
                      allowResize: true,
                      panelPosition: LdPanelPosition.right,
                      initialPanelFraction: detailPanelFraction,
                      body: Provider.value(
                        value: LdDrawerSlot.drawer,
                        child: masterPage,
                      ),
                      panel: Provider.value(
                        value: LdDrawerSlot.body,
                        child: PreventAutoFocus(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: LdTheme.of(context).border,
                                  width: LdTheme.of(context).borderWidth,
                                ),
                              ),
                            ),
                            child: switch (showingDetail || showingNew) {
                              true => wrappedChild,
                              false => SizedBox.shrink(),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            _ => Provider.value(
                value: switch (showingDetail) {
                  true => LdMonkeyEffectiveLayoutMode.detail,
                  false => LdMonkeyEffectiveLayoutMode.master,
                },
                child: wrappedChild,
              ),
          },
        );
      },
    );
  }
}

extension FilterEquals<T extends Identifiable<IdType>, IdType> on Set<LdFilterOption<T, IdType>> {
  bool equals(Set<LdFilterOption<T, IdType>> other) => SetEquality<LdFilterOption<T, IdType>>().equals(this, other);
}

extension SortEqals<T extends Identifiable<IdType>, IdType> on List<LdSortOption<T, IdType>> {
  bool equals(List<LdSortOption<T, IdType>> other) => ListEquality<LdSortOption<T, IdType>>().equals(this, other);
}

class PreventAutoFocus extends StatefulWidget {
  final Widget child;

  const PreventAutoFocus({super.key, required this.child});

  @override
  State<PreventAutoFocus> createState() => _PreventAutoFocusState();
}

class _PreventAutoFocusState extends State<PreventAutoFocus> {
  bool _excluding = false;

  @override
  void didUpdateWidget(covariant PreventAutoFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _excluding = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_excluding) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        setState(() {
          _excluding = false;
        });
      });
    }
    return ExcludeFocus(
      excluding: _excluding,
      child: widget.child,
    );
  }
}
