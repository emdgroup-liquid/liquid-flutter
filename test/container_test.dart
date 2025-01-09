import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdContainer', (WidgetTester test) async {
    var theme = LdTheme();

    var containerKey = GlobalKey();

    // max width is 1200
    await test.binding.setSurfaceSize(const Size(1300, 800));
    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: Scaffold(
            body: Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery(
                  data: const MediaQueryData(size: Size(1300, 800)),
                  child: LdContainer(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                        key: containerKey,
                        width: double.infinity,
                        child: const Text("Hello")),
                  ),
                )),
          ),
        )));
    await test.pumpAndSettle();

    // check if the container is 1000 wide

    var containerSize = test.getSize(find.byKey(containerKey));

    expect(containerSize.width, 1200);
  });
}
