import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/master_detail_route_state.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

class LdMasterDetailShell<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatefulWidget {
  const LdMasterDetailShell({
    super.key,
    required this.child,
    required this.route,
    this.routeSelection,
  });

  final Widget child;
  final String? routeSelection;
  final LdMasterDetailRoute<T, IdType, GroupingCriterion> route;

  @override
  State<LdMasterDetailShell<T, IdType, GroupingCriterion>> createState() =>
      _LdMasterDetailShellState<T, IdType, GroupingCriterion>();
}

class _LdMasterDetailShellState<T extends Identifiable<IdType>, IdType, GroupingCriterion>
    extends State<LdMasterDetailShell<T, IdType, GroupingCriterion>> {
  late final StreamSubscription<LdMasterDetailRouteState<T, IdType, GroupingCriterion>> _selectionSubscription;

  late final StreamSubscription _filterSubscription;
  late final StreamSubscription _sortSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.route.state.repository != null) {
      _setupSubscriptions();
    }
  }

  void _setupSubscriptions() {
    _filterSubscription = widget.route.state.repository!.filterStream.listen((_) => _updateQueryParameters());
    _sortSubscription = widget.route.state.repository!.sortStream.listen((_) => _updateQueryParameters());
    _selectionSubscription = widget.route.stateStream.listen((state) {
      _updateSelection(state);
    });
  }

  @override
  void didUpdateWidget(LdMasterDetailShell<T, IdType, GroupingCriterion> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.routeSelection != widget.routeSelection) {
      _updateSelectionFromRoute();
    }
  }

  void _updateSelectionFromRoute() async {
    if (!mounted) return;

    var newSelectedIds = widget.route.parseSelected(widget.routeSelection ?? "");

    newSelectedIds = newSelectedIds.difference(widget.route.state.deletedItems);

    widget.route.setSelectedItems(newSelectedIds);
  }

  @override
  void dispose() {
    _selectionSubscription.cancel();
    _filterSubscription.cancel();
    _sortSubscription.cancel();

    widget.route.setSelectedItems({});
    super.dispose();
  }

  bool get showingDetail => GoRouter.of(context).routerDelegate.currentConfiguration.routes.any(
        (match) => match is GoRoute && (match).name == "${widget.route.path}-detail",
      );

  void _updateQueryParameters() {
    final queryParameters = widget.route.state.repository?.queryParameters;

    if (queryParameters == null) {
      return;
    }

    final uri = Uri.parse(widget.route.path);

    final newUri = uri.replace(queryParameters: queryParameters);

    final router = GoRouter.of(context);

    router.replace(newUri.toString());
  }

  Map<String, String> _getQueryParameters() {
    final router = GoRouter.of(context);
    final queryParameters = router.routerDelegate.currentConfiguration.uri.queryParameters;

    return queryParameters;
  }

  void _updateSelection(LdMasterDetailRouteState<T, IdType, GroupingCriterion> state) async {
    if (!mounted) return;

    final selectedItems = state.selectedItems;
    final deletedItems = state.deletedItems;
    final router = GoRouter.of(context);

    final detailPath = widget.route.detailPath(selectedItems);

    final queryParameters = widget.route.state.repository?.queryParameters;

    final uri = Uri.parse(detailPath);

    final newUri = uri.replace(queryParameters: queryParameters);

    if (widget.route.parseSelected(widget.routeSelection ?? "") == selectedItems) {
      return;
    }

    if (deletedItems.isNotEmpty && selectedItems.intersection(deletedItems).isNotEmpty) {
      return;
    }

    // Check if the uri would actually change

    if (selectedItems.isNotEmpty) {
      if (showingDetail) {
        router.replace(
          newUri.toString(),
        );
      } else {
        if (widget.route.state.showSelectionControls) {
          return;
        }

        router.push(
          newUri.toString(),
        );
      }
    } else {
      if (showingDetail) {
        router.pop();
      } else {
        router.replace(widget.route.path);
      }
    }
  }

  Widget _buildInitialized(
    BuildContext context,
    LdMasterDetailRouteState<T, IdType, GroupingCriterion> state,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final effectivePresentationMode = LdMasterContext.fromRoute(
        widget.route,
        context,
      );

      if (effectivePresentationMode.isSplit) {
        return Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(
          value: widget.route,
          child: Provider<LdMasterContext<T, IdType, GroupingCriterion>>.value(
            value: effectivePresentationMode,
            child: widget.child,
          ),
        );
      }

      final theme = LdTheme.of(context);

      return Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(
        value: widget.route,
        child: Provider<LdMasterContext<T, IdType, GroupingCriterion>>.value(
          value: effectivePresentationMode,
          child: ColoredBox(
            color: theme.background,
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: 2,
              ),
              child: MultiSplitView(
                dividerBuilder: (context, index, resizable, dragging, highlighted, themeData) => VerticalDivider(
                  color: theme.border,
                  thickness: 1,
                  width: 1,
                ),
                initialAreas: [
                  Area(
                    flex: 1,
                    builder: (context, area) => LdMasterPage(
                      route: widget.route,
                    ),
                  ),
                  Area(
                    flex: widget.route.detailFlex?.toDouble() ?? 2.0,
                    builder: (context, area) {
                      // We need to wrap the child in a stream builder to ensure
                      // that the child is rebuilt when the state changes as the
                      // Area will not rebuild.
                      return StreamBuilder(
                          stream: widget.route.stateStream,
                          initialData: widget.route.state,
                          builder: (context, snapshot) {
                            final state = snapshot.data!;

                            if (state.selectedItems.isNotEmpty && showingDetail) {
                              return widget.child;
                            }
                            return const Center(
                              child: LdMute(
                                child: LdTextL(
                                  "Select something",
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyR, meta: true): () {
          widget.route.state.repository?.refreshList();
        }
      },
      child: StreamBuilder(
        stream: widget.route.stateStream,
        initialData: widget.route.state,
        builder: (context, snapshot) {
          if (widget.route.state.repository == null) {
            return LdSubmit<void, void>(
              config: LdSubmitConfig(
                  autoTrigger: true,
                  timeout: null,
                  action: (_) async {
                    await widget.route.initRepository(
                      context,
                      widget.route.parseSelected(widget.routeSelection ?? ""),
                      _getQueryParameters(),
                    );
                    _setupSubscriptions();
                    _updateSelectionFromRoute();
                  }),
              builder: const LdSubmitCenteredBuilder<void, void>(),
            );
          }

          return _buildInitialized(context, snapshot.data!);
        },
      ),
    );
  }
}
