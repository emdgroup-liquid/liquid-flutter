import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/device_info.dart';
import 'package:liquid_flutter/src/master_detail/app_bar_actions.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:provider/provider.dart';

class LdMasterPage<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final LdMasterDetailRoute<T, IdType, GroupingCriterion> route;

  const LdMasterPage({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isSeperate = LdMasterContext.of<T, IdType, GroupingCriterion>(context).isSplit;

    final bigScreen = DeviceInfo.isDesktop || DeviceInfo.isTablet;

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: StreamBuilder(
            stream: route.stateStream,
            initialData: route.state,
            builder: (context, asyncSnapshot) {
              final state = asyncSnapshot.data!;
              // Provide  the state of the route to the list builder

              return Provider.value(
                value: LdMasterDetailSelection<T, IdType, GroupingCriterion>(items: state.selectedItems),
                child: LdMasterDetailMultiShortcuts(
                  actions: route.actions,
                  child: Builder(builder: (context) {
                    final primaryActions =
                        LdMasterDetailAppBarActions.getActionsAndProviders<T, IdType, GroupingCriterion>(
                      context,
                      LdMasterDetailActionLocation.masterAppBar,
                    );

                    final secondaryActions =
                        LdMasterDetailAppBarActions.getActionsAndProviders<T, IdType, GroupingCriterion>(
                      context,
                      LdMasterDetailActionLocation.masterSecondary,
                    );

                    final searchFilter =
                        route.repository.filters.firstWhereOrNull((filter) => filter is LdFilterSearchOption);

                    return LdScaffold(
                      appBar: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Provider.value(
                            value: LdMasterDetailActionLocation.masterAppBar,
                            child: LdAppBar(
                              title: Text(route.repository.pluralItemTitle),
                              actions: primaryActions.actions,
                              overflowMenuProviders: primaryActions.menuProviders,
                              bottom: searchFilter != null && bigScreen
                                  ? LdFilterSearchWidget(
                                      filter: searchFilter as LdFilterSearchOption<T, IdType, dynamic>,
                                      onFilterChanged: (filter) {
                                        route.repository.updateFilter(filter);
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          if (bigScreen && (secondaryActions.hasActions))
                            Provider.value(
                                value: LdMasterDetailActionLocation.masterSecondary,
                                child: LdAppBar(
                                  disableSafeArea: true,
                                  actions: secondaryActions.actions,
                                  overflowMenuProviders: secondaryActions.menuProviders,
                                )),
                        ],
                      ),
                      bottomNavigationBar: !bigScreen && (secondaryActions.hasActions || searchFilter != null)
                          ? Provider.value(
                              value: LdMasterDetailActionLocation.masterSecondary,
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
                                              route.repository.updateFilter(filter);
                                            },
                                          ),
                                        )
                                      : null,
                                );
                              }),
                            )
                          : null,
                      body: route.listBuilder(
                        route,
                        state,
                        (selection) {
                          route.setSelectedItems(selection);
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
