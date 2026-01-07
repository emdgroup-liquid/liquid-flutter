// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdToggle ', (WidgetTester test) async {
    var theme = LdTheme();

    var onCheckedCalled = false;
    onChecked(bool checked) {
      onCheckedCalled = true;
    }

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdToggle(
            checked: true,
            onChanged: onChecked,
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byType(LdToggle), findsOneWidget);

    await test.tap(find.byType(LdToggle));

    await test.pumpAndSettle();

    expect(onCheckedCalled, true);
  });
}
