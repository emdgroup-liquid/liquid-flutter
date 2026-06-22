import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

MaterialApp _wrapWithMaterialApp(Widget widget) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: Scaffold(
      body: LdThemeProvider(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      ),
    ),
  );
}

class _SampleItem with Identifiable<int> {
  int nr;

  _SampleItem(this.nr);

  @override
  get id => nr;
}

class _SampleStringItem with Identifiable<String> {
  String title;

  _SampleStringItem(this.title);

  @override
  get id => title;
}

void main() {
  group('LdList Tests', () {
    // Sample data to use for our tests
    final sampleItems = List.generate(
      20,
      (index) => _SampleItem(index + 1),
    );

    Widget buildBasicListWidget({
      required LdPaginator<_SampleItem, int> data,
      String Function(_SampleItem item)? grouping,
      Widget Function(BuildContext context, dynamic criterion, List<LdPaginatorItem<_SampleItem>>)? groupingBuilder,
      Widget Function(BuildContext context)? seperatorBuilder,
      Widget? header,
      Widget? footer,
    }) {
      return SizedBox(
        width: 500,
        height: 500,
        child: LdList<_SampleItem, int?>(
          paginator: data,
          assumedItemHeight: 60,
          groupingCriterion: grouping,
          separatorBuilder: seperatorBuilder ?? (context) => const LdDivider(),
          groupHeaderBuilder: groupingBuilder ??
              (context, criterion, items) {
                // add a divider between groups by default
                return Text("Group $criterion").padS();
              },
          itemBuilder: (context, item, index) {
            return LdListItem.trailingForward(
              title: Text("Item ${item.value.nr}"),
            );
          },
          header: header,
          footer: footer,
        ),
      );
    }

    // Golden test
    testGoldens("LdList Golden", (WidgetTester tester) async {
      await multiGolden(tester, "LdList", {
        "Basic List": (tester, place) async {
          await place(
            buildBasicListWidget(
              data: LdPaginator<_SampleItem, int>.fromList(sampleItems.sublist(0, 5)),
            ),
          );
          await tester.pumpAndSettle();
        },
        "List With Grouping, Header, Footer": (tester, place) async {
          await place(
            buildBasicListWidget(
              data: LdPaginator<_SampleItem, int>.fromList(sampleItems.sublist(0, 10)),
              // build two groups, items 1-5 and 6-10
              grouping: (item) => item.nr <= 5 ? 'Group 1-5' : 'Group 6-10',
              groupingBuilder: (context, criterion, items) {
                return LdAutoSpace(
                  children: [
                    const LdDivider(),
                    LdText.caption(criterion!),
                    const LdDivider(),
                  ],
                );
              },
              header: const LdListItem(
                leading: LdAvatar(
                  child: Text("H"),
                ),
                title: Text("Header"),
                subtitle: Text("This is a header"),
              ),
              footer: const LdListItem(
                leading: LdAvatar(
                  child: Text("F"),
                ),
                title: Text("Footer"),
                subtitle: Text("This is a footer"),
              ),
            ),
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        },
        "Empty State": (tester, place) async {
          final paginator = LdPaginator<_SampleItem, int>.fromList([]);
          await place(
            SizedBox(
              width: 500,
              height: 500,
              child: LdList<_SampleItem, int>(
                paginator: paginator,
                itemBuilder: (context, item, index) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        },
        "Error State": (tester, place) async {
          final errorProducingPaginator = LdPaginator<_SampleItem, int>(
            fetchListFunction: (params) {
              throw Exception('Foo');
            },
            debounceTime: const Duration(milliseconds: 0),
          );
          await place(
            SizedBox(
              width: 500,
              height: 500,
              child: LdList<_SampleItem, int>(
                paginator: errorProducingPaginator,
                itemBuilder: (context, item, index) => const SizedBox.shrink(),
              ),
            ),
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        },
      });
    });

    testWidgets('LdList displays items correctly', (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicListWidget(
            data: LdPaginator<_SampleItem, int>.fromList(
              sampleItems.sublist(0, 5),
            ),
            header: const Text("Header"),
            footer: const Text("Footer"),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify that each item is displayed
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsOneWidget);
      }
      expect(
        find.byWidgetPredicate((widget) => widget is LdDivider),
        findsNWidgets(4),
      );
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('LdList handles grouping criteria correctly', (WidgetTester tester) async {
      // Sample grouped data
      final groupedItems = [
        'Group A: Item 1',
        'Group A: Item 2',
        'Group B: Item 1',
        'Group B: Item 2',
        'Group C: Item 1',
      ];

      // Create a paginator with grouped data
      final paginator = LdPaginator<_SampleStringItem, String>.fromList(
        groupedItems.map((e) => _SampleStringItem(e)).toList(),
      );

      // Build our widget with grouping
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdList<_SampleStringItem, String>(
            paginator: paginator,
            groupingCriterion: (item) => item.title.split(':')[0].trim(),
            groupHeaderBuilder: (context, criterion, items) => Text(criterion),
            itemBuilder: (context, item, index) => Text(item.value.title),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify group headers and items are displayed
      expect(find.text('Group A'), findsOneWidget);
      expect(find.text('Group B'), findsOneWidget);
      expect(find.text('Group C'), findsOneWidget);
      expect(find.text('Group A: Item 1'), findsOneWidget);
      expect(find.text('Group A: Item 2'), findsOneWidget);
      expect(find.text('Group B: Item 1'), findsOneWidget);
      expect(find.text('Group B: Item 2'), findsOneWidget);
      expect(find.text('Group C: Item 1'), findsOneWidget);
    });

    testWidgets('LdList handles empty state', (WidgetTester tester) async {
      // Create an empty paginator
      final paginator = LdPaginator<_SampleStringItem, String>.fromList([]);

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdList<_SampleStringItem, String>(
            paginator: paginator,
            emptyBuilder: (context, refresh) => const Text('No items found'),
            itemBuilder: (context, item, index) => Text(item.value.title),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify empty state is displayed
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('LdList handles pagination', (WidgetTester tester) async {
      // Create a custom paginator with multiple pages
      final fiveItemsPerPagePaginator = LdPaginator<_SampleItem, int>(
        pageSize: 5,
        fetchListFunction: (params) async {
          // Simulate a delay for network request
          await Future.delayed(const Duration(milliseconds: 100));

          // Each page has 5 items
          final totalItems = sampleItems.length;

          // Calculate start and end indices
          final startIndex = params.offset;
          final endIndex = (startIndex + params.pageSize < totalItems) ? startIndex + params.pageSize : totalItems;

          // Return results if valid range
          if (startIndex < totalItems) {
            return LdListPage<_SampleItem>(
              newItems: sampleItems.sublist(startIndex, endIndex),
              hasMore: endIndex < totalItems,
              total: totalItems,
            );
          }

          // Empty result for invalid range
          return LdListPage<_SampleItem>(
            newItems: [],
            hasMore: false,
            total: totalItems,
          );
        },
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicListWidget(data: fiveItemsPerPagePaginator),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify first page items are displayed
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
      expect(find.text('Item 20'), findsNothing);

      // Trigger scroll to bottom of the list to load last page
      await tester.drag(
        find.byWidgetPredicate((widget) => widget is LdList),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify last page items are displayed
      expect(find.text('Item 20'), findsOneWidget);
    });

    testWidgets('LdList handles reset and refresh', (WidgetTester tester) async {
      final paginator = LdPaginator<_SampleItem, int>.fromList(
        sampleItems.sublist(0, 5),
      );

      // Build our widget
      late BuildContext capturedContext;
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              capturedContext = context;
              return buildBasicListWidget(data: paginator);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that each item is displayed
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsOneWidget);
      }

      // Clear the list
      paginator.reset();
      await tester.pumpAndSettle();

      // Verify that each item is displayed
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsNothing);
      }

      // Refresh the list using the captured context.
      await paginator.refreshList(context: capturedContext);
      await tester.pumpAndSettle();

      // Verify that each item is displayed
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsOneWidget);
      }
    });

    testWidgets('refreshList keeps items visible while fetching', (WidgetTester tester) async {
      final refreshGate = Completer<void>();
      final items = sampleItems.sublist(0, 5);
      final paginator = LdPaginator<_SampleItem, int>(
        pageSize: 5,
        initialItems: items,
        fetchListFunction: (parameters) async {
          if (parameters.reason == LdFetchReason.refresh) {
            await refreshGate.future;
          }
          return LdListPage<_SampleItem>(
            newItems: items,
            hasMore: false,
            total: items.length,
          );
        },
      );

      late BuildContext capturedContext;
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              capturedContext = context;
              return buildBasicListWidget(data: paginator);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final refreshFuture = paginator.refreshList(
        context: capturedContext,
        reason: LdFetchReason.refresh,
      );
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
      expect(paginator.isControlledRefresh, isTrue);
      expect(paginator.totalItems, equals(5));

      refreshGate.complete();
      await refreshFuture;
      await tester.pumpAndSettle();

      expect(paginator.isControlledRefresh, isFalse);
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsOneWidget);
      }
    });

    testWidgets('refreshList applies reordered items atomically', (WidgetTester tester) async {
      var serverItems = sampleItems.sublist(0, 5);
      final paginator = LdPaginator<_SampleItem, int>(
        pageSize: 5,
        initialItems: serverItems,
        fetchListFunction: (parameters) async {
          final end = (parameters.offset + parameters.pageSize).clamp(0, serverItems.length);
          return LdListPage<_SampleItem>(
            newItems: parameters.offset < serverItems.length ? serverItems.sublist(parameters.offset, end) : [],
            hasMore: end < serverItems.length,
            total: serverItems.length,
          );
        },
      );

      late BuildContext capturedContext;
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              capturedContext = context;
              return buildBasicListWidget(data: paginator);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);

      serverItems = [
        _SampleItem(5),
        _SampleItem(4),
        _SampleItem(3),
        _SampleItem(2),
        _SampleItem(1),
      ];

      await paginator.refreshList(
        context: capturedContext,
        reason: LdFetchReason.refresh,
      );
      await tester.pumpAndSettle();

      expect(find.text('Item 5'), findsOneWidget);
      expect(paginator.getItemAt(0)?.value?.id, equals(5));
      expect(paginator.getItemAt(4)?.value?.id, equals(1));
    });
  });

  group('LdPaginator reorderIndices', () {
    test('no-op when from equals to', () {
      final paginator = LdPaginator<_SampleItem, int>.fromList([
        _SampleItem(1),
        _SampleItem(2),
        _SampleItem(3),
      ]);

      paginator.reorderIndices(1, 1);

      expect(paginator.getItemAt(0)?.value?.id, equals(1));
      expect(paginator.getItemAt(1)?.value?.id, equals(2));
      expect(paginator.getItemAt(2)?.value?.id, equals(3));
    });

    test('moves item down and shifts loaded siblings', () {
      final paginator = LdPaginator<_SampleItem, int>.fromList([
        _SampleItem(1),
        _SampleItem(2),
        _SampleItem(3),
        _SampleItem(4),
      ]);

      paginator.reorderIndices(1, 3);

      expect(paginator.getItemAt(0)?.value?.id, equals(1));
      expect(paginator.getItemAt(1)?.value?.id, equals(3));
      expect(paginator.getItemAt(2)?.value?.id, equals(4));
      expect(paginator.getItemAt(3)?.value?.id, equals(2));
    });

    test('moves item up and shifts loaded siblings', () {
      final paginator = LdPaginator<_SampleItem, int>.fromList([
        _SampleItem(1),
        _SampleItem(2),
        _SampleItem(3),
        _SampleItem(4),
      ]);

      paginator.reorderIndices(3, 1);

      expect(paginator.getItemAt(0)?.value?.id, equals(1));
      expect(paginator.getItemAt(1)?.value?.id, equals(4));
      expect(paginator.getItemAt(2)?.value?.id, equals(2));
      expect(paginator.getItemAt(3)?.value?.id, equals(3));
    });

    test('shifts sparse indices across a gap', () {
      final paginator = LdPaginator<_SampleItem, int>(
        pageSize: 2,
        initialItems: [_SampleItem(1), _SampleItem(2)],
        fetchListFunction: (_) async => LdListPage<_SampleItem>(newItems: [], hasMore: false, total: 4),
      );
      paginator.totalItems = 4;
      paginator.replaceItems({
        0: LdPaginatorItem(value: _SampleItem(1), state: LdPaginatorItemState.loaded),
        1: LdPaginatorItem(value: _SampleItem(2), state: LdPaginatorItemState.loaded),
        3: LdPaginatorItem(value: _SampleItem(4), state: LdPaginatorItemState.loaded),
      });

      paginator.reorderIndices(0, 3);

      expect(paginator.getItemAt(0)?.value?.id, equals(2));
      expect(paginator.getItemAt(1), isNull);
      expect(paginator.getItemAt(2)?.value?.id, equals(4));
      expect(paginator.getItemAt(3)?.value?.id, equals(1));
    });
  });
}
