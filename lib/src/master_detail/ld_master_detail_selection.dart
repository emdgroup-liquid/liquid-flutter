import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/master_detail_route.dart';
import 'package:provider/provider.dart';

class LdMasterDetailSelection<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final Set<IdType> items;

  LdMasterDetailSelection({required this.items});

  factory LdMasterDetailSelection.fromRoute(BuildContext context) {
    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);
    return LdMasterDetailSelection(items: route.state.selectedItems);
  }

  static LdMasterDetailSelection<T, IdType, GroupingCriterion>
      of<T extends Identifiable<IdType>, IdType, GroupingCriterion>(BuildContext context, {bool listen = true}) {
    return listen
        ? context.watch<LdMasterDetailSelection<T, IdType, GroupingCriterion>>()
        : context.read<LdMasterDetailSelection<T, IdType, GroupingCriterion>>();
  }
}
