import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdSelect', (WidgetTester test) async {
    var theme = LdTheme();
    var value = "test1";

    var onChangeCalled = false;

    onChange(String? newValue) {
      onChangeCalled = true;
      value = newValue ?? "";
    }

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: MaterialApp(
              home: Portal(
            child: Scaffold(
              body: LdSelect<String>(
                  key: const ValueKey("select"),
                  onChange: onChange,
                  value: value,
                  items: const [
                    LdSelectItem(child: Text("test1"), value: "test1"),
                    LdSelectItem(child: Text("test2"), value: "test2"),
                  ]),
            ),
          ))),
    ));

    await test.pumpAndSettle();

    expect(find.byKey(const ValueKey("select")), findsOneWidget);

    await test.tap(find.byType(LdTouchableSurface));

    await test.pumpAndSettle();

    await test.tap(find.text("test2", skipOffstage: false).last);

    await test.pumpAndSettle();

    expect(onChangeCalled, true);
    expect(value, "test2");
  });
}
