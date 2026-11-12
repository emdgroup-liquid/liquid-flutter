import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdOrb', (WidgetTester test) async {
    var theme = LdTheme();
    await test.pumpWidget(
      LdThemeProvider(
        theme: theme,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: LdOrb(0.5),
          ),
        ),
      ),
    );

    await test.pump();

    expect(find.byType(LdOrb), findsOneWidget);
  });

  testWidgets('LdOrb keeps a single CustomPaint tree across frames', (tester) async {
    ldDisableAnimations = false;
    addTearDown(() {
      ldDisableAnimations = true;
    });

    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: LdOrb(0.5),
          ),
        ),
      ),
    );

    expect(find.byType(LdOrb), findsOneWidget);
    expect(find.byType(RepaintBoundary), findsWidgets);

    final elementCount = collectAllElementsFrom(
      tester.binding.rootElement!,
      skipOffstage: false,
    ).length;

    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.byType(LdOrb), findsOneWidget);
    expect(
      collectAllElementsFrom(tester.binding.rootElement!, skipOffstage: false).length,
      elementCount,
    );
  });
}
