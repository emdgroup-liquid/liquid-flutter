import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_theme_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('LdAppBar Widget Tests', () {
    testWidgets('Basic app bar rendering (top)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(title: const Text('Test App Bar')),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test App Bar'), findsOneWidget);
    });

    testWidgets('Basic app bar rendering (bottom)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.bottom(title: const Text('Bottom App Bar')),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom App Bar'), findsOneWidget);
    });

    testWidgets('App bar with leading widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  leading: const Icon(LucideIcons.menu),
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.menu), findsOneWidget);
    });

    testWidgets('App bar with trailing widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  trailing: const Icon(LucideIcons.settings),
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    });

    testWidgets('App bar with actions', (WidgetTester tester) async {
      ldDisableAnimations = true;
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  actions: [
                    LdAppBarAction(
                      onPressed: () {
                        actionPressed = true;
                      },
                      child: const Text('Action'),
                    ),
                  ],
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Action'), findsOneWidget);

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(actionPressed, isTrue);
    });

    testWidgets('App bar scroll behavior - static', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('Static App Bar'),
                  scrollBehavior: LdAppBarScrollBehavior.static,
                ),
              ],
              body: ListView(
                children: List.generate(
                  50,
                  (index) => ListTile(title: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Static App Bar'), findsOneWidget);
    });

    testWidgets('App bar background mode - visible', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  backgroundMode: LdAppBarBackgroundMode.visible,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar shadow mode - whenScrolled', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  shadowMode: LdAppBarShadowMode.whenScrolled,
                ),
              ],
              body: ListView(
                children: List.generate(
                  50,
                  (index) => ListTile(title: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar border mode - adaptive', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  borderMode: LdAppBarBorderMode.adaptive,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar attached mode - floating', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('Floating App Bar'),
                  attachedMode: LdAppBarAttachedMode.floating,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Floating App Bar'), findsOneWidget);
    });

    testWidgets('App bar with search config', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  searchConfig: LdSearchConfig(
                    onSearch: (value) {},
                  ),
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LdSearchInput), findsOneWidget);
    });

    testWidgets('App bar with bottom widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  bottom: const Text('Bottom Content'),
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom Content'), findsOneWidget);
    });

    testWidgets('App bar order affects stacking', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('First App Bar'),
                  order: 0,
                ),
                LdAppBar.top(
                  title: const Text('Second App Bar'),
                  order: 1,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('First App Bar'), findsOneWidget);
      expect(find.text('Second App Bar'), findsOneWidget);
    });

    testWidgets('App bar implyLeading - false', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  implyLeading: false,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not show back button
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
    });

    testWidgets('App bar with custom backgroundColor', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  backgroundColor: Colors.red,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar addContainer', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar.top(
                  title: const Text('App Bar'),
                  addContainer: true,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar position mode - adaptive on mobile', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.s, // Small size typically indicates mobile
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdAppBar(
                  title: const Text('Adaptive App Bar'),
                  positionMode: LdAppBarPositionMode.adaptive,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Adaptive App Bar'), findsOneWidget);
    });

    testWidgets(
      'App bar with multiple actions overflow',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: ldThemeWrapper(
              size: LdThemeSize.m,
              brightnessMode: LdThemeBrightnessMode.light,
              child: LdScaffold(
                appBars: [
                  LdAppBar.top(
                    title: const Text('App Bar'),
                    actions: List.generate(
                      10,
                      (index) => LdAppBarAction(
                        onPressed: () {},
                        child: Text('Action $index'),
                      ),
                    ),
                  ),
                ],
                body: const Center(child: Text('Body')),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Some actions should overflow to menu
        expect(find.text('App Bar'), findsOneWidget);
      },
    );
  });
}
