import 'package:flutter/material.dart';
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
}
