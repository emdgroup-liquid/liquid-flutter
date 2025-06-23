import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdMasterDetailAppBarActions<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final LdMasterDetailActionLocation location;

  const LdMasterDetailAppBarActions({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();

    return LayoutBuilder(builder: (context, constraints) {
      return LdAppBarActions(actions: actions);
    });
  }
}
