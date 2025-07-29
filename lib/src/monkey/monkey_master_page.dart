import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/device_info.dart';

import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatefulWidget {
  final LdMonkey<T, IdType, GroupingCriterion> route;
  final FocusNode? searchFocusNode;

  const LdMonkeyMasterPage({
    super.key,
    this.searchFocusNode,
    required this.route,
  });

  @override
  State<LdMonkeyMasterPage<T, IdType, GroupingCriterion>> createState() =>
      _LdMonkeyMasterPageState<T, IdType, GroupingCriterion>();
}

class _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType, GroupingCriterion>
    extends State<LdMonkeyMasterPage<T, IdType, GroupingCriterion>> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bigScreen = DeviceInfo.isDesktop || DeviceInfo.isTablet;

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: StreamBuilder(
            stream: widget.route.stateStream,
            initialData: widget.route.state,
            builder: (context, asyncSnapshot) {
              final state = asyncSnapshot.data!;
              // Provide  the state of the route to the list builder

              return Provider.value(
                value: LdMonkeySelection<T, IdType, GroupingCriterion>(items: state.selectedItems),
                child: LdMonkeyMultiShortcuts(
                  actions: widget.route.actions,
                  child: Builder(builder: (context) {
                    final primaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType, GroupingCriterion>(
                      context,
                      LdMonkeyActionLocation.masterAppBar,
                    );

                    final secondaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType, GroupingCriterion>(
                      context,
                      LdMonkeyActionLocation.masterSecondary,
                    );

                    final searchFilter =
                        widget.route.repository.filters.firstWhereOrNull((filter) => filter is LdFilterSearchOption);

                    return LdScaffold(
                      appBar: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Provider.value(
                            value: LdMonkeyActionLocation.masterAppBar,
                            child: LdAppBar(
                              title: Text(widget.route.repository.pluralItemTitle),
                              actions: primaryActions.actions,
                              overflowMenuProviders: primaryActions.menuProviders,
                              bottom: searchFilter != null && bigScreen
                                  ? LdFilterSearchWidget(
                                      searchFocusNode: widget.searchFocusNode,
                                      filter: searchFilter as LdFilterSearchOption<T, IdType, dynamic>,
                                      onFilterChanged: (filter) {
                                        widget.route.repository.updateFilter(filter);
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          if (bigScreen && (secondaryActions.hasActions))
                            Provider.value(
                                value: LdMonkeyActionLocation.masterSecondary,
                                child: LdAppBar(
                                  disableSafeArea: true,
                                  actions: secondaryActions.actions,
                                  overflowMenuProviders: secondaryActions.menuProviders,
                                )),
                        ],
                      ),
                      bottomNavigationBar: !bigScreen && (secondaryActions.hasActions || searchFilter != null)
                          ? Provider.value(
                              value: LdMonkeyActionLocation.masterSecondary,
                              child: LayoutBuilder(builder: (context, constraints) {
                                return LdAppBar(
                                  implyLeading: false,
                                  actions: secondaryActions.actions,
                                  overflowMenuProviders: secondaryActions.menuProviders,
                                  title: searchFilter != null
                                      ? ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: constraints.maxWidth * (secondaryActions.hasActions ? 0.6 : 0.9),
                                          ),
                                          child: LdFilterSearchWidget(
                                            filter: searchFilter as LdFilterSearchOption<T, IdType, dynamic>,
                                            onFilterChanged: (filter) {
                                              widget.route.repository.updateFilter(filter);
                                            },
                                          ),
                                        )
                                      : null,
                                );
                              }),
                            )
                          : null,
                      body: widget.route.listBuilder(
                        widget.route,
                        state,
                        (selection) {
                          widget.route.setSelectedItems(selection);
                        },
                      ),
                    );
                  }),
                ),
              );
            }),
      ),
    );
  }
}
