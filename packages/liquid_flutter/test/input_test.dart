import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            onBlurred: (_) => onBlur(),
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

  testWidgets('LdInput multiline desktop Enter submits', (tester) async {
    final theme = LdTheme()..platform = LdPlatform.macos;
    final controller = TextEditingController(text: 'hello');
    String? submitted;

    await tester.pumpWidget(
      LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: Scaffold(
            body: LdInput(
              hint: 'Message',
              controller: controller,
              minLines: 1,
              maxLines: 6,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(submitted, 'hello');
    expect(controller.text, 'hello');
  });

  testWidgets('LdInput multiline desktop Shift+Enter inserts newline', (tester) async {
    final theme = LdTheme()..platform = LdPlatform.macos;
    final controller = TextEditingController(text: 'hello');
    String? submitted;

    await tester.pumpWidget(
      LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: Scaffold(
            body: LdInput(
              hint: 'Message',
              controller: controller,
              minLines: 1,
              maxLines: 6,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(submitted, isNull);
    expect(controller.text, contains('\n'));
  });

  testWidgets('LdInput multiline mobile Enter does not submit', (tester) async {
    final theme = LdTheme()..platform = LdPlatform.ios;
    final controller = TextEditingController(text: 'hello');
    String? submitted;

    await tester.pumpWidget(
      LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: Scaffold(
            body: LdInput(
              hint: 'Message',
              controller: controller,
              minLines: 1,
              maxLines: 6,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(submitted, isNull);
  });
}
