import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

_wrapWithMaterialApp(Widget widget) {
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

void main() {
  group('LdList Tests', () {
    // Sample data to use for our tests
    final sampleItems = List.generate(
      20,
      (index) => 'Item ${index + 1}',
    );

    Widget _buildBasicListWidget({
      required LdPaginator<String> data,
      String Function(String item)? grouping,
      Widget Function(BuildContext context, String? criterion)?
          seperatorBuilder,
      Widget? header,
      Widget? footer,
    }) {
      return SizedBox(
        width: 300,
        height: 500,
        child: LdList<String, String?>(
          data: data,
          assumedItemHeight: 60,
          groupingCriterion: grouping,
          seperatorBuilder: seperatorBuilder ??
              (context, criterion) {
                // add a divider between groups by default
                return const LdDivider();
              },
          itemBuilder: (context, item, index) {
            return LdListItem(
              title: Text(item),
              trailingForward: true,
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
            _buildBasicListWidget(
              data: LdPaginator<String>.fromList(sampleItems.sublist(0, 5)),
            ),
          );
          await tester.pumpAndSettle();
          return null;
        },
        "List With Grouping, Header, Footer": (tester, place) async {
          await place(
            _buildBasicListWidget(
              data: LdPaginator<String>.fromList(sampleItems.sublist(0, 10)),
              // build two groups, items 1-5 and 6-10
              grouping: (item) => int.parse(item.split(' ')[1]) <= 5
                  ? 'Group 1-5'
                  : 'Group 6-10',
              seperatorBuilder: (context, criterion) {
                return LdAutoSpace(children: [
                  const LdDivider(),
                  LdTextCaption(criterion!),
                  const LdDivider(),
                ]);
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
          await tester.pumpAndSettle();
          return null;
        },
        "Empty State": (tester, place) async {
          final paginator = LdPaginator<String>.fromList([]);
          await place(
            SizedBox(
              width: 300,
              height: 500,
              child: LdList<String, String>(
                data: paginator,
                itemBuilder: (context, item, index) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          return null;
        },
        "Error State": (tester, place) async {
          final errorProducingPaginator = LdPaginator<String>(
            fetchListFunction: (page, loadedItems, pageToken) {
              throw LdException(message: "Intentional error");
            },
            debounceTime: const Duration(milliseconds: 0),
          );
          await place(
            SizedBox(
              width: 300,
              height: 500,
              child: LdList<String, String>(
                data: errorProducingPaginator,
                itemBuilder: (context, item, index) => const SizedBox.shrink(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          return null;
        },
      });
    });

    testWidgets('LdList displays items correctly', (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicListWidget(
            data: LdPaginator<String>.fromList(
              sampleItems.sublist(0, 5),
            ),
            header: const Text("Header"),
            footer: const Text("Footer"),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle();

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

    testWidgets('LdList handles grouping criteria correctly',
        (WidgetTester tester) async {
      // Sample grouped data
      final groupedItems = [
        'Group A: Item 1',
        'Group A: Item 2',
        'Group B: Item 1',
        'Group B: Item 2',
        'Group C: Item 1',
      ];

      // Create a paginator with grouped data
      final paginator = LdPaginator<String>.fromList(groupedItems);

      // Build our widget with grouping
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdList<String, String>(
            data: paginator,
            groupingCriterion: (item) => item.split(':')[0].trim(),
            seperatorBuilder: (context, criterion) => Text(criterion),
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle();

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
      final paginator = LdPaginator<String>.fromList([]);

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdList<String, String>(
            data: paginator,
            emptyBuilder: (context, refresh) => const Text('No items found'),
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('LdList handles pagination', (WidgetTester tester) async {
      // Create a custom paginator with multiple pages
      final fiveItemsPerPagePaginator = LdPaginator<String>(
        fetchListFunction: (page, loadedItems, pageToken) async {
          // Simulate a delay for network request
          await Future.delayed(const Duration(milliseconds: 100));

          // Each page has 5 items
          const pageSize = 5;
          final totalItems = sampleItems.length;

          // Calculate start and end indices
          final startIndex = page * pageSize;
          final endIndex = (startIndex + pageSize < totalItems)
              ? startIndex + pageSize
              : totalItems;

          // Return results if valid range
          if (startIndex < totalItems) {
            return LdListPage<String>(
              newItems: sampleItems.sublist(startIndex, endIndex),
              hasMore: endIndex < totalItems,
              total: totalItems,
            );
          }

          // Empty result for invalid range
          return LdListPage<String>(
            newItems: [],
            hasMore: false,
            total: totalItems,
          );
        },
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicListWidget(data: fiveItemsPerPagePaginator),
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

    testWidgets('LdList handles reset and refresh',
        (WidgetTester tester) async {
      final paginator = LdPaginator<String>.fromList(
        sampleItems.sublist(0, 5),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicListWidget(data: paginator),
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

      // Refresh the list
      await paginator.refreshList();
      await tester.pumpAndSettle();

      // Verify that each item is displayed
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item ${i + 1}'), findsOneWidget);
      }
    });
  });
}
