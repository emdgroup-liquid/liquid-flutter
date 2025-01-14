import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/modal/modal_types.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Returns a sheet type based on the device type.
///
/// If the device is a watch or mobile, it returns a [LdSheetType].
/// Otherwise, it returns a [LdDialogType].
WoltModalType ldAutoModalType(
    {required BuildContext context,
    required LdSize dialogSize,
    required int index,
    Size? fixedDialogSize,
    double? topRadius,
    double? bottomRadius,
    EdgeInsets? insets}) {
  final theme = LdTheme.of(context);
  final deviceType = getDeviceType(MediaQuery.sizeOf(context));

  return switch (deviceType) {
    DeviceScreenType.watch || DeviceScreenType.mobile => LdSheetType(
        theme: theme,
        index: index,
        topRadius: topRadius,
        insets: insets ?? EdgeInsets.zero,
        bottomRadius: bottomRadius,
      ),
    _ => LdDialogType(
        theme: theme,
        fixedSize: fixedDialogSize,
        size: dialogSize,
        index: index,
      ),
  };
}
