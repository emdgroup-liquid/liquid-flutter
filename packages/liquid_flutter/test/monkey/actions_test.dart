import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

/// Wraps a widget with the minimal providers needed for action visibility
/// tests: repository, router-controller, selection, location, layout mode.
Widget _wrapForVisibility<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required TestSortAndFilterState<T, IdType> shellState,
  required LdMonkeyActionLocation location,
  LdMonkeyEffectiveLayoutMode layoutMode = LdMonkeyEffectiveLayoutMode.master,
  LdMonkeySelection<T, IdType>? selection,
}) {
  selection ??= LdMonkeySelection<T, IdType>(
    selection: shellState.currentSelection,
    viewing: shellState.currentViewing,
    showSelectionControls: shellState.currentShowSelectionControls,
  );
  return ListenableProvider<LdRepository<T, IdType>>.value(
    value: repository,
    child: Provider<LdMonkeyRouterController<T, IdType>>.value(
      value: shellState.controllerDelegate,
      child: Provider<LdMonkeySelection<T, IdType>>.value(
        value: selection,
        child: Provider<LdMonkeyActionLocation>.value(
          value: location,
          child: Provider<LdMonkeyEffectiveLayoutMode>.value(
            value: layoutMode,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('LdMonkeyAction Tests', () {
    group('Action Visibility', () {
      testWidgets('isVisible returns false when no visibility matches location', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.detailAppBar,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible returns true when visibility matches', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects minSelectionCount', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            selection: selection,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects maxSelectionCount', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2, 3},
          viewing: {},
          showSelectionControls: false,
        );

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            selection: selection,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects layoutModes', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            layoutMode: LdMonkeyEffectiveLayoutMode.master,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects visibleWhenShowingSelectionControls', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: true,
        );

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
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            selection: selection,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects custom isVisible function returning false', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              isVisible: (context) => false,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('isVisible respects custom isVisible function returning true', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              minSelectionCount: 0,
              isVisible: (context) => true,
            ),
          },
          builder: (context) => Container(),
          onShortcutTrigger: (context) async {},
        );

        await tester.pumpWidget(
          _wrapForVisibility(
            repository: repository,
            shellState: shellState,
            location: LdMonkeyActionLocation.masterAppBar,
            child: Builder(
              builder: (context) {
                expect(action.isVisible(context), isTrue);
                return Container();
              },
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
          tooltip: (_) => 'Submit',
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
      testWidgets('LdMonkeyMultiShortcuts applies shortcuts when multiple items selected',
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

        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {},
          showSelectionControls: false,
        );
        final focusNode = FocusNode();

        await tester.pumpWidget(
          Provider<LdMonkeyRouterController<TestItem, int>>.value(
            value: shellState.controllerDelegate,
            child: Provider<LdMonkeySelection<TestItem, int>>.value(
              value: selection,
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

        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          Provider<LdMonkeyRouterController<TestItem, int>>.value(
            value: shellState.controllerDelegate,
            child: Provider<LdMonkeySelection<TestItem, int>>.value(
              value: selection,
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

        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );
        final focusNode = FocusNode();
        await tester.pumpWidget(
          Provider<LdMonkeyRouterController<TestItem, int>>.value(
            value: shellState.controllerDelegate,
            child: Provider<LdMonkeySelection<TestItem, int>>.value(
              value: selection,
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

        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {},
          showSelectionControls: false,
        );
        final focusNode = FocusNode();

        await tester.pumpWidget(
          Provider<LdMonkeyRouterController<TestItem, int>>.value(
            value: shellState.controllerDelegate,
            child: Provider<LdMonkeySelection<TestItem, int>>.value(
              value: selection,
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
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final action = showFilterContextMenu<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdRepository<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                  value: shellState.controllerDelegate,
                  child: Provider<LdMonkeySortAndFilterState<TestItem, int>>.value(
                    value: shellState.state,
                    child: Provider<LdMonkeySelection<TestItem, int>>.value(
                      value: selection,
                      child: Provider<LdMonkeyActionLocation>.value(
                        value: LdMonkeyActionLocation.masterAppBar,
                        child: Provider<LdMonkeyEffectiveLayoutMode>.value(
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
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdContextMenu), findsOneWidget);
      });

      testWidgets('toggleSelectionControls() creates selection controls toggle action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final action = toggleSelectionControls<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdRepository<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                  value: shellState.controllerDelegate,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: selection,
                    child: Provider<LdMonkeyActionLocation>.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider<LdMonkeyEffectiveLayoutMode>.value(
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
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {},
          showSelectionControls: false,
        );

        final action = showSelection<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdRepository<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                  value: shellState.controllerDelegate,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: selection,
                    child: Provider<LdMonkeyActionLocation>.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider<LdMonkeyEffectiveLayoutMode>.value(
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
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {1, 2},
          showSelectionControls: false,
        );

        final action = showSelection<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdRepository<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                  value: shellState.controllerDelegate,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: selection,
                    child: Provider<LdMonkeyActionLocation>.value(
                      value: LdMonkeyActionLocation.masterAppBar,
                      child: Provider<LdMonkeyEffectiveLayoutMode>.value(
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
        final shellState = TestSortAndFilterState<TestItem, int>();
        final item = LdPaginatorItem<TestItem>(
          value: createTestItem(1),
          state: LdPaginatorItemState.loaded,
        );
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdRepository<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                  value: shellState.controllerDelegate,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: selection,
                    child: Provider<LdMonkeyEffectiveLayoutMode>.value(
                      value: LdMonkeyEffectiveLayoutMode.master,
                      child: Provider<List<LdMonkeyAction<TestItem, int>>>.value(
                        value: const [],
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
