import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

/// Pump enough frames to flush async* stream delivery and setState rebuilds.
Future<void> _pumpStream(WidgetTester tester) async {
  // pump() flushes microtasks + renders 1 frame; repeat to catch setState chain.
  // async* generators deliver their first element after an await point, so we
  // need at least one pump() to allow the Dart event loop to run.
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  group('LdMonkeyDetailPage Tests', () {
    group('Scrollable View', () {
      testWidgets('scrollable() factory renders all viewing items', (WidgetTester tester) async {
        final repository = createTestListController(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {1, 2},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await _pumpStream(tester);
        expect(find.text('Detail: Item 1'), findsOneWidget);
        expect(find.text('Detail: Item 2'), findsOneWidget);
      });
    });

    group('Stacked View', () {
      testWidgets('stacked() factory creates stacked detail view', (WidgetTester tester) async {
        final repository = createTestListController(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {1, 2},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>.stacked(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await _pumpStream(tester);
        expect(find.text('Detail: Item 1'), findsOneWidget);
        expect(find.text('Detail: Item 2'), findsOneWidget);
      });
    });

    group('Stream Selection', () {
      testWidgets('LdMonkeyStreamSelection updates when viewing items change', (WidgetTester tester) async {
        final repository = createTestListController(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );

        var currentSelection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {1},
          showSelectionControls: false,
        );

        Widget buildTree() => LdThemeProvider(
              child: MaterialApp(
                localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                home: ListenableProvider<LdListController<TestItem, int>>.value(
                  value: repository,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: currentSelection,
                    child: LdMonkeyViewingBuilder<TestItem, int>(
                      buildItem: (context, item) => Text(item.value?.name ?? ''),
                      builder: (context, itemWidgets) => Column(
                        children: itemWidgets,
                      ),
                    ),
                  ),
                ),
              ),
            );

        await tester.pumpWidget(buildTree());
        await _pumpStream(tester);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsNothing);

        currentSelection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {2},
          showSelectionControls: false,
        );
        await tester.pumpWidget(buildTree());
        await _pumpStream(tester);

        expect(find.text('Item 1'), findsNothing);
        expect(find.text('Item 2'), findsOneWidget);
      });

      testWidgets('LdMonkeyStreamSelection handles empty viewing items', (WidgetTester tester) async {
        final repository = createTestListController();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider<LdListController<TestItem, int>>.value(
                value: repository,
                child: Provider<LdMonkeySelection<TestItem, int>>.value(
                  value: selection,
                  child: LdMonkeyViewingBuilder<TestItem, int>(
                    buildItem: (context, item) => Text(item.value?.name ?? ''),
                    builder: (context, itemWidgets) => Column(
                      children: itemWidgets,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await _pumpStream(tester);
        expect(find.byType(Column), findsOneWidget);
      });
    });

    group('App Bars', () {
      testWidgets('uses custom primaryAppBar when provided', (WidgetTester tester) async {
        final repository = createTestListController();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>(
          primaryAppBarConfig: LdAppBarConfig(title: const Text('Custom Primary App Bar')),
          child: Container(),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pumpAndSettle();
        final appBars = tester.widgetList<LdAppBarWidget>(find.byType(LdAppBarWidget));
        expect(
          appBars.any(
            (bar) => bar.title is Text && (bar.title! as Text).data == 'Custom Primary App Bar',
          ),
          isTrue,
        );
      });

      testWidgets('uses default LdMonkeyAppBar when primaryAppBar not provided', (WidgetTester tester) async {
        final repository = createTestListController();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>(
          child: Container(),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdMonkeyAppBar<TestItem, int>), findsWidgets);
      });

      testWidgets('secondary app bar does not inherit primary app bar title', (WidgetTester tester) async {
        final repository = createTestListController();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>(
          primaryAppBarConfig: LdAppBarConfig(title: const Text('Primary Only Title')),
          child: Container(),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Primary Only Title'), findsOneWidget);
      });

      testWidgets('uses custom secondaryAppBar when provided', (WidgetTester tester) async {
        final repository = createTestListController();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>(
          secondaryAppBarConfig: LdAppBarConfig(title: const Text('Custom Secondary App Bar')),
          child: Container(),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom Secondary App Bar'), findsOneWidget);
      });
    });

    group('Viewing Items Updates', () {
      testWidgets('detail view updates when viewing items change', (WidgetTester tester) async {
        final repository = createTestListController(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );

        var currentSelection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {1},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        Widget buildTree() => wrapMonkeyDetailPage(
              repository: repository,
              selection: currentSelection,
              child: detailPage,
            );

        await tester.pumpWidget(buildTree());
        await _pumpStream(tester);
        expect(find.text('Detail: Item 1'), findsOneWidget);

        currentSelection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {2},
          showSelectionControls: false,
        );

        await tester.pumpWidget(buildTree());
        await _pumpStream(tester);

        expect(find.text('Detail: Item 2'), findsOneWidget);
        expect(find.text('Detail: Item 1'), findsNothing);
      });
    });

    group('Missing item deep link', () {
      testWidgets('shows error view when viewing item cannot be loaded', (WidgetTester tester) async {
        final repository = createTestListController(
          getById: (context, id) async => throw StateError('No element'),
        );
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {99},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('retry-button')), findsOneWidget);
        expect(find.textContaining('could not be loaded'), findsOneWidget);
        expect(find.text('Detail:'), findsNothing);
      });

      testWidgets('shows loader while missing item is loading', (WidgetTester tester) async {
        final completer = Completer<TestItem>();
        final repository = createTestListController(
          getById: (context, id) => completer.future,
        );
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {99},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailAppBars<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          wrapMonkeyDetailPage(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(find.byType(LdLoader), findsWidgets);
        expect(find.textContaining('Loading item'), findsOneWidget);

        completer.complete(createTestItem(99, name: 'Loaded Item'));
        await tester.pumpAndSettle();

        expect(find.text('Detail: Loaded Item'), findsOneWidget);
      });
    });
  });
}
