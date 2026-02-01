import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Returns the [SystemUiOverlayStyle] for app bar surfaces (LdAppBar, LdTabNavigation).
///
/// Applies theme-appropriate status bar and navigation bar styling.
SystemUiOverlayStyle appBarSystemUiOverlayStyle(LdTheme theme) {
  if (theme.isDark) {
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: theme.background.withAlpha(150),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );
  }
  return SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: theme.background.withAlpha(150),
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}
