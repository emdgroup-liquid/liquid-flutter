// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdRadio ', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdRadio(
            checked: true,
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdRadio), findsOneWidget);

    var onCheckedCalled = false;
    onChecked(bool checked) {
      onCheckedCalled = true;
    }

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdRadio(
            checked: false,
            label: "Hello",
            onChanged: onChecked,
          ))),
    ));

    expect(find.byType(LdRadio), findsOneWidget);
    expect(find.text("Hello"), findsOneWidget);

    await test.tap(find.byType(LdRadio));

    expect(onCheckedCalled, true);
  });

  testWidgets('LdRadio with color', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdRadio(
            checked: true,
            color: shadAmber,
            label: "Hello",
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdRadio), findsOneWidget);

    final radio =
        ((test.firstWidget(find.byKey(const ValueKey("frame"))) as Container)
            .decoration as BoxDecoration);

    expect(
      radio.border?.top.color,
      shadAmber.active(false),
    );
    // check if color is correct by finding the box decoration
  });
}
