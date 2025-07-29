import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

class LdMonkeyContext<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final bool isSideBySide;
  final bool detailInDialog;

  final LdMonkeyDetailState<T, IdType, GroupingCriterion> state;

  LdMonkeyContext({
    required this.isSideBySide,
    required this.detailInDialog,
    required this.state,
  });

  LdMonkeyContext<T, IdType, GroupingCriterion> copyWithSelectionOverride({
    Set<IdType>? selectedItems,
  }) {
    return LdMonkeyContext<T, IdType, GroupingCriterion>(
      isSideBySide: isSideBySide,
      detailInDialog: detailInDialog,
      state: state.copyWith(selectedItems: selectedItems),
    );
  }

  static LdMonkeyContext<T, IdType, GroupingCriterion> of<T extends Identifiable<IdType>, IdType, GroupingCriterion>(
    BuildContext context,
  ) {
    return context.read<LdMonkeyContext<T, IdType, GroupingCriterion>>();
  }

  factory LdMonkeyContext.fromRoute(LdMonkey<T, IdType, GroupingCriterion> route, BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return LdMonkeyContext(
      isSideBySide: route.isSideBySide(size),
      detailInDialog: route.presentationMode == MonkeyDetailVariant.dialog,
      state: route.state,
    );
  }
}
