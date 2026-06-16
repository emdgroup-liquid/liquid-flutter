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

/// Wraps a widget with providers needed for action build/trigger tests.
Widget _wrapForActionBuild<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required TestSortAndFilterState<T, IdType> shellState,
  required LdMonkeyActionLocation location,
  LdMonkeyEffectiveLayoutMode layoutMode = LdMonkeyEffectiveLayoutMode.master,
  LdMonkeySelection<T, IdType>? selection,
  List<LdMonkeyAction<T, IdType>> actions = const [],
}) {
  selection ??= LdMonkeySelection<T, IdType>(
    selection: shellState.currentSelection,
    viewing: shellState.currentViewing,
    showSelectionControls: shellState.currentShowSelectionControls,
  );
  return Provider<LdMonkeyActionScope<T, IdType>>(
    create: (_) => LdMonkeyActionScope<T, IdType>(),
    child: ListenableProvider<LdRepository<T, IdType>>.value(
      value: repository,
      child: Provider<LdMonkeyRouterController<T, IdType>>.value(
        value: shellState.controllerDelegate,
        child: Provider<LdMonkeySelection<T, IdType>>.value(
          value: selection,
          child: Provider<LdMonkeyActionLocation>.value(
            value: location,
            child: Provider<LdMonkeyEffectiveLayoutMode>.value(
              value: layoutMode,
              child: LdMonkeyActionHost<T, IdType>(
                actions: actions,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Wraps a widget with providers needed for keyboard shortcut tests.
Widget _wrapForShortcuts<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required TestSortAndFilterState<T, IdType> shellState,
  required LdMonkeySelection<T, IdType> selection,
  LdMonkeyActionLocation location = LdMonkeyActionLocation.masterAppBar,
  LdMonkeyEffectiveLayoutMode layoutMode = LdMonkeyEffectiveLayoutMode.master,
}) {
  return ListenableProvider<LdRepository<T, IdType>>.value(
    value: repository,
    child: Provider<LdMonkeyActionScope<T, IdType>>(
      create: (_) => LdMonkeyActionScope<T, IdType>(),
      child: Provider<LdMonkeyRouterController<T, IdType>>.value(
        value: shellState.controllerDelegate,
        child: Provider<LdMonkeySelection<T, IdType>>.value(
          value: selection,
          child: Provider<LdMonkeyActionLocation>.value(
            value: location,
            child: Provider<LdMonkeyEffectiveLayoutMode>.value(
              value: layoutMode,
              child: Builder(
                builder: (context) {
                  LdMonkeyActionScope.of<T, IdType>(context).appContext = context;
                  return child;
                },
              ),
            ),
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {},
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
          builder: (ctx, trigger) => const Text('Test Action'),
          onTrigger: (ctx) async {},
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterAppBar,
                child: Builder(
                  builder: (context) => action.build(context),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Test Action'), findsOneWidget);
      });

      testWidgets('onShortcutPressed calls onTrigger', (WidgetTester tester) async {
        var called = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {
            called = true;
          },
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        await tester.pumpWidget(
          MaterialApp(
            home: _wrapForActionBuild(
              repository: repository,
              shellState: shellState,
              location: LdMonkeyActionLocation.masterAppBar,
              child: Builder(
                builder: (context) {
                  action.onShortcutPressed(context, LdMonkeyActionScope.of(context));
                  return Container();
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(called, isTrue);
      });
    });

    group('LdMonkeySubmitAction', () {
      testWidgets('buildTrigger renders submit button', (WidgetTester tester) async {
        final action = LdMonkeySubmitAction<TestItem, int, String>(
          id: 'test-submit',
          visibility: const {},
          tooltip: (_) => 'Submit',
          submitConfig: (_) => const LdMonkeySubmitConfig(),
          onSubmit: (ctx) async => 'result',
          child: const Text('Submit'),
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: LdScaffold(
                body: _wrapForActionBuild(
                  repository: repository,
                  shellState: shellState,
                  location: LdMonkeyActionLocation.masterAppBar,
                  actions: [action],
                  child: Builder(
                    builder: (context) => action.build(context),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Submit'), findsOneWidget);
      });
    });

    group('Keyboard Shortcuts', () {
      testWidgets('LdMonkeyMultiShortcuts applies shortcuts when multiple items selected',
          (WidgetTester tester) async {
        var shortcutPressed = false;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (ctx, trigger) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onTrigger: (ctx) async {
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
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapForShortcuts(
            repository: repository,
            shellState: shellState,
            selection: selection,
            child: LdMonkeyMultiShortcuts<TestItem, int>(
              actions: [action],
              child: Focus(
                focusNode: focusNode,
                child: const SizedBox(),
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
          builder: (ctx, trigger) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onTrigger: (ctx) async {
            shortcutPressed = true;
          },
        );

        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapForShortcuts(
            repository: repository,
            shellState: shellState,
            selection: selection,
            child: LdMonkeyMultiShortcuts<TestItem, int>(
              actions: [action],
              child: const SizedBox(),
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
          builder: (ctx, trigger) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onTrigger: (ctx) async {
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
        final repository = createTestRepository();
        await tester.pumpWidget(
          _wrapForShortcuts(
            repository: repository,
            shellState: shellState,
            selection: selection,
            child: LdMonkeySingleShortcuts<TestItem, int>(
              actions: [action],
              item: 1,
              child: Focus(
                focusNode: focusNode,
                child: const SizedBox(),
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
          builder: (ctx, trigger) => Container(),
          shortcutActivators: {
            const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          onTrigger: (ctx) async {
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
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapForShortcuts(
            repository: repository,
            shellState: shellState,
            selection: selection,
            child: LdMonkeySingleShortcuts<TestItem, int>(
              actions: [action],
              item: 1,
              child: Focus(
                focusNode: focusNode,
                child: const SizedBox(),
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

    group('LdMonkeyActionContext', () {
      testWidgets('of() uses adaptive selection for app bar location', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: _wrapForActionBuild(
              repository: repository,
              shellState: shellState,
              location: LdMonkeyActionLocation.masterAppBar,
              selection: selection,
              child: Builder(
                builder: (context) {
                  final scope = LdMonkeyActionScope.of<TestItem, int>(context);
                  scope.appContext = context;
                  final ctx = LdMonkeyActionContext.of<TestItem, int>(
                    context,
                    appContext: context,
                  );
                  expect(ctx.selectedIds, {1, 2});
                  expect(ctx.location, LdMonkeyActionLocation.masterAppBar);
                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('of() uses item-scoped selection from context menu override', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        // Context menu overrides selection to the right-clicked item when it is not selected.
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {3},
          viewing: {},
          showSelectionControls: false,
        );
        final item = LdPaginatorItem<TestItem>(
          value: createTestItem(3),
          state: LdPaginatorItemState.loaded,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: _wrapForActionBuild(
              repository: repository,
              shellState: shellState,
              location: LdMonkeyActionLocation.context,
              selection: selection,
              child: Provider<LdPaginatorItem<TestItem>>.value(
                value: item,
                child: Builder(
                  builder: (context) {
                    final scope = LdMonkeyActionScope.of<TestItem, int>(context);
                    scope.appContext = context;
                    final ctx = LdMonkeyActionContext.of<TestItem, int>(
                      context,
                      appContext: context,
                    );
                    expect(ctx.selectedIds, {3});
                    expect(ctx.contextItem, item);
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );
      });

      testWidgets('trigger callback passes fresh snapshot at press time', (WidgetTester tester) async {
        Set<int>? triggerSelectedIds;
        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (ctx, trigger) => LdAppBarAction(
            onPressed: trigger,
            child: const Text('Press'),
          ),
          onTrigger: (ctx) async {
            triggerSelectedIds = ctx.selectedIds;
          },
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterAppBar,
                selection: selection,
                child: Builder(
                  builder: (context) => action.build(context),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Press'));
        await tester.pumpAndSettle();

        expect(triggerSelectedIds, {1});
      });

      testWidgets('onTrigger reads app provider from ctx.appContext', (WidgetTester tester) async {
        const marker = 'app-provider-marker';
        var readValue = '';

        final action = LdMonkeyBareChildAction<TestItem, int>(
          visibility: const {},
          builder: (ctx, trigger) => Container(),
          onTrigger: (ctx) async {
            readValue = ctx.appContext.read<String>();
          },
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<String>.value(
              value: marker,
              child: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterAppBar,
                child: Builder(
                  builder: (context) {
                    action.onShortcutPressed(context, LdMonkeyActionScope.of(context));
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(readValue, marker);
      });
    });

    group('Built-in Actions', () {
      testWidgets('toggleFilters() creates filter toggle action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        final action = showFilterContextMenu<TestItem, int>();

        await tester.pumpWidget(
          wrapMonkeyFilterTestContext<TestItem, int>(
            repository: repository,
            shellState: shellState,
            child: _wrapForActionBuild<TestItem, int>(
              repository: repository,
              shellState: shellState,
              location: LdMonkeyActionLocation.masterAppBar,
              child: Builder(
                builder: (context) => action.build(context),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdContextMenu), findsOneWidget);
      });

      testWidgets('showSelectionControlsAction() creates selection controls action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();

        final action = showSelectionControlsAction<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterAppBar,
                child: Builder(
                  builder: (context) => action.build(context),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('show_selection_controls')), findsOneWidget);
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
              home: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterSecondary,
                selection: selection,
                child: Builder(
                  builder: (context) => action.build(context),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('show_selection')), findsOneWidget);
      });

      testWidgets('deleteAction() creates delete action', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {1},
          showSelectionControls: false,
        );

        final action = deleteAction<TestItem, int>();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: LdScaffold(
                body: _wrapForActionBuild(
                  repository: repository,
                  shellState: shellState,
                  location: LdMonkeyActionLocation.detailAppBar,
                  selection: selection,
                  actions: [action],
                  child: Builder(
                    builder: (context) => action.build(context),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Delete 1 item'), findsOneWidget);
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
              home: _wrapForActionBuild(
                repository: repository,
                shellState: shellState,
                location: LdMonkeyActionLocation.masterSecondary,
                selection: selection,
                child: Builder(
                  builder: (context) => action.build(context),
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
