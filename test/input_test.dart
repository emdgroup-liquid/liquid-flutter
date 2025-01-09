import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdInput', (WidgetTester test) async {
    var theme = LdTheme();

    var focus = FocusNode();
    var scaffoldKey = GlobalKey();
    var onBlurCalled = false;

    onBlur() {
      onBlurCalled = true;
    }

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: MaterialApp(
            home: Scaffold(
          key: scaffoldKey,
          body: LdInput(
            hint: "Foo",
            label: "Test",
            focusNode: focus,
            onBlur: (_) => onBlur(),
          ),
        ))));

    await test.pumpAndSettle();

    expect(find.byType(LdInput), findsOneWidget);
    // Focus the input
    await test.tap(find.byType(TextField));
    await test.pump(const Duration(milliseconds: 20));

    // Defocus the input

    focus.requestFocus();

    await test.pump(const Duration(milliseconds: 20));

    FocusScope.of(scaffoldKey.currentContext!).requestFocus(FocusNode());

    await test.pump(const Duration(milliseconds: 20));

    expect(onBlurCalled, true);
  });
}
