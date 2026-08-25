import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  tearDown(() {
    ldDisableAnimations = true;
  });

  testWidgets('LdLoader keeps a single CustomPaint across frames', (tester) async {
    ldDisableAnimations = false;

    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: LdLoader(),
          ),
        ),
      ),
    );

    expect(find.byType(LdLoader), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);

    final elementCount = collectAllElementsFrom(
      tester.binding.rootElement!,
      skipOffstage: false,
    ).length;

    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.byType(LdLoader), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
    expect(
      collectAllElementsFrom(tester.binding.rootElement!, skipOffstage: false).length,
      elementCount,
    );
  });
}
