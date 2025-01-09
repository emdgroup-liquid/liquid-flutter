import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget withLiquidTheme(Widget child, {LdTheme? theme}) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: theme ?? LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate
      ],
      home: LdPortal(
        child: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(800, 800),
                ),
                child: child),
          ),
        ),
      ),
    ),
  );
}
