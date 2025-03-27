import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdTag', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: LdTag(
            child: Text("Hello"),
            color: shadGreen,
          )),
        )));

    await test.pumpAndSettle();
    expect(find.text("Hello"), findsOneWidget);
    expect(find.byType(LdTag), findsOneWidget);

    final color =
        ((test.firstWidget<Container>(find.byKey(const ValueKey("tagBox"))))
                .decoration as BoxDecoration)
            .color;

    expect(color, const Color(0x3215803d));
  });
}
