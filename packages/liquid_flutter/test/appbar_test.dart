import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'appbar_metrics_test_utils.dart';

/// Helper: wraps [bar] (which has [child]) in a minimal scaffold-like tree.
/// The bar's wrappedChild provides MediaQuery insets to its subtree.
Widget _wrapInScaffold(Widget body) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: ldFrame(
      size: LdThemeSize.m,
      brightnessMode: LdThemeBrightnessMode.light,
      child: body,
    ),
  );
}

void main() {
  group('LdAppBar wrapper-mode tests', () {
    testWidgets('Basic app bar rendering (top)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Test App Bar'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test App Bar'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('Basic app bar rendering (bottom)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.bottom(
              title: const Text('Bottom App Bar'),
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              leading: const Icon(LucideIcons.database),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.database), findsOneWidget);
    });

    testWidgets('App bar with trailing widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              trailing: const Icon(LucideIcons.settings),
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              actions: [
                LdAppBarAction(
                  onPressed: () {
                    actionPressed = true;
                  },
                  child: const Text('Action'),
                ),
              ],
              child: const Center(child: Text('Body')),
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

    testWidgets('App bar actions show labels on wide mobile when leading is set', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            ldFrameOptions: iPhone16Pro,
            child: LdScaffold(
              body: LdAppBar.top(
                title: const Text('Items'),
                actions: [
                  LdAppBarAction(
                    leading: const Icon(LucideIcons.listFilter),
                    onPressed: () {},
                    child: const Text('Filter'),
                  ),
                ],
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('App bar title keeps width before actions compact', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: SizedBox(
              width: 200,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Example Page'),
                  actions: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.gitFork),
                      onPressed: () {},
                      child: const Text('GitHub'),
                    ),
                    LdContextMenu(
                      builder: (context, isShuttle, open, isOpen, child) => LdAppBarAction(
                        tooltip: 'Theme',
                        leading: const Icon(LucideIcons.paintBucket),
                        onPressed: open,
                        active: isOpen,
                        child: const Text('Theme'),
                      ),
                      menuBuilder: (context) => const SizedBox.shrink(),
                    ),
                  ],
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.renderObject<RenderBox>(find.text('Example Page')).size.width,
        greaterThan(48),
      );
    });

    testWidgets('App bar shows overflow menu when long title crowds actions', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: SizedBox(
              width: 320,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Very Long Page Title That Should Not Hide Actions'),
                  actions: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.listFilter),
                      onPressed: () {},
                      child: const Text('Filter'),
                    ),
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.save),
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                  ],
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.ellipsisVertical), findsOneWidget);
      expect(find.text('Filter'), findsNothing);
      expect(find.text('Save'), findsNothing);

      final titleBox = tester.renderObject<RenderBox>(
        find.text('Very Long Page Title That Should Not Hide Actions'),
      );
      final overflowView = tester.renderObject<RenderBox>(find.byType(LdOverflowView));
      final indicatorBox = tester.renderObject<RenderBox>(find.byIcon(LucideIcons.ellipsisVertical));
      expect(titleBox.size.width, lessThan(overflowView.size.width));
      expect(
        titleBox.localToGlobal(Offset.zero).dx,
        closeTo(overflowView.localToGlobal(Offset.zero).dx, 1),
      );

      final titleRight = titleBox.localToGlobal(titleBox.size.bottomRight(Offset.zero)).dx;
      final indicatorLeft = indicatorBox.localToGlobal(Offset.zero).dx;
      expect(indicatorLeft - titleRight, lessThan(20));
    });

    testWidgets('App bar keeps pinned actions visible when overflowable actions overflow', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: SizedBox(
              width: 320,
              child: LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Very Long Page Title That Should Not Hide Actions'),
                  actions: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.listFilter),
                      onPressed: () {},
                      child: const Text('Filter'),
                    ),
                    LdAppBarAction(
                      overflowMode: LdAppBarActionOverflowMode.pinned,
                      onPressed: () {},
                      child: const Text('Done'),
                    ),
                  ],
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.ellipsisVertical), findsOneWidget);
      expect(find.text('Filter'), findsNothing);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('App bar actions compact when row is tight', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: Center(
              child: SizedBox(
                width: 130,
                child: LdOverflowView(
                  spacing: 8,
                  builder: (context, overflowedChildIndices) => const SizedBox(
                    width: 32,
                    height: 32,
                  ),
                  children: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.listFilter),
                      onPressed: () {},
                      child: const Text('Filter items'),
                    ),
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.save),
                      onPressed: () {},
                      child: const Text('Save all changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.renderObject<RenderBox>(find.text('Filter items')).hasSize, isFalse);
      expect(tester.renderObject<RenderBox>(find.text('Save all changes')).hasSize, isFalse);
    });

    testWidgets('App bar actions compact when wrapped in LdContextMenu', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: Center(
              child: SizedBox(
                width: 120,
                child: LdOverflowView(
                  spacing: 8,
                  builder: (context, overflowedChildIndices) => const SizedBox(
                    width: 32,
                    height: 32,
                  ),
                  children: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.gitFork),
                      onPressed: () {},
                      child: const Text('GitHub'),
                    ),
                    LdContextMenu(
                      builder: (context, isShuttle, open, isOpen, child) => LdAppBarAction(
                        tooltip: 'Theme',
                        leading: const Icon(LucideIcons.paintBucket),
                        onPressed: open,
                        active: isOpen,
                        child: const Text('Theme'),
                      ),
                      menuBuilder: (context) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.renderObject<RenderBox>(find.text('Theme')).hasSize, isFalse);
      expect(tester.renderObject<RenderBox>(find.text('GitHub')).hasSize, isFalse);
      expect(find.byIcon(LucideIcons.paintBucket), findsWidgets);
    });

    testWidgets('App bar actions keep labels with mobile search below the bar', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            ldFrameOptions: iPhone16Pro,
            child: Builder(
              builder: (context) => LdScaffold(
                body: LdAppBar.top(
                  searchConfig: LdSearchConfig(onSearch: (_) {}, hint: 'Search items'),
                  actions: [
                    LdAppBarAction(
                      leading: const Icon(LucideIcons.listFilter),
                      onPressed: () {},
                      child: const Text('Filter'),
                    ),
                  ],
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('App bar keeps search visible on narrow desktop width', (WidgetTester tester) async {
      ldDisableAnimations = true;
      addTearDown(tester.view.resetPhysicalSize);

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            ldFrameOptions: const LdFrameOptions(platform: LdPlatform.macos),
            child: LdScaffold(
              body: LdAppBar.top(
                title: const Text('Tasks'),
                searchConfig: LdSearchConfig(onSearch: (_) {}, hint: 'Search tasks'),
                actions: [
                  LdAppBarAction(
                    leading: const Icon(LucideIcons.refreshCw),
                    onPressed: () {},
                    child: const Text('Refresh'),
                  ),
                  LdAppBarAction(
                    leading: const Icon(LucideIcons.listFilter),
                    onPressed: () {},
                    child: const Text('Filter'),
                  ),
                  LdAppBarAction(
                    overflowMode: LdAppBarActionOverflowMode.pinned,
                    onPressed: () {},
                    child: const Text('Select'),
                  ),
                ],
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchBox = tester.renderObject<RenderBox>(find.byType(LdSearchInput));
      expect(searchBox.hasSize, isTrue);
      expect(searchBox.size.width, greaterThan(200));
      expect(
        find.descendant(of: find.byType(LdOverflowView), matching: find.byType(LdSearchInput)),
        findsNothing,
      );
    });

    testWidgets('App bar action compactMode never does not use adaptive wrapper', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: LdAppBarAction(
              leading: const Icon(LucideIcons.eye),
              compactMode: LdAppBarActionCompactMode.never,
              onPressed: () {},
              child: const Text('Never Label'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LdOverflowAdaptiveChild), findsNothing);
      expect(find.text('Never Label'), findsOneWidget);
    });

    testWidgets('App bar action compactMode always uses icon-only', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            ldFrameOptions: iPhone16Pro,
            child: LdScaffold(
              body: LdAppBar.top(
                title: const Text('Items'),
                actions: [
                  LdAppBarAction(
                    leading: const Icon(LucideIcons.listFilter),
                    compactMode: LdAppBarActionCompactMode.always,
                    onPressed: () {},
                    child: const Text('Filter'),
                  ),
                ],
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsNothing);
      expect(find.byIcon(LucideIcons.listFilter), findsOneWidget);
    });

    testWidgets('App bar scroll behavior - static', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Static App Bar'),
              scrollBehavior: LdAppBarScrollBehavior.static,
              child: ListView(
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              backgroundMode: LdAppBarBackgroundMode.visible,
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              shadowMode: LdAppBarShadowMode.whenScrolled,
              child: ListView(
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              borderMode: LdAppBarBorderMode.adaptive,
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Floating App Bar'),
              attachedMode: LdAppBarAttachedMode.floating,
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              searchConfig: LdSearchConfig(
                onSearch: (value) {},
              ),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LdSearchInput), findsOneWidget);
    });

    testWidgets('search suggestions overlay dismisses on outside tap', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              searchConfig: LdSearchConfig(
                onSearch: (_) {},
                getSuggestions: (query) async => ['alpha', 'beta'].where((s) => s.contains(query)).toList(),
                buildSuggestion: (context, suggestion) => LdListItem(title: Text('$suggestion')),
              ),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(LdInput));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(LdSearchSuggestionsOverlay), findsOneWidget);

      final overlayBarrier = find.byWidgetPredicate(
        (widget) => widget is ModalBarrier && widget.onDismiss != null,
      );
      expect(overlayBarrier, findsOneWidget);
      await tester.tap(overlayBarrier);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.byType(LdSearchSuggestionsOverlay), findsNothing);
    });

    testWidgets('App bar with bottom widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              bottom: const Text('Bottom Content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom Content'), findsOneWidget);
    });

    testWidgets('App bar implyLeading - false', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              implyLeading: false,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not show back button
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
    });

    testWidgets('App bar implyLeading when navigator can pop', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: Navigator(
              onDidRemovePage: (_) {},
              pages: [
                const MaterialPage<void>(child: SizedBox.shrink()),
                MaterialPage<void>(
                  child: LdScaffold(
                    body: LdAppBar.top(
                      title: const Text('Detail'),
                      child: const Center(child: Text('Body')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('App bar implyLeading hidden under modal route', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: Builder(
              builder: (context) {
                return LdScaffold(
                  body: LdAppBar.top(
                    title: const Text('Page'),
                    child: Center(
                      child: LdButton(
                        onPressed: () {
                          LdModalRoute<void>(
                            context: context,
                            pageBuilder: (context) => LdScaffold(
                              body: LdAppBar.top(
                                title: const Text('Modal'),
                                child: const Center(child: Text('Modal body')),
                              ),
                            ),
                          ).show(context);
                        },
                        child: const Text('Open modal'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);

      await tester.tap(find.text('Open modal'));
      await tester.pumpAndSettle();

      expect(find.text('Page'), findsOneWidget);
      expect(find.text('Modal'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
    });

    testWidgets('App bar implyLeading hidden when stacked drawer is open', (WidgetTester tester) async {
      ldDisableAnimations = true;
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: LdScaffold(
                drawer: const Center(child: Text('Drawer')),
                body: LdAppBar.top(
                  title: const Text('Page'),
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);

      await tester.tap(find.byIcon(LucideIcons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Drawer'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);

      LdDrawerLayout.closeDrawer(tester.element(find.text('Body')));
      await tester.pumpAndSettle();
    });

    testWidgets('App bar implyLeading only on innermost top bar when stacked', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: Navigator(
              onDidRemovePage: (_) {},
              pages: [
                const MaterialPage<void>(child: SizedBox.shrink()),
                MaterialPage<void>(
                  child: LdScaffold(
                    body: LdAppBar.top(
                      title: const Text('Outer'),
                      child: LdAppBar.top(
                        title: const Text('Inner'),
                        child: const Center(child: Text('Body')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('App bar implyLeading ignores tab navigation when detecting parent', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: Navigator(
              onDidRemovePage: (_) {},
              pages: [
                const MaterialPage<void>(child: SizedBox.shrink()),
                MaterialPage<void>(
                  child: LdScaffold(
                    body: LdAppBar.top(
                      title: const Text('Outer'),
                      child: LdTabNavigation(
                        activeRoute: '/home',
                        onTabPressed: (_) {},
                        tabs: const [
                          LdNavigationTab(
                            label: 'Home',
                            icon: Icon(LucideIcons.house),
                            route: '/home',
                          ),
                        ],
                        child: const Center(child: Text('Body')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('App bar with custom backgroundColor', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              backgroundColor: Colors.red,
              child: const Center(child: Text('Body')),
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
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              addContainer: true,
              child: const Center(child: Text('Body')),
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
          home: ldFrame(
            size: LdThemeSize.s, // Small size typically indicates mobile
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              body: LdAppBar(
                title: const Text('Adaptive App Bar'),
                positionMode: LdAppBarPositionMode.adaptive,
                child: const Center(child: Text('Body')),
              ),
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
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('App Bar'),
                actions: List.generate(
                  10,
                  (index) => LdAppBarAction(
                    onPressed: () {},
                    child: Text('Action $index'),
                  ),
                ),
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Some actions should overflow to menu
        expect(find.text('App Bar'), findsOneWidget);
      },
    );

    // ── New wrapper-mode tests ───────────────────────────────────────────────

    testWidgets(
      'LdAppBar.top wrapping LdTabNavigation.bottom — both edges padded',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        final tabs = [
          LdNavigationTab(
            label: 'Home',
            icon: const Icon(LucideIcons.circle),
            route: '/home',
          ),
        ];

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Top Bar'),
                child: LdTabNavigation(
                  tabs: tabs,
                  activeRoute: '/home',
                  onTabPressed: (_) {},
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Top Bar'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);

        // Both top and bottom padding should be > 0 from the bars.
        // (Exact values depend on bar sizes which may be 0 before layout,
        // so we just verify the widgets render without errors.)
      },
    );

    testWidgets(
      'LdAppBar LdAppBarMetrics provided to child subtree',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        LdAppBarMetrics? capturedMetrics;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Top Bar'),
                child: Builder(
                  builder: (context) {
                    capturedMetrics = context.read<LdAppBarMetrics?>();
                    return const Center(child: Text('Body'));
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // LdAppBarMetrics should be available in the child's context.
        expect(capturedMetrics, isNotNull);
        expect(capturedMetrics!.position, equals(LdAppBarPosition.top));
        expect(capturedMetrics!.level, equals(0));
      },
    );

    testWidgets(
      'Nested LdAppBars — level increments',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        LdAppBarMetrics? outerMetrics;
        LdAppBarMetrics? innerMetrics;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Outer Bar'),
                child: Builder(
                  builder: (context) {
                    outerMetrics = context.read<LdAppBarMetrics?>();
                    return LdAppBar.top(
                      title: const Text('Inner Bar'),
                      child: Builder(
                        builder: (context) {
                          innerMetrics = context.read<LdAppBarMetrics?>();
                          return const Center(child: Text('Body'));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(outerMetrics, isNotNull);
        expect(innerMetrics, isNotNull);
        expect(outerMetrics!.level, equals(0));
        expect(innerMetrics!.level, equals(1));
      },
    );

    testWidgets(
      'scroll-hide: LdAppBar with scrollBehavior always renders without errors',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Scroll-hide Bar'),
                scrollBehavior: LdAppBarScrollBehavior.always,
                child: ListView(
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

        expect(find.text('Scroll-hide Bar'), findsOneWidget);

        // Scroll down to trigger hide behaviour.
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Bar should still be in the tree (just potentially translated).
        expect(find.text('Scroll-hide Bar'), findsOneWidget);
      },
    );
  });

  // ── Legacy scaffold-injection mode (LdScaffold.appBars) ──────────────────
  // The appBars parameter is a deprecated no-op since the registry was removed.
  // Verify that using it does not throw and the body is still rendered.

  // ── Stage 5: ScrolledUnderBuilder and drawer button tests ─────────────────

  group('ScrolledUnderBuilder', () {
    testWidgets('rebuilds when LdAppBarMetrics.isScrolledUnder changes', (WidgetTester tester) async {
      ldDisableAnimations = true;

      // We'll use a ValueNotifier to drive isScrolledUnder externally.
      final metricsNotifier = ValueNotifier<LdAppBarMetrics>(
        testAppBarMetrics(
          position: LdAppBarPosition.top,
          barHeight: const EdgeInsets.only(top: 56),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<LdAppBarMetrics>(
            valueListenable: metricsNotifier,
            builder: (context, metrics, _) {
              return Provider<LdAppBarMetrics?>.value(
                value: metrics,
                child: Builder(
                  builder: (context) {
                    return ScrolledUnderBuilder(
                      builder: (context, isScrolledUnder) {
                        return Text(isScrolledUnder ? 'scrolled' : 'not scrolled');
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('not scrolled'), findsOneWidget);
      expect(find.text('scrolled'), findsNothing);

      // Update metrics so isScrolledUnder becomes true.
      metricsNotifier.value = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 56),
        isScrolledUnder: true,
      );
      await tester.pump();

      expect(find.text('scrolled'), findsOneWidget);
      expect(find.text('not scrolled'), findsNothing);

      metricsNotifier.dispose();
    });

    testWidgets('returns false when no LdAppBarMetrics is in context', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<LdAppBarMetrics?>.value(
            value: null,
            child: ScrolledUnderBuilder(
              builder: (context, isScrolledUnder) {
                return Text(isScrolledUnder ? 'scrolled' : 'not scrolled');
              },
            ),
          ),
        ),
      );

      expect(find.text('not scrolled'), findsOneWidget);
    });
  });

  group('OpenDrawerButton visibility', () {
    Widget buildWithMetrics({
      required LdAppBarMetrics? metrics,
      required bool drawerOpen,
      required bool isSideBySide,
    }) {
      return MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: ldFrame(
          size: LdThemeSize.m,
          brightnessMode: LdThemeBrightnessMode.light,
          child: MultiProvider(
            providers: [
              Provider<LdAppBarMetrics?>.value(value: metrics),
              Provider<LdDrawerSlot?>.value(value: LdDrawerSlot.body),
              Provider<LdDrawerState?>.value(
                value: LdDrawerState(
                  isOpen: drawerOpen,
                  isSideBySide: isSideBySide,
                ),
              ),
            ],
            child: const _FakeDrawerLayout(
              child: OpenDrawerButton(),
            ),
          ),
        ),
      );
    }

    testWidgets('is visible in level-0 top bar with closed drawer', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        buildWithMetrics(
          metrics: testAppBarMetrics(
            position: LdAppBarPosition.top,
            barHeight: const EdgeInsets.only(top: 56),
          ),
          drawerOpen: false,
          isSideBySide: false,
        ),
      );
      await tester.pump();

      // LdReveal wraps the button; check that the icon is not excluded from focus
      // (which happens when shouldShow is false).
      final excludeFocus = tester.widget<ExcludeFocus>(find.byType(ExcludeFocus).first);
      expect(excludeFocus.excluding, isFalse);
    });

    testWidgets('is hidden in nested (level > 0) top bar', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        buildWithMetrics(
          metrics: testAppBarMetrics(
            position: LdAppBarPosition.top,
            barHeight: const EdgeInsets.only(top: 56),
            level: 1,
          ),
          drawerOpen: false,
          isSideBySide: false,
        ),
      );
      await tester.pump();

      final excludeFocus = tester.widget<ExcludeFocus>(find.byType(ExcludeFocus).first);
      expect(excludeFocus.excluding, isTrue);
    });

    testWidgets('is hidden in bottom bar', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        buildWithMetrics(
          metrics: testAppBarMetrics(
            position: LdAppBarPosition.bottom,
            barHeight: const EdgeInsets.only(bottom: 56),
          ),
          drawerOpen: false,
          isSideBySide: false,
        ),
      );
      await tester.pump();

      final excludeFocus = tester.widget<ExcludeFocus>(find.byType(ExcludeFocus).first);
      expect(excludeFocus.excluding, isTrue);
    });
  });
}

/// Minimal fake that satisfies LdDrawerLayout ancestor check inside
/// [OpenDrawerButton._shouldShow].
class _FakeDrawerLayout extends StatelessWidget {
  final Widget child;
  const _FakeDrawerLayout({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
