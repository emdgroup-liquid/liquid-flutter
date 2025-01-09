import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('LdButton interactivity', (WidgetTester test) async {
    var theme = LdTheme();

    // Called for all button types
    testButton(
        WidgetTester test,
        Widget Function(Function() onPress, Widget child) buttonBuilder,
        LdColor color) async {
      var pressed = false;

      void _onPress() {
        pressed = true;
      }

      var textKey = GlobalKey();

      await test.pumpWidget(LdThemeProvider(
          theme: theme,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: buttonBuilder(
              _onPress,
              Text(
                "Test button",
                key: textKey,
              ),
            ),
          )));

      await test.pumpAndSettle();

      expect(find.text("Test button"), findsOneWidget);

      final gestureHover =
          await test.createGesture(kind: PointerDeviceKind.mouse);

      await gestureHover.addPointer(location: Offset.zero);

      await test.pump();

      await gestureHover.moveTo(test.getCenter(find.byType(LdButton)));

      await test.pumpAndSettle();

      expect(pressed, isFalse);
      expect(
          ((test.firstWidget(find.byType(Container)) as Container).decoration
                  as BoxDecoration)
              .color,
          color.hover(false));

      expect(
        DefaultTextStyle.of(textKey.currentContext!).style.color,
        color.contrastingText(color.hover(false)),
      );

      await gestureHover.removePointer();

      var gesture = await test.startGesture(const Offset(10, 10), pointer: 7);

      await test.pumpAndSettle();

      expect(pressed, isFalse);

      await gesture.up();

      await test.pumpAndSettle();

      await test.tap(find.byType(LdButton));

      await test.pumpAndSettle();

      expect(pressed, isTrue);
    }

    var types = {
      shadSky: (onPressed, child) => LdButton(
            child: child,
            onPressed: onPressed,
          ),
    };

    for (var type in types.entries) {
      await testButton(test, type.value, type.key);
    }
  });

  testWidgets("LdButton with icon", (WidgetTester test) async {
    var _key = const Key("trailing");
    var _key2 = const Key("leading");

    var theme = LdTheme();
    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: LdButton(
            child: const Text("Test button"),
            leading: Icon(Icons.add, key: _key2),
            onPressed: () {},
            trailing: Icon(Icons.add, key: _key),
          ),
        )));
    await test.pumpAndSettle();
    expect(find.byKey(_key), isNotNull);
    expect(find.byKey(_key2), isNotNull);
  });

  testWidgets("LdButton sizes", (WidgetTester test) async {
    var theme = LdTheme();

    var sizes = [
      LdSize.xs,
      LdSize.s,
      LdSize.m,
      LdSize.l,
    ];

    var results = [];

    for (var size in sizes) {
      await test.pumpWidget(LdThemeProvider(
          theme: theme,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Center(
                  child: LdButton(
                    child: const Text("Test button"),
                    onPressed: () {},
                    size: size,
                  ),
                ),
              ],
            ),
          )));
      await test.pumpAndSettle();
      results.add(test.getSize(find.byType(LdButton)));
    }

    await test.pumpAndSettle();
    // Check that the sizes are in the correct order

    for (var i = 0; i < results.length - 1; i++) {
      expect(results[i].width, lessThan(results[i + 1].width));
      expect(results[i].height, lessThan(results[i + 1].height));
    }
  });

  testWidgets("LdButton loading", (WidgetTester test) async {
    var theme = LdTheme();

    var completer = Completer();

    onPressed() async {
      return completer.future;
    }

    await test.pumpWidget(MaterialApp(
      localizationsDelegates: const [LiquidLocalizations.delegate],
      home: LdThemeProvider(
          theme: theme,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: LdButton(
              child: const Text("Test button"),
              onPressed: onPressed,
            ),
          )),
    ));

    await test.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await test.tap(find.byType(LdButton));

    await test.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();

    await test.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
