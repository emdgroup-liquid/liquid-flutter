import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdForm', (WidgetTester test) async {
    var theme = LdTheme();
    var submitted = false;
    onSubmit() async {
      submitted = true;
    }

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: MaterialApp(
              localizationsDelegates:
                  LiquidLocalizations.localizationsDelegates,
              locale: const Locale('en'),
              home: Scaffold(
                body: LdForm(
                    disabled: false,
                    hints: {"firstName": LdFormHint("Hint", LdHintType.error)},
                    onSubmit: onSubmit,
                    fields: [
                      LdFormItem(
                        "firstName",
                        const LdInput(
                          hint: "First Name",
                          label: "First Name",
                          valid: false,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ]),
              ),
            ))));

    await test.pumpAndSettle();

    expect(find.byType(LdForm), findsOneWidget);
    expect(find.byType(LdInput), findsOneWidget);
    expect(find.text("Hint"), findsOneWidget);

    await test.tap(find.byType(LdButton));

    await test.pumpAndSettle();

    expect(submitted, true);
  });
}
