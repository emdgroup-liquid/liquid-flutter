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
  group('LdListReorderScope keep-alive', () {
    testWidgets('dragged item survives sliver culling when KeepAlive is applied',
        (tester) async {
      final items = List.generate(6, (i) => _RItem(i, 'Item $i'));
      const pageSize = 3;

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
      var reorderCompleted = false;

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
                height: 160,
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
                      reorderCompleted = true;
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

      // Start a drag on Item 1 (index 1).
      final grip = find.byIcon(LucideIcons.gripHorizontal).at(1);
      final center = tester.getCenter(grip);

      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();

      // While drag is held, scroll the list so that Item 1 is culled from the
      // viewport.  Without KeepAlive the Draggable's state gets deactivated and
      // no onDragEnd ever fires.
      scrollController.jumpTo(200);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Confirm Item 1 is no longer rendered.
      expect(find.text('Item 1'), findsNothing, reason: 'Item 1 must be scrolled out of view');

      // Release the drag.
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // The reorder must have been processed (onDragEnd fired on the Draggable).
      expect(reorderCompleted, isTrue, reason: 'onDragEnd must fire after scroll-cull with KeepAlive');
    });
  });
}