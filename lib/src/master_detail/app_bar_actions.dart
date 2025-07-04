import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
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

        return LayoutBuilder(builder: (context, constraints) {
          return LdReveal.quick(
            revealed: hasActions,
            child: Provider.value(
              value: location,
              child: LdAppBarActions(actions: actions),
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

    return LdReveal.quick(
      revealed: hasActions,
      child: Provider.value(
        value: location,
        child: LdBottomBar(
          child: LdAppBarActions(
            actions: actions,
          ),
        ),
      ),
    );
  }
}
