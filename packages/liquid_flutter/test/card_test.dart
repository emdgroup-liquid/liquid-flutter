// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdCard ', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdCard(
            header: Text("Header"),
            footer: Text("Footer"),
            child: Text("Hello"),
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.text("Header"), findsOneWidget);
    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("Footer"), findsOneWidget);

    expect(find.byType(LdCard), findsOneWidget);
  });

  testWidgets('LdCard in Row with unbounded width does not throw', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              LdCard(
                header: Text('H'),
                child: Text('Body'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Body'), findsOneWidget);
  });
}
