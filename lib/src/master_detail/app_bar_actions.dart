import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:provider/provider.dart';

class LdMasterDetailAppBarActions<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final LdMasterDetailActionLocation location;

  const LdMasterDetailAppBarActions({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    return StreamBuilder(
      stream: route.repository.updatedItems,
      builder: (context, _) {
        final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();

        final hasActions = actions.any((e) => e.isVisible(context, location: location));

        final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

        return LayoutBuilder(builder: (context, constraints) {
          return LdReveal.quick(
            revealed: hasActions,
            child: Provider.value(
              value: location,
              child: LdAppBarActions(
                actions: actions,
                menuProviders: (context) => [
                  Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(value: route),
                  Provider<LdMasterDetailSelection<T, IdType, GroupingCriterion>>.value(value: selection),
                  Provider<LdMasterContext<T, IdType, GroupingCriterion>>.value(value: LdMasterContext.of(context)),
                  Provider<LdMasterDetailActionLocation>.value(value: location),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class LdMasterDetailBottomBarActions<T extends Identifiable<IdType>, IdType, GroupingCriterion>
    extends StatelessWidget {
  final LdMasterDetailActionLocation location;

  const LdMasterDetailBottomBarActions({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();

    final hasActions = actions.any((e) => e.isVisible(context, location: location));

    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

    return LdReveal.quick(
      revealed: hasActions,
      child: Provider.value(
        value: location,
        child: LdBottomBar(
          child: LdAppBarActions(
            menuProviders: (context) => [
              Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(value: route),
              Provider<LdMasterDetailSelection<T, IdType, GroupingCriterion>>.value(value: selection),
              Provider<LdMasterContext<T, IdType, GroupingCriterion>>.value(
                value: LdMasterContext.fromRoute(route, context),
              ),
              Provider<LdMasterDetailActionLocation>.value(value: location),
            ],
            actions: actions,
          ),
        ),
      ),
    );
  }
}
