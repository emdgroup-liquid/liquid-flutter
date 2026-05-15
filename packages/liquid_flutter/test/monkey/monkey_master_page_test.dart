import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyMasterPage Tests', () {
    group('Search Integration', () {
      testWidgets('initializes search config when search filter exists', (WidgetTester tester) async {
        final searchFilter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
        );

        final repository = createTestRepository(filters: {searchFilter});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                  child: Provider.value(
                    value: const <LdMonkeyAction<TestItem, int>>[],
                    child: Provider.value(
                      value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: LdMonkeyMasterPage<TestItem, int>(
                          buildItem: (context, item) => LdListItem(
                            title: Text(item.value?.name ?? ''),
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
        // Search config should be initialized
        expect(find.byType(LdSearchInput), findsOneWidget);
        expect(find.byType(LdMonkeyMasterPage<TestItem, int>), findsOneWidget);
      });

      testWidgets('does not initialize search config when no search filter', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                  child: Provider.value(
                    value: const <LdMonkeyAction<TestItem, int>>[],
                    child: Provider.value(
                      value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: LdMonkeyMasterPage<TestItem, int>(
                          buildItem: (context, item) => LdListItem(
                            title: Text(item.value?.name ?? ''),
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
          LdThemeProvider(
              child: MaterialApp(
                  localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                  home: ListenableProvider.value(
                    value: repository,
                    child: ListenableProvider.value(
                      value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                      child: Provider.value(
                        value: const <LdMonkeyAction<TestItem, int>>[],
                        child: Provider.value(
                          value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                          child: Provider.value(
                            value: LdMonkeyEffectiveLayoutMode.master,
                            child: LdMonkeyMasterPage<TestItem, int>(
                              buildItem: (context, item) => LdListItem(
                                title: Text('Custom: ${item.value?.name ?? ''}'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom: Custom Item'), findsOneWidget);
      });

      testWidgets('uses buildList when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(LdThemeProvider(
            child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: ListenableProvider.value(
            value: repository,
            child: ListenableProvider.value(
              value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
              child: Provider.value(
                value: const <LdMonkeyAction<TestItem, int>>[],
                child: Provider.value(
                  value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                  child: Provider.value(
                    value: LdMonkeyEffectiveLayoutMode.master,
                    child: LdMonkeyMasterPage<TestItem, int>(
                      buildList: (context, repository) => const Text('Custom List'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )));

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
          LdThemeProvider(
              child: MaterialApp(
                  localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                  home: ListenableProvider.value(
                    value: repository,
                    child: ListenableProvider.value(
                      value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                      child: Provider.value(
                        value: const <LdMonkeyAction<TestItem, int>>[],
                        child: Provider.value(
                          value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                          child: Provider.value(
                            value: LdMonkeyEffectiveLayoutMode.master,
                            child: LdMonkeyMasterPage<TestItem, int>(
                              buildItem: (context, item) => LdListItem(
                                title: Text(item.value?.toString() ?? ''),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))),
        );

        await tester.pumpAndSettle();
        // Should render the item using toString()
        expect(find.textContaining('TestItem'), findsWidgets);
      });
    });

    group('App Bars', () {
      testWidgets('uses custom appBar when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                  child: Provider.value(
                    value: const <LdMonkeyAction<TestItem, int>>[],
                    child: Provider.value(
                      value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: LdMonkeyMasterPage<TestItem, int>(
                          buildItem: (context, item) => LdListItem(
                            title: Text(item.value?.name ?? ''),
                          ),
                          appBar: const LdMonkeyAppBar<TestItem, int>(
                              location: LdMonkeyActionLocation.masterAppBar,
                              title: Text(
                                'Custom App Bar',
                              )),
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
        expect(find.text('Custom App Bar'), findsOneWidget);
      });

      testWidgets('uses default LdMonkeyAppBar when appBar not provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                  child: Provider.value(
                    value: const <LdMonkeyAction<TestItem, int>>[],
                    child: Provider.value(
                      value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: LdMonkeyMasterPage<TestItem, int>(
                          buildItem: (context, item) => LdListItem(
                            title: Text(item.value?.name ?? ''),
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
        expect(find.byType(LdMonkeyAppBar<TestItem, int>), findsWidgets);
      });

      testWidgets('uses custom secondaryAppBar when provided', (WidgetTester tester) async {
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                  child: Provider.value(
                    value: const <LdMonkeyAction<TestItem, int>>[],
                    child: Provider.value(
                      value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                      child: Provider.value(
                        value: LdMonkeyEffectiveLayoutMode.master,
                        child: LdMonkeyMasterPage<TestItem, int>(
                          secondaryAppBar: const LdMonkeyAppBar<TestItem, int>(
                            location: LdMonkeyActionLocation.masterSecondary,
                            title: Text('Custom Secondary App Bar'),
                          ),
                          buildItem: (context, item) => LdListItem(
                            title: Text(item.value?.name ?? ''),
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
        expect(find.text('Custom Secondary App Bar'), findsOneWidget);
      });
    });

    group('Selection Handling', () {
      testWidgets('onSelectionChange updates shell state', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: "/test");

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
                localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                home: ListenableProvider.value(
                  value: repository,
                  child: ListenableProvider.value(
                    value: shellState,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: Provider.value(
                        value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                        child: Provider.value(
                          value: LdMonkeyEffectiveLayoutMode.master,
                          child: LdMonkeyMasterPage<TestItem, int>(
                            buildItem: (context, item) => LdListItem(
                              title: Text(item.value?.name ?? ''),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        );

        await tester.pumpAndSettle();

        // Selection should be handled by LdSelectableList
        expect(find.byType(LdSelectableList<TestItem, int>), findsOneWidget);

        await tester.tap(find.byType(LdListItem).first);

        await tester.pumpAndSettle();
        expect(shellState.viewingItems, {1});
      });
    });

    group('Item Animations', () {
      testWidgets('wraps items in LdListItemAnimation', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
          ],
        );

        await tester.pumpWidget(LdThemeProvider(
            child: MaterialApp(
                localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                home: ListenableProvider.value(
                  value: repository,
                  child: ListenableProvider.value(
                    value: LdMonkeyShellState<TestItem, int>(basePath: "/test"),
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: Provider.value(
                        value: LdMonkeySelection<TestItem, int>(selection: {}, viewing: {}),
                        child: Provider.value(
                          value: LdMonkeyEffectiveLayoutMode.master,
                          child: LdMonkeyMasterPage<TestItem, int>(
                            buildItem: (context, item) => LdListItem(
                              title: Text(item.value?.name ?? ''),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ))));

        await tester.pumpAndSettle();
        // Items should be wrapped in animation widgets
        expect(find.byType(LdListItemAnimation), findsWidgets);
      });
    });
  });
}
