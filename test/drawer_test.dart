import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdDrawer', (WidgetTester test) async {
    var theme = LdTheme();
    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: const Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQueryData(
                size: Size(1000, 1000),
              ),
              child: Center(
                child: LdAutoSpace(children: [
                  LdDrawerHeader(title: Text("Header ")),
                  LdSectionHeader("Section 1"),
                  LdDrawerItemSection(
                      active: true,
                      leading: Icon(Icons.circle),
                      child: Text("Item 1")),
                  LdDrawerItemSection(
                      leading: Icon(Icons.circle), child: Text("Item 2")),
                  LdDrawerItemSection(
                    leading: Icon(Icons.circle),
                    initiallyExpanded: true,
                    child: Text("Item 3"),
                    children: [
                      LdDrawerItemSection(child: Text("Item 3.1")),
                      LdDrawerItemSection(child: Text("Item 3.2")),
                      LdDrawerItemSection(
                        child: Text("Item 3.3"),
                        trailing: Icon(Icons.arrow_right),
                      )
                    ],
                  )
                ]),
              ),
            ))));
    await test.pumpAndSettle();

    expect(find.byType(LdDrawerHeader), findsOneWidget);
    expect(find.byType(LdSectionHeader), findsOneWidget);
    expect(find.byType(LdDrawerItemSection), findsNWidgets(6));
  });
}
