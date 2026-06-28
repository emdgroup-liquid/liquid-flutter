import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/platform.dart';
import 'package:liquid_flutter/src/tokens.dart';
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

  final tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: theme.surface,
      border: Border.all(
        color: theme.floatingBorder,
        width: theme.borderWidth,
      ),
      borderRadius: theme.radius(LdSize.s),
    ),
    textStyle: baseStyle.copyWith(
      fontSize: theme.paragraphSize(LdSize.s),
      color: theme.text,
    ),
    padding: theme.balPad(LdSize.s),
  );

  if (palette.isDark) {
    return ThemeData(
      // Define the default brightness and colors.

      appBarTheme: AppBarTheme(
        backgroundColor: theme.surface,
        surfaceTintColor: theme.surface,
        foregroundColor: theme.text,
        shadowColor: theme.neutralShade(2),
      ),

      tooltipTheme: tooltipTheme,

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
    tooltipTheme: tooltipTheme,
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
    package: theme.fontFamilyPackage,
    fontFamily: theme.fontFamily,
    platform: switch (theme.platform) {
      LdPlatform.android => TargetPlatform.android,
      LdPlatform.ios => TargetPlatform.iOS,
      LdPlatform.macos => TargetPlatform.macOS,
      LdPlatform.linux => TargetPlatform.linux,
      LdPlatform.windows => TargetPlatform.windows,
      LdPlatform.webAndroid => TargetPlatform.android,
      LdPlatform.webIOS => TargetPlatform.iOS,
      LdPlatform.webMacOS => TargetPlatform.macOS,
      LdPlatform.webWindows => TargetPlatform.windows,
      LdPlatform.webLinux => TargetPlatform.linux,
      LdPlatform.webUnknown => TargetPlatform.android,
    },
  );
}
