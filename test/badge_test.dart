import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdBadge Golden", (WidgetTester tester) async {
    await multiGolden(
        tester,
        "LdBadge",
        {
          "default": (tester, place) async {
            await place(const LdBadge(
              color: shadSky,
              child: Text("Hello"),
            ));
            return null;
          },
          "LdSize.l": (tester, place) async {
            await place(const LdBadge(
              color: shadSky,
              size: LdSize.l,
              child: Text("Hello"),
            ));
            return null;
          },
          "LdSize.s": (tester, place) async {
            await place(const LdBadge(
              color: shadSky,
              size: LdSize.s,
              child: Text("Hello"),
            ));
            return null;
          },
          "LdSize.xs": (tester, place) async {
            await place(const LdBadge(
              color: shadSky,
              size: LdSize.xs,
              child: Text("Hello"),
            ));
            return null;
          },
        },
        width: 200);
  });

  testWidgets('LdBadge', (WidgetTester test) async {
    var theme = LdTheme();

    testBadgeVariant(LdColor variant, Color expectedColor) async {
      await test.pumpWidget(LdThemeProvider(
          theme: theme,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
                child: LdBadge(
              color: variant,
              child: const Text(
                "Hello",
              ),
            )),
          )));

      await test.pumpAndSettle();

      expect(find.text("Hello"), findsOneWidget);
      expect(find.byType(LdBadge), findsOneWidget);
      expect(
          ((test.firstWidget(find.byType(Container)) as Container).decoration
                  as BoxDecoration)
              .color,
          expectedColor);
    }

    testBadgeVariant(
      shadSky,
      shadSky.idle(false),
    );
  });
}
