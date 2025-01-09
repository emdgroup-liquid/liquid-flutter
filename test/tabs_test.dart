// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdTabs', (WidgetTester test) async {
    var theme = LdTheme();

    var key = GlobalKey();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTabController(
                length: 2,
                child: LdTabs(
                  key: key,
                  children: const [
                    Text("test1"),
                    Text("test2"),
                  ],
                )))));

    await test.pumpAndSettle();
    expect(find.byType(LdTabs), findsOneWidget);

    expect(DefaultTabController.of(key.currentContext!).index, 0);

    await test.tap(find.text("test2"));

    await test.pumpAndSettle();

    expect(DefaultTabController.of(key.currentContext!).index, 1);
  });
}
