// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdBreadcrumb Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdBreadcrumb", {
      "LdColorNames.richBlue": (tester, place) async {
        await place(LdBreadcrumb.fromStrings(
          const ["Home", "About", "Contact"],
        ));
        return null;
      },
    });
  });

  testWidgets('LdBreadcrumb ', (WidgetTester test) async {
    var theme = LdTheme();

    var lastKey = GlobalKey();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdBreadcrumb(
            children: [
              const Text("Home"),
              const Text("About"),
              Text("Contact", key: lastKey),
            ],
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.text("Home"), findsOneWidget);
    expect(find.text("About"), findsOneWidget);
    expect(find.text("Contact"), findsOneWidget);
    expect(find.byType(LdBreadcrumb), findsOneWidget);

    // Check if defaultTextStyle at lastKeys context is correct
    var lastContext = lastKey.currentContext;
    var lastTextStyle = DefaultTextStyle.of(lastContext!).style;

    expect(lastTextStyle.color, theme.palette.primary.idle(false));
  });
  testWidgets('LdBreadcrumb fromStrings', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdBreadcrumb.fromStrings(
                  const ["Home", "About", "Contact"]))),
    ));

    await test.pumpAndSettle();

    expect(find.text("Home"), findsOneWidget);
    expect(find.text("About"), findsOneWidget);
    expect(find.text("Contact"), findsOneWidget);
    expect(find.byType(LdBreadcrumb), findsOneWidget);
  });
}
