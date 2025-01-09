import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'theme.dart';

/// build a material theme with the current [LdThemeData] to create a [MaterialApp]
ThemeData getMaterialTheme(LdTheme theme) {
  final palette = theme.palette;
  final baseStyle = TextStyle(
    color: palette.text,
    package: theme.fontFamilyPackage,
    fontFamily: theme.fontFamily,
  );

  final text = TextTheme(
    titleLarge: baseStyle.copyWith(
      fontSize: theme.headlineSize(LdSize.l),
      fontWeight: FontWeight.w700,
    ),
    titleMedium: baseStyle.copyWith(
      fontSize: theme.headlineSize(LdSize.m),
      fontWeight: FontWeight.w700,
    ),
    titleSmall: baseStyle.copyWith(
      fontSize: theme.headlineSize(LdSize.s),
      fontWeight: FontWeight.w700,
    ),
    labelLarge: baseStyle.copyWith(
      fontSize: theme.labelSize(LdSize.l),
      fontWeight: FontWeight.w400,
    ),
    labelMedium: baseStyle.copyWith(
      fontSize: theme.labelSize(LdSize.m),
      fontWeight: FontWeight.w700,
    ),
    labelSmall: baseStyle.copyWith(
      fontSize: theme.labelSize(LdSize.s),
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: baseStyle.copyWith(
      fontSize: theme.paragraphSize(LdSize.l),
    ),
    bodyMedium: baseStyle.copyWith(
      fontSize: theme.paragraphSize(LdSize.m),
    ),
    bodySmall: baseStyle.copyWith(
      fontSize: theme.paragraphSize(LdSize.s),
    ),
  );

  if (palette.isDark) {
    return ThemeData(
      // Define the default brightness and colors.

      appBarTheme: AppBarTheme(
        backgroundColor: theme.surface,
        surfaceTintColor: theme.surface,
        centerTitle: false,
        foregroundColor: theme.text,
        shadowColor: theme.neutralShade(2),
      ),

      colorScheme: ColorScheme.dark(
        primary: theme.primaryColor,
        onPrimary: theme.primaryColorText,
        secondary: theme.secondaryColor,
        onSecondary: theme.secondaryColorText,
        error: palette.error.idle(theme.isDark),
        onError: palette.error.contrastingText(
          palette.error.idle(theme.isDark),
        ),
        tertiary: theme.warningColor,
        onTertiary: theme.warningColorText,
        surface: theme.background,
        onSurface: theme.text,
      ),

      package: theme.fontFamilyPackage,
      fontFamily: theme.fontFamily,

      textTheme: text,
    );
  }

  return ThemeData(
    // Define the default brightness and colors.

    appBarTheme: AppBarTheme(
      backgroundColor: theme.surface,
      surfaceTintColor: theme.surface,
      shadowColor: theme.neutralShade(2),
      centerTitle: false,
      foregroundColor: theme.text,
    ),
    colorScheme: ColorScheme.light(
      primary: theme.primaryColor,
      onPrimary: theme.primaryColorText,
      secondary: theme.secondaryColor,
      onSecondary: theme.secondaryColorText,
      error: palette.error.idle(theme.isDark),
      onError: palette.error.contrastingText(
        palette.error.idle(theme.isDark),
      ),
      tertiary: theme.warningColor,
      onTertiary: theme.warningColorText,
      surface: theme.background,
      onSurface: theme.text,
    ),
    textTheme: text,
    extensions: [
      WoltModalSheetThemeData(
        topBarShadowColor: theme.background.withAlpha(0),
        backgroundColor: theme.surface,
        navBarHeight: 48,
        topBarElevation: 0,
        isTopBarLayerAlwaysVisible: true,
        modalBarrierColor: theme.palette.neutral.shades.last.withAlpha(204),
      )
    ],
  );
}
