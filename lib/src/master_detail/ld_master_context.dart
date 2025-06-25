import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/master_detail_route_state.dart';
import 'package:provider/provider.dart';

class LdMasterContext<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final bool isSplit;
  final bool detailInDialog;

  final LdMasterDetailRouteState<T, IdType, GroupingCriterion> state;

  LdMasterContext({
    required this.isSplit,
    required this.detailInDialog,
    required this.state,
  });

  LdMasterContext<T, IdType, GroupingCriterion> copyWithSelectionOverride({
    Set<IdType>? selectedItems,
  }) {
    return LdMasterContext<T, IdType, GroupingCriterion>(
      isSplit: isSplit,
      detailInDialog: detailInDialog,
      state: state.copyWith(selectedItems: selectedItems),
    );
  }

  static LdMasterContext<T, IdType, GroupingCriterion> of<T extends Identifiable<IdType>, IdType, GroupingCriterion>(
      BuildContext context) {
    return context.watch<LdMasterContext<T, IdType, GroupingCriterion>>();
  }

  factory LdMasterContext.fromRoute(LdMasterDetailRoute<T, IdType, GroupingCriterion> route, BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return LdMasterContext(
      isSplit: route.isSplit(size),
      detailInDialog: route.presentationMode == MasterDetailPresentationMode.dialog,
      state: route.state,
    );
  }
}
