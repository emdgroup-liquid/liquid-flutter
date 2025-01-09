import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdSwitch', (WidgetTester test) async {
    var theme = LdTheme();
    var value = "test";

    var onChangeCalled = false;

    onChange(String newValue) {
      onChangeCalled = true;
      value = newValue;
    }

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
                child: LdSwitch<String>(
                    onChanged: onChange,
                    children: const {
                      "test": Text("test"),
                      "test2": Text("test2"),
                    },
                    value: value)))));

    await test.pumpAndSettle();
    expect(find.byType(LdSwitch<String>), findsOneWidget);

    await test.tap(find.text("test2"));

    await test.pumpAndSettle();

    expect(onChangeCalled, true);
    expect(value, "test2");
  });
}
