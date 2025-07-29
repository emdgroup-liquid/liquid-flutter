import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

LdModal ldMonkeyDetailModal<T extends Identifiable<IdType>, IdType, GroupingCriterion>(
  LdMonkey<T, IdType, GroupingCriterion> route,
) {
  return LdModal(
    modalContent: (context) => SizedBox(
      height: 300,
      child: LdMonkeyDetailPageContent(route: route, selection: route.state.selectedItems),
    ),
    title: StreamBuilder(
      stream: route.stateStream,
      initialData: route.state,
      builder: (context, asyncSnapshot) {
        final selection = asyncSnapshot.data!;
        return Text(
          selection.selectedItems.length > 1 ? route.repository.pluralItemTitle : route.repository.singularItemTitle,
        );
      },
    ),
  );
}
