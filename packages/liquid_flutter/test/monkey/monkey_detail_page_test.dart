import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

/// Wraps a widget with all providers required by [LdMonkeyDetailPage] and
/// [LdMonkeyAppBar]: repository, selection, layout mode, sort/filter state,
/// and actions list.
Widget _wrapDetail<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required LdMonkeySelection<T, IdType> selection,
  LdMonkeyEffectiveLayoutMode layoutMode = LdMonkeyEffectiveLayoutMode.detail,
  List<LdMonkeyAction<T, IdType>> actions = const [],
  Set<LdFilterOption<T, IdType>> filters = const {},
}) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: ListenableProvider<LdRepository<T, IdType>>.value(
        value: repository,
        child: Provider<LdMonkeySelection<T, IdType>>.value(
          value: selection,
          child: Provider<LdMonkeyEffectiveLayoutMode>.value(
            value: layoutMode,
            child: Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
              value: LdMonkeySortAndFilterState<T, IdType>(
                filters: filters,
                sortOptions: [],
              ),
              child: Provider<LdMonkeyActions<T, IdType>>.value(
                value: actions,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

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
      testWidgets('scrollable() factory creates scrollable detail view', (WidgetTester tester) async {
        final repository = createTestRepository(
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

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          _wrapDetail(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await _pumpStream(tester);
        expect(find.text('Detail: Item 1'), findsOneWidget);
        expect(find.text('Detail: Item 2'), findsOneWidget);
      });

      testWidgets('scrollable view renders multiple items', (WidgetTester tester) async {
        final repository = createTestRepository(
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

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          _wrapDetail(
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
        final repository = createTestRepository(
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

        final detailPage = LdMonkeyDetailPage<TestItem, int>.stacked(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          _wrapDetail(
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
        final repository = createTestRepository(
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
                home: ListenableProvider<LdRepository<TestItem, int>>.value(
                  value: repository,
                  child: Provider<LdMonkeySelection<TestItem, int>>.value(
                    value: currentSelection,
                    child: LdMonkeyStreamSelection<TestItem, int>(
                      builder: (context, items) => Column(
                        children: items.map((item) => Text(item.value?.name ?? '')).toList(),
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
        final repository = createTestRepository();
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
                child: Provider<LdMonkeySelection<TestItem, int>>.value(
                  value: selection,
                  child: LdMonkeyStreamSelection<TestItem, int>(
                    builder: (context, items) => Column(
                      children: items.map((item) => Text(item.value?.name ?? '')).toList(),
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
        final repository = createTestRepository();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          primaryAppBarConfig: LdAppBarConfig(title: const Text('Custom Primary App Bar')),
          body: Container(),
        );

        await tester.pumpWidget(
          _wrapDetail(
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
        final repository = createTestRepository();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          body: Container(),
        );

        await tester.pumpWidget(
          _wrapDetail(
            repository: repository,
            selection: selection,
            child: detailPage,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdMonkeyAppBar<TestItem, int>), findsWidgets);
      });

      testWidgets('uses custom secondaryAppBar when provided', (WidgetTester tester) async {
        final repository = createTestRepository();
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          secondaryAppBarConfig: LdAppBarConfig(title: const Text('Custom Secondary App Bar')),
          body: Container(),
        );

        await tester.pumpWidget(
          _wrapDetail(
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
        final repository = createTestRepository(
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

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        Widget buildTree() => _wrapDetail(
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
  });
}
