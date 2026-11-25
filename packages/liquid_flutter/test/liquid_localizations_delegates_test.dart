import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('liquidLocalizationsDelegates', () {
    testWidgets('resolves Material and Liquid strings for a German locale', (
      tester,
    ) async {
      MaterialLocalizations? material;
      LiquidLocalizations? liquid;

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: liquidLocalizationsDelegates,
            supportedLocales: LiquidLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                material = MaterialLocalizations.of(context);
                liquid = LiquidLocalizations.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(liquid?.localeName, 'de');
      // 'Schließen' only exists in material_ui's GlobalMaterialLocalizations.
      // The legacy delegate would leave this string in English.
      expect(material?.closeButtonTooltip, 'Schließen');
    });

    testWidgets('the generated delegate list lacks material_ui localizations', (
      tester,
    ) async {
      MaterialLocalizations? material;
      LiquidLocalizations? liquid;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          supportedLocales: LiquidLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              // Use the non-asserting lookup: MaterialLocalizations.of would
              // throw here, which is exactly what the legacy delegates cause.
              material = Localizations.of<MaterialLocalizations>(
                context,
                MaterialLocalizations,
              );
              liquid = LiquidLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Documents why liquidLocalizationsDelegates exists: the generated list
      // only satisfies the deprecated flutter_localizations types. Liquid's own
      // strings still resolve, but material_ui gets no MaterialLocalizations
      // delegate for German and would crash in liquid widgets that need one.
      // The framework reports the missing German delegates as a test error.
      expect(tester.takeException(), isNotNull);
      expect(liquid?.localeName, 'de');
      expect(material, isNull);
    });
  });
}
