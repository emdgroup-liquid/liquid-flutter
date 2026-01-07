import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Wraps the [child] with a [LdThemeProvider] and [Localizations] widget as
/// required by the Liquid Design System.
Widget ldThemeWrapper({
  LdThemeBrightnessMode brightnessMode = LdThemeBrightnessMode.auto,
  LdThemeSize? size,
  List<LocalizationsDelegate> localizationsDelegates = const [],
  required Widget child,
}) {
  final theme = LdTheme();
  if (size != null) {
    theme.setThemeSize(size);
  }
  return Localizations(
    delegates: [
      ...localizationsDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      LiquidLocalizations.delegate,
    ],
    locale: const Locale('en'),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: LdThemeProvider(
        theme: theme,
        autoSize: size == null,
        brightnessMode: brightnessMode,
        child: child,
      ),
    ),
  );
}
