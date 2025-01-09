import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdAccordion interactivity', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: LdAccordion(
              childBuilder: (context, n) {
                return SizedBox(height: 300, child: Text("Test $n"));
              },
              itemCount: 2,
              initialOpenIndex: const {0},
              headerBuilder: (context, n) {
                return Text("Header $n");
              },
            ),
          ),
        )));

    await test.pumpAndSettle();

    expect(find.text("Header 0"), findsOneWidget);
    expect(find.text("Header 1"), findsOneWidget);

    expect(find.text("Test 0"), findsOneWidget);

    await test.pumpAndSettle();

    var expandedSize = test.getSize(find.byType(LdAccordion));

    // Collapse the intial open index
    await test.tap(find.text("Header 0"));

    await test.pumpAndSettle();

    // Accordion should be smaller than the expanded size
    expect(test.getSize(find.byType(LdAccordion)).height,
        lessThan(expandedSize.height));
  });

  testWidgets('LdAccordion fromList', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: LdAccordion.fromList([
              LdAccordionItem(
                header: const Text("Header 0"),
                child: const Text("Test 0"),
              ),
              LdAccordionItem(
                header: const Text("Header 1"),
                child: const Text("Test 1"),
              ),
              LdAccordionItem(
                header: const Text("Header 2"),
                child: const Text("Test 2"),
              ),
            ], initialOpenIndex: const {
              0
            }),
          ),
        )));

    await test.pumpAndSettle();

    expect(find.text("Header 0"), findsOneWidget);
    expect(find.text("Header 1"), findsOneWidget);
    expect(find.text("Header 2"), findsOneWidget);
    expect(find.text("Test 0"), findsOneWidget);
  });

  testWidgets("LdAccordion multiple open", (WidgetTester test) async {
    var theme = LdTheme();

    await test.binding.setSurfaceSize(const Size(1000, 1000));

    var allowMultipleOpen = true;

    var completer = Completer();

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: FutureBuilder(
              future: completer.future,
              builder: ((context, snapshot) => LdAccordion(
                    childBuilder: (context, n) {
                      return SizedBox(height: 400, child: Text("Test $n"));
                    },
                    itemCount: 3,
                    allowMultipleOpen: allowMultipleOpen,
                    initialOpenIndex: const {0, 1},
                    headerBuilder: (context, n) {
                      return Text("Header $n");
                    },
                  )),
            ),
          ),
        )));

    await test.pumpAndSettle();

    List<bool> getCollapsed() {
      return List<LdCollapse>.from(test.widgetList(find.byType(LdCollapse)))
          .map((e) => e.collapsed)
          .toList();
    }

    expect(getCollapsed(), [false, false, true]);

    // Collapse the intial open index
    await test.tap(find.text("Header 0"));

    await test.pumpAndSettle();

    expect(getCollapsed(), [true, false, true]);

    // Accordion should be smaller than the expanded size

    await test.tap(find.text("Header 0"));

    await test.pumpAndSettle();

    expect(getCollapsed(), [false, false, true]);

    allowMultipleOpen = false;
    // Forces a rebuild bit of a hack
    completer.complete();

    await test.pumpAndSettle();

    // Accordion should be smaller than the expanded size because it collapses all but one
    expect(getCollapsed(), [false, true, true]);

    await test.tap(find.text("Header 1"));

    await test.pumpAndSettle();

    expect(getCollapsed(), [true, false, true]);
  });
}
