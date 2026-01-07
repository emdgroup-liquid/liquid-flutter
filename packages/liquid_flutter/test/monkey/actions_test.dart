import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyAction Tests', () {
    group('Action Visibility', () {
      testWidgets('isVisible returns false when no visibility matches location', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        final selection = LdMonkeySelection<TestItem, int>(selection: {}, viewing: {});

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: selection,
                child: Provider.value(
                  value: LdMonkeyActionLocation.detailAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isFalse);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('isVisible returns true when visibility matches', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        final selection = LdMonkeySelection<TestItem, int>(selection: {}, viewing: {});

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: selection,
                child: Provider.value(
                  value: LdMonkeyActionLocation.masterAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isTrue);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('isVisible respects minSelectionCount', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1});

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 2,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: LdMonkeySelection<TestItem, int>(selection: {1}, viewing: {}),
                child: Provider.value(
                  value: LdMonkeyActionLocation.masterAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isFalse);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('isVisible respects maxSelectionCount', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1, 2, 3});

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              maxSelectionCount: 2,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: LdMonkeySelection<TestItem, int>(selection: {1, 2, 3}, viewing: {}),
                child: Provider.value(
                  value: LdMonkeyActionLocation.masterAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isFalse);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('isVisible respects layoutModes', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                child: Provider.value(
                  value: LdMonkeyActionLocation.masterAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isFalse);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('isVisible respects visibleWhenShowingSelectionControls', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setShowSelectionControls(true);

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              visibleWhenShowingSelectionControls: false,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: shellState,
              child: Provider.value(
                value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                child: Provider.value(
                  value: LdMonkeyActionLocation.masterAppBar,
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: Builder(
                      builder: (context) {
                        expect(action.isVisible(context), isFalse);
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });

    group('LdMonkeyBareChildAction', () {
      testWidgets('build() returns widget from builder', (WidgetTester tester) async {
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => const Text('Test Action'),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => action.build(context),
            ),
          ),
        );

        expect(find.text('Test Action'), findsOneWidget);
      });

      test('onShortcutPressed calls onShortcutTrigger', () async {
        var called = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {
            called = true;
          },
        );

        final context = MockBuildContext();
        await action.onShortcutPressed(context);

        expect(called, isTrue);
      });
    });

    group('LdMonkeySubmitAction', () {
      testWidgets('build() creates LdSubmit widget', (WidgetTester tester) async {
        final action = LdMonkeySubmitAction<TestItem, int, String>(
          visibility: const {},
          config: (context) => LdSubmitConfig(
            action: (_) async => 'result',
          ),
          child: const Text('Submit'),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: LdScaffold(
                body: Builder(
                  builder: (context) => action.build(context),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Submit'), findsOneWidget);
      });
    });

    group('Keyboard Shortcuts', () {
      testWidgets('LdMonkeyMultiShortcuts applies shortcuts when multiple items selected', (WidgetTester tester) async {
        var shortcutPressed = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onShortcutTrigger: (context) async {
            shortcutPressed = true;
          },
        );

        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1, 2});
        final focusNode = FocusNode();

        await tester.pumpWidget(
          ListenableProvider.value(
            value: shellState,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(selection: {1, 2}, viewing: {}),
              child: LdMonkeyMultiShortcuts<TestItem, int>(
                actions: [action],
                child: Focus(
                  focusNode: focusNode,
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
        await tester.pumpAndSettle();

        expect(shortcutPressed, isTrue);
      });

      testWidgets('LdMonkeyMultiShortcuts does not apply shortcuts when single item selected',
          (WidgetTester tester) async {
        var shortcutPressed = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onShortcutTrigger: (context) async {
            shortcutPressed = true;
          },
        );

        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1});

        await tester.pumpWidget(
          ListenableProvider.value(
            value: shellState,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(selection: {1}, viewing: {}),
              child: LdMonkeyMultiShortcuts<TestItem, int>(
                actions: [action],
                child: const SizedBox(),
              ),
            ),
          ),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
        await tester.pumpAndSettle();

        expect(shortcutPressed, isFalse);
      });

      testWidgets('LdMonkeySingleShortcuts applies shortcuts when single item selected', (WidgetTester tester) async {
        var shortcutPressed = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onShortcutTrigger: (context) async {
            shortcutPressed = true;
          },
        );

        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        final focusNode = FocusNode();
        await tester.pumpWidget(
          ListenableProvider.value(
            value: shellState,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
              child: LdMonkeySingleShortcuts<TestItem, int>(
                actions: [action],
                item: 1,
                child: Focus(
                  focusNode: focusNode,
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        );
        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
        await tester.pumpAndSettle();

        expect(shortcutPressed, isTrue);
      });

      testWidgets('LdMonkeySingleShortcuts does not apply shortcuts when multiple items selected',
          (WidgetTester tester) async {
        var shortcutPressed = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (context) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onShortcutTrigger: (context) async {
            shortcutPressed = true;
          },
        );

        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1, 2});
        final focusNode = FocusNode();

        await tester.pumpWidget(
          ListenableProvider.value(
            value: shellState,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(selection: {1, 2}, viewing: {}),
              child: LdMonkeySingleShortcuts<TestItem, int>(
                actions: [action],
                item: 1,
                child: Focus(
                  focusNode: focusNode,
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
        await tester.pumpAndSettle();

        expect(shortcutPressed, isFalse);
      });
    });

    group('Built-in Actions', () {
      testWidgets('toggleFilters() creates filter toggle action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final action = showFilterContextMenu<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
                  child: Provider.value(
                    value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                    child: Provider.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: Builder(
                          builder: (context) => action.build(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // Action should render
        expect(find.byType(LdContextMenu), findsOneWidget);
      });

      testWidgets('toggleSelectionControls() creates selection controls toggle action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final action = toggleSelectionControls<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
                  child: Provider.value(
                    value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                    child: Provider.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: Builder(
                          builder: (context) => action.build(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('toggle_selection_controls')), findsOneWidget);
      });

      testWidgets('showSelection() creates show selection action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1, 2});

        final action = showSelection<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
                  child: Provider.value(
                    value: LdMonkeySelection<TestItem, int>(selection: {1, 2}, viewing: {}),
                    child: Provider.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: Builder(
                          builder: (context) => action.build(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('show_selection')), findsOneWidget);
      });

      testWidgets('showSelection() hides when selection matches viewing', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setSelectedItems({1, 2});
        shellState.setViewingItems({1, 2});

        final action = showSelection<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
                  child: Provider.value(
                    value: LdMonkeySelection<TestItem, int>(selection: {1, 2}, viewing: {1, 2}),
                    child: Provider.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: Builder(
                          builder: (context) => action.build(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('show_selection')), findsNothing);
      });
    });

    group('LdMonkeyContextMenu', () {
      testWidgets('renders context menu widget', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        final item = LdPaginatorItem<TestItem>(
          value: createTestItem(1),
          state: LdPaginatorItemState.loaded,
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
                  child: Provider.value(
                    value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                    child: Provider.value(
                      value: LdMonkeyEffectiveLayoutMode.master,
                      child: Provider.value(
                        value: const <LdMonkeyAction<TestItem, int>>[],
                        child: LdMonkeyContextMenu<TestItem, int>(
                          item: item,
                          child: const Text('Child'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Child'), findsOneWidget);
        expect(find.byType(LdContextMenu), findsOneWidget);
      });
    });
  });
}
