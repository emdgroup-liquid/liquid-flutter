import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget _withTheme({
  required Widget child,
  required MediaQueryData mediaQueryData,
}) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate,
      ],
      home: MediaQuery(
        data: mediaQueryData,
        child: LdScaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'LdScaffoldBody keeps top app bar padding when keyboard is open',
    (tester) async {
      const keyboardInset = 300.0;
      const safeTop = 44.0;

      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: safeTop, bottom: 34),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 34),
      );

      const keyboardData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: safeTop, bottom: 0),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 0),
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
      );

      EdgeInsets? bodyPadding;

      Future<void> pumpWith(MediaQueryData data) async {
        await tester.pumpWidget(
          _withTheme(
            mediaQueryData: data,
            child: LdAppBar.top(
              title: const Text('Title'),
              child: Builder(
                builder: (context) {
                  bodyPadding = MediaQuery.paddingOf(context);
                  return LdScaffoldBody(
                    children: [
                      const TextField(
                        key: Key('body_field'),
                        decoration: InputDecoration(
                          hintText: 'Body input',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();
      }

      await pumpWith(baseData);

      final barBottomNoKeyboard =
          tester.getBottomLeft(find.text('Title')).dy;
      final fieldTopNoKeyboard =
          tester.getTopLeft(find.byKey(const Key('body_field'))).dy;
      final paddingTopNoKeyboard = bodyPadding!.top;

      await pumpWith(keyboardData);

      final barBottomWithKeyboard =
          tester.getBottomLeft(find.text('Title')).dy;
      final fieldTopWithKeyboard =
          tester.getTopLeft(find.byKey(const Key('body_field'))).dy;

      expect(
        bodyPadding!.top,
        closeTo(paddingTopNoKeyboard, 1.0),
        reason:
            'App bar padding must stay stable when keyboard opens '
            '(before=$paddingTopNoKeyboard, after=${bodyPadding!.top})',
      );
      expect(
        fieldTopNoKeyboard,
        greaterThan(barBottomNoKeyboard - 1),
        reason: 'Body field should start below the app bar without keyboard',
      );
      expect(
        fieldTopWithKeyboard,
        greaterThan(barBottomWithKeyboard - 1),
        reason:
            'Body field should stay below the app bar with keyboard '
            '(field=$fieldTopWithKeyboard, bar=$barBottomWithKeyboard)',
      );
    },
  );

  testWidgets(
    'scroll subtree keeps app bar MediaQuery padding when keyboard opens',
    (tester) async {
      const keyboardInset = 300.0;
      const safeTop = 44.0;

      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: safeTop, bottom: 34),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 34),
      );

      const keyboardData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: safeTop, bottom: 0),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 0),
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
      );

      Future<void> pumpWith(MediaQueryData data) async {
        await tester.pumpWidget(
          _withTheme(
            mediaQueryData: data,
            child: LdAppBar.top(
              title: const Text('Title'),
              child: LdScaffoldBody(
                children: [
                  const TextField(
                    key: Key('body_field'),
                    decoration: InputDecoration(hintText: 'Body input'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();
      }

      await pumpWith(baseData);
      await pumpWith(keyboardData);

      final scrollContext = tester.element(
        find.descendant(
          of: find.byType(LdScaffoldBody),
          matching: find.byType(CustomScrollView),
        ),
      );
      final scrollPadding = MediaQuery.paddingOf(scrollContext);
      expect(
        scrollPadding.top,
        greaterThan(safeTop),
        reason:
            'Scrollable must see app bar padding after keyboard opens '
            '(top=${scrollPadding.top})',
      );
    },
  );

  testWidgets(
    'body TextField keeps focus when keyboard opens',
    (tester) async {
      const keyboardInset = 300.0;
      const safeTop = 44.0;

      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: safeTop, bottom: 34),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 34),
      );

      ldDisableAnimations = true;
      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme(),
          child: MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              LiquidLocalizations.delegate,
            ],
            home: _KeyboardSimulator(
              baseData: baseData,
              keyboardInset: keyboardInset,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Title'),
                  child: LdScaffoldBody(
                    children: [
                      const TextField(
                        key: Key('body_field'),
                        decoration: InputDecoration(hintText: 'Body input'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('body_field')));
      await tester.pump();

      expect(
        FocusScope.of(
          tester.element(find.byKey(const Key('body_field'))),
        ).focusedChild,
        isNotNull,
        reason: 'Body field should focus on tap',
      );

      await tester.tap(find.byKey(_KeyboardSimulator.openKey));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        FocusScope.of(
          tester.element(find.byKey(const Key('body_field'))),
        ).focusedChild,
        isNotNull,
        reason: 'Body field must stay focused after keyboard opens',
      );
    },
  );

  testWidgets(
    'LdScaffoldBody shrinks scroll viewport when keyboard is open',
    (tester) async {
      const keyboardInset = 300.0;
      const screenHeight = 800.0;

      const baseData = MediaQueryData(
        size: Size(400, screenHeight),
        padding: EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );

      ldDisableAnimations = true;
      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.ios,
          child: MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              LiquidLocalizations.delegate,
            ],
            home: _KeyboardSimulator(
              baseData: baseData,
              keyboardInset: keyboardInset,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Title'),
                  child: LdScaffoldBody(
                    children: [
                      const SizedBox(height: 1200),
                      const TextField(
                        key: Key('body_field'),
                        decoration: InputDecoration(hintText: 'Body input'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(_KeyboardSimulator.openKey));
      await tester.pumpAndSettle();

      final scrollable = tester.renderObject<RenderBox>(
        find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ).first,
      );

      expect(
        scrollable.size.height,
        lessThan(screenHeight - keyboardInset + 1),
        reason: 'Scroll viewport should shrink above the keyboard',
      );
    },
  );

  testWidgets(
    'LdScaffoldBody scrolls focused field above keyboard',
    (tester) async {
      const keyboardInset = 300.0;
      const screenHeight = 800.0;
      const safeTop = 44.0;

      const baseData = MediaQueryData(
        size: Size(400, screenHeight),
        padding: EdgeInsets.only(top: safeTop, bottom: 34),
        viewPadding: EdgeInsets.only(top: safeTop, bottom: 34),
      );

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      ldDisableAnimations = true;
      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.ios,
          child: MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              LiquidLocalizations.delegate,
            ],
            home: _KeyboardSimulator(
              baseData: baseData,
              keyboardInset: keyboardInset,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Title'),
                  child: LdScaffoldBody(
                    children: [
                      const SizedBox(height: 1200),
                      TextField(
                        key: const Key('body_field'),
                        focusNode: focusNode,
                        decoration: const InputDecoration(hintText: 'Body input'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(_KeyboardSimulator.openKey));
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final fieldBottom = tester.getBottomLeft(find.byKey(const Key('body_field'))).dy;
      final visibleBottom = screenHeight - keyboardInset;

      expect(
        fieldBottom,
        lessThanOrEqualTo(visibleBottom + 1),
        reason: 'Field bottom ($fieldBottom) should be above keyboard ($visibleBottom)',
      );
    },
  );
}

class _KeyboardSimulator extends StatefulWidget {
  static const openKey = Key('open_keyboard');

  final MediaQueryData baseData;
  final double keyboardInset;
  final Widget child;

  const _KeyboardSimulator({
    required this.baseData,
    required this.keyboardInset,
    required this.child,
  });

  @override
  State<_KeyboardSimulator> createState() => _KeyboardSimulatorState();
}

class _KeyboardSimulatorState extends State<_KeyboardSimulator> {
  bool _keyboardOpen = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = _keyboardOpen
        ? widget.baseData.copyWith(
            viewInsets: EdgeInsets.only(bottom: widget.keyboardInset),
          )
        : widget.baseData;

    return Stack(
      children: [
        MediaQuery(
          data: mediaQueryData,
          child: widget.child,
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: TextButton(
            key: _KeyboardSimulator.openKey,
            onPressed: () => setState(() => _keyboardOpen = true),
            child: const Text('Open keyboard'),
          ),
        ),
      ],
    );
  }
}
