import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
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
                  child: LdScaffold(
                    appBar: LdAppBar(
                      title: Text(route.repository.pluralItemTitle),
                      trailing: LdMasterDetailAppBarActions<T, IdType, GroupingCriterion>(
                        location: LdMasterDetailActionLocation.masterAppBar,
                      ),
                      bottom: !isSeperate
                          ? LdMasterDetailAppBarActions<T, IdType, GroupingCriterion>(
                              location: LdMasterDetailActionLocation.masterSecondary,
                            )
                          : null,
                    ),
                    bottomNavigationBar: isSeperate
                        ? LdMasterDetailBottomBarActions<T, IdType, GroupingCriterion>(
                            location: LdMasterDetailActionLocation.masterSecondary,
                          )
                        : null,
                    body: SafeArea(
                      right: false,
                      child: route.listBuilder(
                        route,
                        state,
                        (selection) {
                          route.setSelectedItems(selection);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
