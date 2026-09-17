import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _RItem with Identifiable<int> {
  _RItem(this.id, this.label);

  @override
  final int id;
  final String label;

  @override
  String toString() => label;
}

void main() {
  group('LdListReorderScope scroll-during-drag', () {
    testWidgets('drop index tracks freshly loaded items after scroll culls the dragged row',
        (tester) async {
    final items = List.generate(16, (i) => _RItem(i, 'Item $i'));
    const pageSize = 4;

      final paginator = LdPaginator<_RItem, int>(
        pageSize: pageSize,
        debounceTime: Duration.zero,
        fetchListFunction: (params) async {
          final offset = params.offset;
          if (offset >= items.length) {
            return LdListPage<_RItem>(newItems: [], hasMore: false, total: items.length);
          }
          await Future.delayed(const Duration(milliseconds: 10));
          final end = (offset + pageSize).clamp(0, items.length);
          return LdListPage<_RItem>(
            newItems: items.sublist(offset, end),
            hasMore: end < items.length,
            total: items.length,
          );
        },
      );

      final scrollController = ScrollController();
      final dropLog = <(int, int)>[];

      addTearDown(() {
        scrollController.dispose();
        paginator.dispose();
      });

      final theme = LdTheme()..platform = LdPlatform.macos;

      await tester.pumpWidget(
        LdThemeProvider(
          theme: theme,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: Scaffold(
              body: SizedBox(
                height: 200,
                child: LdListConfigProvider<_RItem, int>(
                  config: LdListConfig<_RItem, int>(
                    paginator: paginator,
                    scrollController: scrollController,
                    itemBuilder: (context, item, index) => LdListItem(
                      title: Text(item.value.label),
                    ),
                  ),
                  child: LdListReorderScope<_RItem, int>(
                    onReorder: (id, from, to) async {
                      dropLog.add((from, to));
                      paginator.reorderIndices(from, to);
                    },
                    child: LdList<_RItem, int>(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Viewport ~200px shows about 4 items. Initial fetch loads page 0 (items 0-3).
      // Gap-fill may also load page 1 (items 4-7). Page 2 (items 8-11) should not be loaded.
      expect(find.text('Item 9'), findsNothing, reason: 'page 2 must not be loaded yet');

      // Grab the grip of Item 2 (index 2) and start a drag.
      final gripFinder = find.byIcon(LucideIcons.gripHorizontal).at(2);
      final gripCenter = tester.getCenter(gripFinder);

      final gesture = await tester.startGesture(gripCenter);
      await tester.pump(const Duration(milliseconds: 20));

      // Scroll the list far enough that Item 2 is culled from the viewport
      // and page 2 items appear.
      scrollController.jumpTo(400);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Item 2 should no longer be visible.
      expect(find.text('Item 2'), findsNothing);
      // Page 2 items are now rendered.
      expect(find.text('Item 9'), findsOneWidget);

      // The gesture recognizer is still alive (keep-alive held the item).
      // Drop at the current pointer position.
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // The reorder must have been processed, not silently cancelled.
      expect(dropLog, isNotEmpty, reason: 'reorder must have completed');
    });
  });
}