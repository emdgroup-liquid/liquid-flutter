import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdHint', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdHint(
            type: LdHintType.info,
            child: Text(
              "Hello",
            ),
          )),
        )));

    await test.pumpAndSettle();

    expect(find.text("Hello"), findsOneWidget);
    expect(find.byType(LdHint), findsOneWidget);
  });
}
