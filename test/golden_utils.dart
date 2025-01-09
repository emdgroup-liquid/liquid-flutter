import 'dart:convert';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef WidgetBuilder = Future<Future<void> Function()?> Function(
  WidgetTester tester,
  Future<void> Function(Widget widget) placeWidget,
);
Widget liquidFrame({
  required Key key,
  required Widget child,
  required bool isDark,
  required LdThemeSize size,
}) {
  final theme = LdTheme()..setThemeSize(size);
  return LdThemeProvider(
    theme: theme,
    autoSize: false,
    brightnessMode:
        isDark ? LdThemeBrightnessMode.dark : LdThemeBrightnessMode.light,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getMaterialTheme(theme),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate,
      ],
      home: LdPortal(child: Builder(builder: (context) {
        return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: theme.radius(LdSize.m),
            ),
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (context) {
                    return SingleChildScrollView(
                      child: Center(key: key, child: child),
                    );
                  },
                )));
      })),
    ),
  );
}

const List<String> _overridableFonts = [
  'Roboto',
  '.SF UI Display',
  '.SF UI Text',
  '.SF Pro Text',
  '.SF Pro Display',
];
String derivedFontFamily(Map<String, dynamic> fontDefinition) {
  if (!fontDefinition.containsKey('family')) {
    return '';
  }

  final fontFamily = fontDefinition['family'] as String;
  final fonts = fontDefinition['fonts'] as List<dynamic>;

  if (_overridableFonts.contains(fontFamily)) {
    return fontFamily;
  }

  if (fontFamily.startsWith('packages/')) {
    final fontFamilyName = fontFamily.split('/').last;
    if (_overridableFonts.any((font) => font == fontFamilyName)) {
      return fontFamilyName;
    }
  } else {
    for (final fontType in fonts) {
      final asset = (fontType as Map<String, dynamic>)['asset'] as String?;
      if (asset != null && asset.startsWith('packages')) {
        final packageName = asset.split('/')[1];
        return 'packages/$packageName/$fontFamily';
      }
    }
  }
  return fontFamily;
}

Future<void> multiGolden(
  WidgetTester tester,
  String name,
  Map<String, WidgetBuilder> widgets, {
  int width = 900,
  int? height,
}) async {
  ldDisableAnimations = true;
  ldIncludeFontPackage = false;

  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string) as Iterable<dynamic>,
  ) as List<dynamic>;

  for (final font in fontManifest) {
    final fontLoader =
        FontLoader(derivedFontFamily(font as Map<String, dynamic>));
    final fonts = font['fonts'] as List<dynamic>;
    for (final fontType in fonts) {
      fontLoader.addFont(
        rootBundle.load((fontType as Map<String, dynamic>)['asset'] as String),
      );
    }
    await fontLoader.load();
  }

  for (final entry in widgets.entries) {
    for (final themeSize in LdThemeSize.values) {
      for (final brightness in Brightness.values) {
        final slug = '${entry.key}/'
            "${themeSize.toString().split(".").last}"
            "-${brightness.toString().split(".").last}";
        await tester.binding.setSurfaceSize(
          Size(width.toDouble(), height?.toDouble() ?? 1000),
        );

        tester.view.physicalSize = Size(width.toDouble(), 1000);

        final cleanup = await entry.value(tester, (widget) async {
          await tester.pumpWidget(
            liquidFrame(
              key: ValueKey(slug),
              child: widget,
              isDark: brightness == Brightness.dark,
              size: themeSize,
            ),
          );
        });
        final size =
            find.byKey(ValueKey(slug)).evaluate().single.size ?? Size.zero;
        if (height == null) {
          await tester.binding.setSurfaceSize(
            Size(width.toDouble(), size.height + 64),
          );
          tester.view.physicalSize = Size(width.toDouble(), size.height + 64);
        }
        await tester.pump();

        final path = 'goldens/${name.toSnakeCase()}/${slug.toSnakeCase()}.png';

        await expectLater(
          find.byWidgetPredicate((widget) => true).first,
          matchesGoldenFile(path),
        );

        if (cleanup != null) {
          await cleanup();
        }
        await tester.pumpAndSettle();

        await tester.pumpWidget(const SizedBox());

        await tester.pumpAndSettle();
      }
    }
  }
}
