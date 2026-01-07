import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyDetailPage Tests', () {
    group('Scrollable View', () {
      testWidgets('scrollable() factory creates scrollable detail view', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setViewingItems({1, 2});

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: Provider.value(
                  value: LdMonkeyEffectiveLayoutMode.detail,
                  child: ListenableProvider.value(
                    value: shellState,
                    child: Provider.value(value: const <LdMonkeyAction<TestItem, int>>[], child: detailPage),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
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
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setViewingItems({1, 2});

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: Provider.value(
                  value: LdMonkeyEffectiveLayoutMode.detail,
                  child: ListenableProvider.value(
                    value: shellState,
                    child: Provider.value(value: const <LdMonkeyAction<TestItem, int>>[], child: detailPage),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
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
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setViewingItems({1, 2});

        final detailPage = LdMonkeyDetailPage<TestItem, int>.stacked(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: Provider.value(
                  value: LdMonkeyEffectiveLayoutMode.detail,
                  child: ListenableProvider.value(
                    value: shellState,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: detailPage,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
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
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setViewingItems({1});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
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

        await tester.pumpAndSettle();
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsNothing);

        // Update viewing items
        shellState.setViewingItems({2});
        await tester.pumpAndSettle();

        expect(find.text('Item 1'), findsNothing);
        expect(find.text('Item 2'), findsOneWidget);
      });

      testWidgets('LdMonkeyStreamSelection handles empty viewing items', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: ListenableProvider.value(
                  value: shellState,
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

        await tester.pumpAndSettle();
        // Should render empty list
        expect(find.byType(Column), findsOneWidget);
      });
    });

    group('App Bars', () {
      testWidgets('uses custom primaryAppBar when provided', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          primaryAppBar: const Text('Custom Primary App Bar'),
          body: Container(),
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
                    value: LdMonkeyEffectiveLayoutMode.detail,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: detailPage,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Custom Primary App Bar'), findsOneWidget);
      });

      testWidgets('uses default LdMonkeyAppBar when primaryAppBar not provided', (WidgetTester tester) async {
        final repository = createTestRepository();
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          body: Container(),
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
                    value: LdMonkeyEffectiveLayoutMode.detail,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: detailPage,
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
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');

        final detailPage = LdMonkeyDetailPage<TestItem, int>(
          secondaryAppBar: const Text('Custom Secondary App Bar'),
          body: Container(),
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
                    value: LdMonkeyEffectiveLayoutMode.detail,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: detailPage,
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

    group('Viewing Items Updates', () {
      testWidgets('detail view updates when viewing items change', (WidgetTester tester) async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1, name: 'Item 1'),
            createTestItem(2, name: 'Item 2'),
          ],
        );
        final shellState = LdMonkeyShellState<TestItem, int>(basePath: '/test');
        shellState.setViewingItems({1});

        final detailPage = LdMonkeyDetailPage<TestItem, int>.scrollable(
          buildDetail: (context, item) => Text('Detail: ${item.value?.name ?? ''}'),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: ListenableProvider.value(
                value: repository,
                child: Provider.value(
                  value: LdMonkeyEffectiveLayoutMode.detail,
                  child: ListenableProvider.value(
                    value: shellState,
                    child: Provider.value(
                      value: const <LdMonkeyAction<TestItem, int>>[],
                      child: detailPage,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Detail: Item 1'), findsOneWidget);

        // Update viewing items
        shellState.setViewingItems({2});
        await tester.pumpAndSettle();

        expect(find.text('Detail: Item 2'), findsOneWidget);
        expect(find.text('Detail: Item 1'), findsNothing);
      });
    });
  });
}
