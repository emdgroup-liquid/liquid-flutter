import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

void main() {
  testGoldens("LdBadge Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdBadge", {
      "default": (tester, place) async {
        await place(const LdBadge(
          color: shadSky,
          child: Text("Hello"),
        ));
      },
      "LdSize.l": (tester, place) async {
        await place(const LdBadge(
          color: shadSky,
          size: LdSize.l,
          child: Text("Hello"),
        ));
      },
      "LdSize.s": (tester, place) async {
        await place(const LdBadge(
          color: shadSky,
          size: LdSize.s,
          child: Text("Hello"),
        ));
      },
      "LdSize.xs": (tester, place) async {
        await place(const LdBadge(
          color: shadSky,
          size: LdSize.xs,
          child: Text("Hello"),
        ));
      },
    }, frameScenarios: const [
      LdFrameOptions(width: 200)
    ]);
  });

  testWidgets('LdBadge', (WidgetTester test) async {
    var theme = LdTheme();

    testBadgeVariant(LdColor variant) async {
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
    }

    testBadgeVariant(
      shadSky,
    );
  });
}
