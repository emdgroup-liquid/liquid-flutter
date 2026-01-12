import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Wraps the [child] with a [LdThemeProvider] and [Localizations] widget as
/// required by the Liquid Design System.
Widget ldThemeWrapper({
  LdThemeBrightnessMode brightnessMode = LdThemeBrightnessMode.auto,
  LdThemeSize? size,
  List<LocalizationsDelegate> localizationsDelegates = const [],
  LdPlatform? platform,
  required Widget child,
}) {
  final theme = LdTheme();
  if (size != null) {
    theme.setThemeSize(size);
  }
  if (platform != null) {
    theme.platform = platform;
  }
  return LdThemeProvider(
    theme: theme,
    brightnessMode: brightnessMode,
    child: LdThemedAppBuilder(appBuilder: (context, theme) {
      return MaterialApp(
        theme: theme,
        localizationsDelegates: [
          ...localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          LiquidLocalizations.delegate,
        ],
        locale: const Locale('en'),
        home: child,
      );
    }),
  );
}
