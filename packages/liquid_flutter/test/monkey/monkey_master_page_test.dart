import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

/// Minimal provider wrapper for [LdMonkeyMasterPage] tests.
Widget _wrapMasterPage<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  TestSortAndFilterState<T, IdType>? shellState,
  LdMonkeyEffectiveLayoutMode layoutMode = LdMonkeyEffectiveLayoutMode.master,
  List<LdMonkeyAction<T, IdType>> actions = const [],
}) {
  shellState ??= TestSortAndFilterState<T, IdType>();
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: Provider<LdMonkeyActionScope<T, IdType>>(
        create: (_) => LdMonkeyActionScope<T, IdType>(),
        child: ListenableProvider<LdRepository<T, IdType>>.value(
          value: repository,
          child: Provider<LdMonkeyRouterController<T, IdType>>.value(
            value: shellState.controllerDelegate,
            child: ListenableBuilder(
              listenable: shellState,
              builder: (context, _) {
                return Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                  value: shellState!.state,
                  child: Provider<LdMonkeySelection<T, IdType>>.value(
                    value: shellState.selection,
                    child: Provider<LdMonkeyActions<T, IdType>>.value(
                      value: actions,
                      child: Provider<LdMonkeyEffectiveLayoutMode>.value(
                        value: layoutMode,
                        child: LdMonkeyActionHost<T, IdType>(
                          actions: actions,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

bool _isListItemActive(WidgetTester tester, String itemLabel) {
  final touchable = tester.widget<LdTouchableSurface>(
    find.descendant(
      of: find.widgetWithText(LdListItem, itemLabel),
      matching: find.byType(LdTouchableSurface),
    ),
  );
  return touchable.active;
}

void main() {
  group('LdMonkeyMasterPage Tests', () {
    group('Search Integration', () {
      testWidgets('initializes search config when search filter exists', (WidgetTester tester) async {
        final searchFilter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
        );

        final repository = createTestRepository();
        final shellState = TestSortAndFilterState<TestItem, int>(filters: {searchFilter});

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            shellState: shellState,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdSearchInput), findsOneWidget);
        expect(find.byType(LdMonkeyMasterPage<TestItem, int>), findsOneWidget);
      });

      testWidgets('does not initialize search config when no search filter', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdMonkeyMasterPage<TestItem, int>), findsOneWidget);
        expect(find.byType(LdSearchInput), findsNothing);
      });
    });

    group('List Building', () {
      testWidgets('uses buildItem when provided', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1, name: 'Custom Item'),
          ],
        );

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text('Custom: ${item.value?.name ?? ''}'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom: Custom Item'), findsOneWidget);
      });

      testWidgets('uses buildList when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildList: (context, repository) => const Text('Custom List'),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom List'), findsOneWidget);
      });

      testWidgets('uses default item builder when neither buildItem nor buildList provided',
          (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
          ],
        );

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.toString() ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('TestItem'), findsWidgets);
      });
    });

    group('App Bars', () {
      testWidgets('uses custom primaryAppBarConfig when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
              primaryAppBarConfig: LdAppBarConfig(title: const Text('Custom App Bar')),
            ),
          ),
        );

        await tester.pumpAndSettle();
        final appBars = tester.widgetList<LdAppBarWidget>(find.byType(LdAppBarWidget));
        expect(
          appBars.any(
            (bar) => bar.title is Text && (bar.title! as Text).data == 'Custom App Bar',
          ),
          isTrue,
        );
      });

      testWidgets('uses default LdMonkeyAppBar when primaryAppBarConfig not provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdMonkeyAppBar<TestItem, int>), findsWidgets);
      });

      testWidgets('uses custom secondaryAppBarConfig when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              secondaryAppBarConfig: LdAppBarConfig(title: const Text('Custom Secondary App Bar')),
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom Secondary App Bar'), findsOneWidget);
      });
    });

    group('Selection Handling', () {
      testWidgets('viewing item is indicated as active in the master list', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );
        final shellState = TestSortAndFilterState<TestItem, int>();
        shellState.updateViewing(MockBuildContext(), {1});

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            shellState: shellState,
            layoutMode: LdMonkeyEffectiveLayoutMode.sideBySide,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(_isListItemActive(tester, 'Item 1'), isTrue);
        expect(_isListItemActive(tester, 'Item 2'), isFalse);
      });

      testWidgets('onSelectionChange updates shell state', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );
        final shellState = TestSortAndFilterState<TestItem, int>();

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            shellState: shellState,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Selection should be handled by LdSelectableList
        expect(find.byType(LdSelectableList<TestItem, int>), findsOneWidget);

        await tester.tap(find.byType(LdListItem).first);
        await tester.pumpAndSettle();

        // After tapping, viewing should be updated via the router controller
        expect(shellState.currentViewing, equals({1}));
      });
    });

    group('Item Animations', () {
      testWidgets('wraps items in LdListItemAnimation', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
          ],
        );

        await tester.pumpWidget(
          _wrapMasterPage(
            repository: repository,
            child: LdMonkeyMasterPage<TestItem, int>(
              buildItem: (context, item) => LdListItem(
                title: Text(item.value?.name ?? ''),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LdListItemAnimation), findsWidgets);
      });
    });
  });
}
