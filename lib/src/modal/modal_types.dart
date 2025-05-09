import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class LdSheetType extends WoltBottomSheetType {
  final int index;
  final EdgeInsets insets;
  LdSheetType({
    required LdTheme theme,
    this.insets = EdgeInsets.zero,
    double? topRadius,
    double? bottomRadius,
    this.index = 0,
  }) : super(
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius ?? 0),
              bottomRight: Radius.circular(bottomRadius ?? 0),
              topLeft: Radius.circular(
                topRadius ?? theme.sizingConfig.radiusL,
              ),
              topRight: Radius.circular(
                topRadius ?? theme.sizingConfig.radiusL,
              ),
            ),
          ),
        );

  @override
  BoxConstraints layoutModal(Size availableSize) {
    if (insets != EdgeInsets.zero) {
      return super.layoutModal(
        Size(availableSize.width - insets.horizontal,
            availableSize.height - insets.vertical - index * 48),
      );
    }

    return super.layoutModal(availableSize);
  }

  @override
  Offset positionModal(
      Size availableSize, Size modalContentSize, TextDirection _) {
    final xOffset = max(
      0.0,
      (availableSize.width - modalContentSize.width) / 2,
    );

    final yOffset = max(
      0.0,
      (availableSize.height - modalContentSize.height + insets.bottom),
    );
    return Offset(xOffset, yOffset - insets.top);
  }
}

class LdDialogType extends WoltDialogType {
  final LdSize size;
  final Size? fixedSize;
  final LdTheme theme;
  final int index;
  LdDialogType({
    required this.theme,
    this.size = LdSize.m,
    this.index = 0,
    this.fixedSize,
  }) : super(
          shapeBorder: RoundedRectangleBorder(
            borderRadius: theme.radius(LdSize.m),
            side: BorderSide(
              color: theme.stroke,
              width: 1,
            ),
          ),
        );

  @override
  Offset positionModal(
      Size availableSize, Size modalContentSize, TextDirection _) {
    final xOffset =
        max(0.0, (availableSize.width - modalContentSize.width) / 2);
    final yOffset = max(
        0.0, (availableSize.height - modalContentSize.height + index * 64) / 2);
    return Offset(xOffset, yOffset);
  }

  @override
  BoxConstraints layoutModal(Size availableSize) {
    late Size configuredSize;

    switch (size) {
      case LdSize.xs:
        configuredSize = const Size(400, 300);
        break;
      case LdSize.s:
        configuredSize = const Size(500, 400);
        break;
      case LdSize.m:
        configuredSize = const Size(600, 500);
        break;
      case LdSize.l:
        configuredSize = const Size(900, 700);
        break;
    }

    if (fixedSize != null) {
      configuredSize = fixedSize!;
    }

    final minPadding = theme.pad(size: LdSize.l);

    double maxWidth = min(
      configuredSize.width,
      availableSize.width - minPadding.horizontal,
    );

    double maxHeight = min(
      configuredSize.height,
      availableSize.height - minPadding.vertical - index * 64,
    );

    return BoxConstraints(
      minWidth: 0,
      maxWidth: maxWidth,
      minHeight: 0,
      maxHeight: maxHeight,
    );
  }
}
