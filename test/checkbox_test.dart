// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdCheckbox ', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdCheckbox(
            checked: true,
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdCheckbox), findsOneWidget);

    var onCheckedCalled = false;
    onChecked(bool checked) {
      onCheckedCalled = true;
    }

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdCheckbox(
            checked: false,
            color: shadAmber,
            label: "Hello",
            onChanged: onChecked,
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdCheckbox), findsOneWidget);
    expect(find.text("Hello"), findsOneWidget);

    await test.tap(find.byType(LdCheckbox));

    expect(onCheckedCalled, true);
  });

  testWidgets('LdCheckbox with color', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdCheckbox(
            checked: true,
            color: shadAmber,
            label: "Hello",
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdCheckbox), findsOneWidget);

    expect(
        ((test.firstWidget(find.byKey(const ValueKey("frame"))) as Container)
                .decoration as BoxDecoration)
            .color,
        shadAmber.idle(false));
    // check if color is correct by finding the box decoration
  });
}
