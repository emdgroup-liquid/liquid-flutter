import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/conditional_parent.dart';
import 'package:liquid_flutter/src/master_detail/filter_modal.dart';
import 'package:liquid_flutter/src/master_detail/master_detail_route_state.dart';
import 'package:provider/provider.dart';

enum MasterDetailPresentationMode { page, dialog }

enum MasterDetailLayoutMode { auto, split, compact }

class LdMasterDetailRoute<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  LdRepository<T, IdType> get repository => _state.repository!;

  var _state = LdMasterDetailRouteState<T, IdType, GroupingCriterion>(
    showSelectionControls: false,
    selectedItems: {},
    repository: null,
  );

  final _stateStream = StreamController<LdMasterDetailRouteState<T, IdType, GroupingCriterion>>.broadcast();
  Stream<LdMasterDetailRouteState<T, IdType, GroupingCriterion>> get stateStream => _stateStream.stream;

  LdMasterDetailRouteState<T, IdType, GroupingCriterion> get state => _state;

  void _updateState(LdMasterDetailRouteState<T, IdType, GroupingCriterion> state) {
    _state = state;
    _stateStream.add(state);
  }

  final LdRepository<T, IdType> Function(BuildContext context) buildRepository;

  final Widget Function(BuildContext context, Widget child)? wrapShell;

  final String path;
  final IdType Function(String id) parseId;
  final String Function(Set<IdType> ids) detailPath;
  final Set<IdType> Function(String selected)? _parseSelected;
  final double reflowBreakpoint;
  final int? detailFlex;

  final MasterDetailPresentationMode presentationMode;
  final MasterDetailLayoutMode layoutMode;

  final bool allowMultipleSelection;
  final bool showMultiSelectItems;

  /// Builds the detail content.
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;

  /// The actions that are available in the master and detail pages.
  final List<LdMasterDetailAction<T, IdType, GroupingCriterion>> actions;

  /// Builds the selectable list,
  final LdSelectableList<T, IdType, GroupingCriterion> Function(
    LdMasterDetailRoute<T, IdType, GroupingCriterion> route,
    LdMasterDetailRouteState<T, IdType, GroupingCriterion> state,
    void Function(Set<IdType> selectedItems) onSelectionChange,
  ) listBuilder;

  static LdMasterDetailRoute<T, IdType, GroupingCriterion>
      of<T extends Identifiable<IdType>, IdType, GroupingCriterion>(BuildContext context, {bool watch = false}) {
    return watch
        ? context.watch<LdMasterDetailRoute<T, IdType, GroupingCriterion>>()
        : context.read<LdMasterDetailRoute<T, IdType, GroupingCriterion>>();
  }

  LdMasterDetailRoute({
    required this.path,
    required this.detailPath,
    required this.buildDetail,
    required this.buildRepository,
    required this.parseId,
    this.reflowBreakpoint = 600,
    required this.listBuilder,
    this.detailFlex = 2,
    this.actions = const [],
    this.allowMultipleSelection = true,
    this.showMultiSelectItems = false,
    this.wrapShell,
    this.presentationMode = MasterDetailPresentationMode.page,
    this.layoutMode = MasterDetailLayoutMode.auto,
    Set<IdType> Function(String selected)? parseSelected,
  }) : _parseSelected = parseSelected;

  List<RouteBase> buildRoute() {
    return [
      GoRoute(
        name: "$path-filters",
        path: "$path/filters",
        pageBuilder: (context, state) => LdModalPage(
          key: state.pageKey,
          builder: ldFilterModal(context, this),
        ),
      ),
      ShellRoute(
        routes: [
          GoRoute(
              name: "$path-master",
              path: path,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                    key: state.pageKey,
                    child: LdMasterPage(
                      route: this,
                    ),
                  ),
              routes: [
                GoRoute(
                    name: "$path-detail",
                    path: "/:selected",
                    pageBuilder: (context, state) {
                      final effectivePresentationMode = LdMasterContext.of<T, IdType, GroupingCriterion>(context);
                      final page = Provider.value(
                        value: effectivePresentationMode,
                        child: Provider.value(
                          value: this,
                          child: LdDetailPage<T, IdType, GroupingCriterion>(),
                        ),
                      );

                      if (effectivePresentationMode.isSplit) {
                        if (effectivePresentationMode.detailInDialog) {
                          return LdModalPage(
                            key: state.pageKey,
                            builder: ldDetailModal(this),
                          );
                        }
                        return MaterialPage(
                          child: page,
                          key: state.pageKey,
                        );
                      }
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: page,
                      );
                    }),
              ]),
        ],
        builder: (context, state, child) => LdWrapConditional(
          condition: wrapShell != null,
          builder: (context, child) => wrapShell!.call(context, child),
          child: LdMasterDetailShell(
            child: child,
            route: this,
            routeSelection: state.pathParameters['selected'],
          ),
        ),
      )
    ];
  }

  Future<void> initRepository(
      BuildContext context, Set<IdType> initialSelection, Map<String, String> queryParameters) async {
    _updateState(
      _state.copyWith(repository: buildRepository(context)),
    );

    if (initialSelection.isNotEmpty) {
      await repository.initWithSelection(initialSelection);
    } else {
      await repository.fetchItemsAtOffset(0);
    }

    if (queryParameters.isNotEmpty) {
      print("queryParameters: $queryParameters");
      repository.filters.forEach((filter) async {
        final value = queryParameters[filter.name];
        print("filter: ${filter.name} value: $value");
        if (value != null) {
          print("marshalling filter: ${filter.name} value: $value");
          filter.marshalSerialized(value);
          repository.updateFilter(filter);
        }
      });
    }

    repository.updatedItems.listen((item) async {
      if (item.state == LdPaginatorItemState.deleted && item.value != null) {
        _updateState(
          _state.copyWith(
            deletedItems: {
              ..._state.deletedItems,
              item.value!.id,
            },
            selectedItems: _state.selectedItems.where((id) => id != item.value!.id).toSet(),
          ),
        );
      }
    });
  }

  void setShowSelectionControls(bool showSelectionControls) {
    _updateState(
      _state.copyWith(
        showSelectionControls: showSelectionControls,
        selectedItems: showSelectionControls ? _state.selectedItems : {},
      ),
    );
  }

  Set<IdType> parseSelected(String selected) {
    if (_parseSelected != null) {
      return _parseSelected!(selected);
    }
    if (selected.isEmpty) {
      return {};
    }
    return selected.split(",").map(parseId).toSet();
  }

  void setSelectedItems(Set<IdType> selectedItems) {
    if (selectedItems.join(",") == _state.selectedItems.join(",")) {
      return;
    }

    _updateState(
      _state.copyWith(selectedItems: selectedItems),
    );
  }

  bool isSplit(Size size) {
    return (size.width < reflowBreakpoint && layoutMode == MasterDetailLayoutMode.auto) ||
        layoutMode == MasterDetailLayoutMode.compact;
  }
}
