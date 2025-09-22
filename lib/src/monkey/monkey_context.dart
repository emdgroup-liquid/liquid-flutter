import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

class LdMonkeyContext<T extends Identifiable<IdType>, IdType> {
  final bool isSideBySide;
  final bool detailInDialog;

  final LdMonkeyDetailState<T, IdType> state;

  LdMonkeyContext({
    required this.isSideBySide,
    required this.detailInDialog,
    required this.state,
  });

  LdMonkeyContext<T, IdType> copyWithSelectionOverride({
    Set<IdType>? selectedItems,
  }) {
    return LdMonkeyContext<T, IdType>(
      isSideBySide: isSideBySide,
      detailInDialog: detailInDialog,
      state: state.copyWith(selectedItems: selectedItems),
    );
  }

  static LdMonkeyContext<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context,
  ) {
    return context.read<LdMonkeyContext<T, IdType>>();
  }

  factory LdMonkeyContext.fromRoute(LdMonkey<T, IdType> route, BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return LdMonkeyContext(
      isSideBySide: route.isSideBySide(size),
      detailInDialog: route.presentationMode == MonkeyDetailVariant.dialog,
      state: route.state,
    );
  }
}
