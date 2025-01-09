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
            child: Text("Hello"),
            footer: Text("Footer"),
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.text("Header"), findsOneWidget);
    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("Footer"), findsOneWidget);

    expect(find.byType(LdCard), findsOneWidget);
  });
}
