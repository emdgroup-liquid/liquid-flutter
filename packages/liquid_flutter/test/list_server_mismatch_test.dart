// Tests for client/server state mismatch scenarios in LdPaginator and
// LdListController.  Every test intentionally causes the server snapshot to
// diverge from what the client already cached / loaded and verifies that the
// paginator recovers cleanly without infinite loops, stuck loaders, or
// assertion errors.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

// ---------------------------------------------------------------------------
// Shared test helpers
// ---------------------------------------------------------------------------

class _Item with Identifiable<int> {
  @override
  final int id;
  final String label;
  _Item(this.id, [this.label = '']);

  @override
  String toString() => '_Item($id, "$label")';
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: LdThemeProvider(child: Scaffold(body: child)),
  );
}

Future<BuildContext> _ctx(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(_wrap(Builder(builder: (c) {
    ctx = c;
    return const SizedBox();
  })));
  await tester.pump();
  return ctx;
}

/// Creates an [LdListController] backed by [fetchFn].
LdListController<_Item, int> _makeController(
  Future<LdListPage<_Item>> Function(FetchPageParameters<_Item, int>) fetchFn, {
  int pageSize = 5,
  Future<void> Function(BuildContext, int)? deleteItem,
}) {
  return LdListController.fromModel(
    LdCallbackModel<_Item, int>(
      fetchListWithParameters: fetchFn,
      getById: (ctx, id) async => _Item(id),
      deleteItem: deleteItem,
      pageSize: pageSize,
      autoCache: false, // most tests want raw network behaviour
      autoInvalidateCache: false,
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // 1. Server shrinks the total between two consecutive page fetches
  // ──────────────────────────────────────────────────────────────────────────
  group('Server total shrinks between page fetches', () {
    testWidgets(
        'totalItems updates to the smaller value returned by the second page',
        (tester) async {
      // Page 0 → 5 items, claims total = 20.
      // Page 5 → 5 items, claims total = 8  (server shrank between requests).
      final serverData = List.generate(10, (i) => _Item(i + 1));

      final controller = _makeController((params) async {
        final total = params.offset == 0 ? 20 : 8;
        final slice = serverData.skip(params.offset).take(params.pageSize).toList();
        return LdListPage<_Item>(
          newItems: slice,
          hasMore: params.offset + params.pageSize < total,
          total: total,
        );
      });

      final ctx = await _ctx(tester);

      // Fetch page 0 — totalItems becomes 20
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 20);

      // Fetch page 5 — totalItems must shrink to 8
      await controller.fetchPageAtOffset(ctx, 5,
          reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 8,
          reason: 'totalItems must track the latest server total');

      controller.dispose();
    });

    testWidgets('items beyond the new total are not shown as gaps',
        (tester) async {
      // Page 0 claims total = 15; refresh returns total = 3.
      var callCount = 0;
      final controller = _makeController((params) async {
        callCount++;
        if (callCount == 1) {
          // First load: 5 items, total = 15
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(i + 1)),
            hasMore: true,
            total: 15,
          );
        }
        // Subsequent calls (refresh): only 3 items remain
        return LdListPage<_Item>(
          newItems: List.generate(3, (i) => _Item(i + 1)),
          hasMore: false,
          total: 3,
        );
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 15);

      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(controller.totalItems, 3,
          reason: 'after refresh totalItems must equal the new server total');
      // items() has length = totalItems; none should be null since we loaded
      // all 3 items in the single refresh page
      final items = controller.items;
      expect(items.length, 3);
      expect(items.every((item) => item != null), isTrue);

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Cross-page eviction: same item appears at a different index on second
  //    fetch (server shifted items between the two requests)
  // ──────────────────────────────────────────────────────────────────────────
  group('Cross-page eviction', () {
    testWidgets(
        'item that moved from page 0 to page 1 is not duplicated in the map',
        (tester) async {
      // Snapshot A (served on first fetch of offset=0):
      //   [1, 2, 3, 4, 5]  total=10
      // Snapshot B (served on first fetch of offset=5):
      //   [6, 7, 8, 9, 10]  total=10
      //   but item id=2 was deleted server-side, so the list shifted:
      //   offset=0 would now be [1, 3, 4, 5, 6], offset=5 = [7, 8, 9, 10, ...]
      //   However, since offset=0 was already loaded we only see the mismatch
      //   when we receive item id=1 again at a new position via a cross-page
      //   fetch.  We simulate this by returning item id=5 in BOTH page 0 and
      //   page 1 responses.

      final controller = _makeController((params) async {
        if (params.offset == 0) {
          // Initial page: items 1-5
          return LdListPage<_Item>(
            newItems: [_Item(1), _Item(2), _Item(3), _Item(4), _Item(5)],
            hasMore: true,
            total: 10,
          );
        } else {
          // Page 5 — item id=5 appears again (server shifted after a delete)
          return LdListPage<_Item>(
            newItems: [_Item(5), _Item(6), _Item(7), _Item(8), _Item(9)],
            hasMore: false,
            total: 9,
          );
        }
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await controller.fetchPageAtOffset(ctx, 5,
          reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // id=5 must appear exactly once in the loaded items
      final allIds = controller.itemsMap.values
          .where((item) => item.value != null)
          .map((item) => item.value!.id)
          .toList();
      expect(allIds.where((id) => id == 5).length, 1,
          reason: 'duplicate item must be evicted by cross-page eviction logic');

      controller.dispose();
    });

    testWidgets('cross-page eviction clears listCache to prevent ping-pong',
        (tester) async {
      // Strategy:
      //  1. Pre-populate the cache for offset=5 with stale data that contains
      //     item id=3 (which will also appear in page 0).
      //  2. Load page 0 via network — id=3 lands at index 2.
      //  3. Request offset=5 — cache HIT serves stale data including id=3.
      //     _insertPageItems detects cross-page eviction and calls listCache.clear().
      //  4. Pre-populate the cache again for offset=5 with fresh (non-conflicting)
      //     data. If listCache.clear() actually worked, offset=5 is no longer
      //     cached, and a subsequent request for offset=10 (a brand-new slot)
      //     cannot have a stale cache entry either — the cache is empty.
      //  5. Verify the cache has no remaining entries after the eviction.

      final cache = LdListCache<_Item, int>();

      // Pre-populate stale cache entry for offset=5 (contains id=3 which is
      // also in page 0).
      cache.writePage(
        '',
        offset: 5,
        items: [_Item(3), _Item(6), _Item(7), _Item(8), _Item(9)],
        total: 10,
      );

      // Sanity-check: cache has the entry before we start
      expect(cache.readPage('', 5), isNotNull);

      var networkCallCount = 0;
      final controller = LdListController.fromModel(
        LdCallbackModel<_Item, int>(
          fetchListWithParameters: (params) async {
            networkCallCount++;
            // Always return page 0 data: items 1-5
            return LdListPage<_Item>(
              newItems: [_Item(1), _Item(2), _Item(3), _Item(4), _Item(5)],
              hasMore: true,
              total: 10,
            );
          },
          getById: (ctx, id) async => _Item(id),
          pageSize: 5,
          autoCache: true, // enable cache so hits are possible
          autoInvalidateCache: false,
          cache: cache,
        ),
      );

      final ctx = await _ctx(tester);

      // Fetch page 0 (network call, writes offset=0 to cache)
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(networkCallCount, 1);

      // Fetch offset=5 — served from stale cache, cross-page eviction fires,
      // listCache.clear() must be called.
      await controller.fetchPageAtOffset(ctx, 5,
          reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After the eviction the entire cache must be empty (both offset=0 and
      // offset=5 entries are gone).
      expect(cache.readPage('', 0), isNull,
          reason: 'listCache.clear() must remove all entries including offset=0');
      expect(cache.readPage('', 5), isNull,
          reason: 'listCache.clear() must remove the stale offset=5 entry');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Refresh storm guard: concurrent single-item deletions must not each
  //    trigger a redundant refreshList while one is already in flight
  // ──────────────────────────────────────────────────────────────────────────
  group('Refresh storm guard', () {
    testWidgets(
        'confirming multiple deletions concurrently issues at most one refresh',
        (tester) async {
      // 10 items; pageSize=10 so indices are contiguous and compactable,
      // except we only load 5 and leave indices 5-9 unloaded so compaction
      // cannot proceed (non-contiguous sparse map after 5 items) — forcing
      // the non-compact path that calls refreshList.

      // We'll load 6 items (0-5) so deletion at index 5 is at the edge:
      // after deleting index 5 the map has 0-4 contiguous → compactable.
      // Instead, load only indices 0-4 with total=10 so every deletion from
      // that set leaves a sparse tail and triggers the refresh path.

      var refreshCallCount = 0;
      final deleteCompleter = Completer<void>();

      final items = List.generate(10, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          refreshCallCount++;
          final slice =
              items.skip(params.offset).take(params.pageSize).toList();
          return LdListPage<_Item>(
            newItems: slice,
            hasMore: params.offset + params.pageSize < items.length,
            total: items.length,
          );
        },
        pageSize: 10, // single page covers all items → total=10, 10 loaded
        deleteItem: (ctx, id) async {
          await deleteCompleter.future; // hold all deletes until we release
        },
      );

      final ctx = await _ctx(tester);
      // Load all items (one page of 10)
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 10);
      refreshCallCount = 0; // only count refreshes from now on

      // Fire 3 concurrent deletes without awaiting — all block on deleteCompleter
      final f1 = controller.model!.delete(context: ctx, id: 1);
      final f2 = controller.model!.delete(context: ctx, id: 2);
      final f3 = controller.model!.delete(context: ctx, id: 3);

      // Give the scheduleItemDeletion calls a moment to run
      await tester.pump(const Duration(milliseconds: 10));

      // Release all deletes simultaneously
      deleteCompleter.complete();

      // Wait for all three to finish
      await Future.wait([f1, f2, f3]);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After 3 deletes with compaction (10 → 7, contiguous) the list should
      // have been compacted locally, not refreshed.  In the case where the
      // sparse map cannot be compacted, the storm guard must cap refreshes.
      //
      // Either way at most 1 refresh should have been triggered.
      expect(refreshCallCount, lessThanOrEqualTo(1),
          reason:
              'concurrent deletes must not each trigger an independent refreshList');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Transient item (deleting) survives a concurrent refresh
  // ──────────────────────────────────────────────────────────────────────────
  group('Transient item survives concurrent refresh', () {
    testWidgets(
        'item in deleting state is moved to detached map during refresh commit',
        (tester) async {
      final deleteStarted = Completer<void>();
      final deleteGate = Completer<void>();

      final items = List.generate(5, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          final slice =
              items.skip(params.offset).take(params.pageSize).toList();
          return LdListPage<_Item>(
            newItems: slice,
            hasMore: false,
            total: items.length,
          );
        },
        deleteItem: (ctx, id) async {
          deleteStarted.complete();
          await deleteGate.future; // hold the delete while refresh runs
        },
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Start delete for id=3 (does not await — will block on deleteGate)
      final deleteFuture = controller.model!.delete(context: ctx, id: 3);

      // Wait until the delete has started (item is now in `deleting` state)
      await deleteStarted.future;
      await tester.pump();

      // Verify item is in deleting state
      expect(controller.getItemById(3)?.state,
          LdPaginatorItemState.deleting,
          reason: 'item must be in deleting state before refresh');

      // Trigger a refresh while delete is in-flight
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After the refresh committed, id=3 should still be resolvable
      // (either still in paged items or promoted to detached map)
      final item = controller.getItemById(3);
      expect(item, isNotNull,
          reason:
              'in-flight deleting item must remain accessible after refresh commit');

      // Now release the delete — it should complete cleanly
      deleteGate.complete();
      await deleteFuture;
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // id=3 should be gone from the controller after confirm
      expect(controller.getItemById(3), isNull,
          reason: 'item must be removed after deletion confirmed');

      controller.dispose();
    });

    testWidgets('delete rollback resolves cleanly after a concurrent refresh',
        (tester) async {
      final deleteGate = Completer<void>();
      final items = List.generate(5, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          return LdListPage<_Item>(
            newItems: items.skip(params.offset).take(params.pageSize).toList(),
            hasMore: false,
            total: items.length,
          );
        },
        deleteItem: (ctx, id) async {
          await deleteGate.future;
          throw Exception('Delete failed'); // force rollback
        },
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Start failing delete
      final deleteFuture =
          controller.model!.delete(context: ctx, id: 2).catchError((_) {});

      await tester.pump(const Duration(milliseconds: 10));

      // Refresh while delete is pending
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Release the delete → it throws → rollback path runs
      deleteGate.complete();
      await deleteFuture;
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The controller must not be in an error state; item 2 should be back
      // (rolled back) and the list must be consistent
      expect(controller.hasError, isFalse,
          reason: 'rollback after concurrent refresh must not leave an error');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Server returns empty list during a refresh (total drops to 0)
  // ──────────────────────────────────────────────────────────────────────────
  group('Server returns empty list on refresh', () {
    testWidgets('totalItems becomes 0 and busy becomes false', (tester) async {
      var callCount = 0;
      final controller = _makeController((params) async {
        callCount++;
        if (callCount == 1) {
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(i + 1)),
            hasMore: false,
            total: 5,
          );
        }
        // All items deleted server-side
        return LdListPage<_Item>(newItems: [], hasMore: false, total: 0);
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 5);

      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(controller.totalItems, 0);
      expect(controller.busy, isFalse,
          reason: 'busy must be false after refresh completes with empty list');
      expect(controller.hasError, isFalse);

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 6. Concurrent delete confirm arrives after refresh already removed the item
  // ──────────────────────────────────────────────────────────────────────────
  group('Delete confirm after refresh removes item', () {
    testWidgets('late confirm is a no-op and does not throw', (tester) async {
      // We cannot easily test the private _confirmDeletionForId path directly,
      // so we use the public model.delete() + a refresh that completes first.
      // We want to ensure that when the refresh beats the delete confirm the
      // controller doesn't crash.

      final deleteGate = Completer<void>();
      final refreshCompleted = Completer<void>();

      final items = List.generate(5, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          // After the first load, the refresh returns items without id=1
          final isRefresh = params.reason == LdFetchReason.refresh ||
              params.reason == LdFetchReason.invalidate;
          final serverItems = isRefresh
              ? items.where((i) => i.id != 1).toList()
              : items.toList();
          return LdListPage<_Item>(
            newItems:
                serverItems.skip(params.offset).take(params.pageSize).toList(),
            hasMore: false,
            total: serverItems.length,
          );
        },
        deleteItem: (ctx, id) async {
          await deleteGate.future; // hold until after refresh
        },
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Start delete for id=1 — will block
      final deleteFuture = controller.model!.delete(context: ctx, id: 1);
      await tester.pump(const Duration(milliseconds: 10));

      // Trigger refresh (server no longer returns id=1)
      final refreshFuture = controller
          .refreshList(context: ctx, reason: LdFetchReason.refresh)
          .then((_) => refreshCompleted.complete());

      // Let refresh complete before the delete
      await refreshFuture;
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Now release the delete — confirm path runs even though item is gone
      deleteGate.complete();
      // Must not throw
      await expectLater(deleteFuture, completes);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(controller.hasError, isFalse);

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 7. Paginator receives inconsistent total across pages (each page returns
  //    a different total) — the last-seen total wins and no infinite fetch loop
  //    is triggered
  // ──────────────────────────────────────────────────────────────────────────
  group('Inconsistent total across pages', () {
    testWidgets(
        'paginator does not loop when each page returns a different total',
        (tester) async {
      var fetchCount = 0;
      final controller = LdPaginator<_Item, int>(
        pageSize: 5,
        debounceTime: Duration.zero, // immediate for tests
        fetchListFunction: (params) async {
          fetchCount++;
          // Simulate server returning a different total on each request
          final totals = [20, 15, 12];
          final total = totals[fetchCount % totals.length];
          final start = params.offset;
          final allItems = List.generate(15, (i) => _Item(i + 1));
          final slice = allItems.skip(start).take(params.pageSize).toList();
          return LdListPage<_Item>(
            newItems: slice,
            hasMore: start + params.pageSize < total,
            total: total,
          );
        },
      );

      final ctx = await _ctx(tester);

      // Fetch the first two pages
      await controller.fetchPageAtOffset(ctx, 0,
          reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await controller.fetchPageAtOffset(ctx, 5,
          reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // fetchCount must be bounded — no infinite loop
      expect(fetchCount, lessThanOrEqualTo(4),
          reason: 'inconsistent totals must not cause an infinite fetch loop');

      // totalItems must reflect the most recent fetch response
      expect(controller.totalItems, isPositive);

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 8. Deleting all loaded items when more exist on the server must NOT show
  //    the empty state — it should keep totalItems > 0 and let gap-fills load
  //    the remaining unloaded pages
  // ──────────────────────────────────────────────────────────────────────────
  group('Delete all loaded items with more on server', () {
    testWidgets(
        'currentItemCount==0 with totalItems>0 does not trigger empty state',
        (tester) async {
      // 10 items total; page 0 (ids 1-5) is loaded, page 1 (ids 6-10) is not.
      // Deleting all 5 loaded items must leave totalItems=5 (decremented from 10),
      // currentItemCount=0, but the empty state must NOT appear because
      // totalItems > 0.

      final serverItems = List.generate(10, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          final slice =
              serverItems.skip(params.offset).take(params.pageSize).toList();
          return LdListPage<_Item>(
            newItems: slice,
            hasMore: params.offset + params.pageSize < serverItems.length,
            total: serverItems.length,
          );
        },
        deleteItem: (ctx, id) async {}, // instant server confirm
      );

      final ctx = await _ctx(tester);

      // Load only page 0
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 10);
      expect(controller.currentItemCount, 5);

      // Delete all 5 loaded items
      for (final id in [1, 2, 3, 4, 5]) {
        await controller.model!.delete(context: ctx, id: id);
      }
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // currentItemCount must be 0 (all loaded items gone)
      expect(controller.currentItemCount, 0);
      // totalItems must still reflect the remaining server items (5 left)
      expect(controller.totalItems, 5,
          reason:
              'totalItems must be decremented per deletion, not set to 0');
      // busy should be false (no fetch currently in flight from the controller
      // itself — the widget-driven gap-fill is separate)
      expect(controller.hasError, isFalse);

      controller.dispose();
    });

    testWidgets(
        'LdList does not show empty state when totalItems>0 after all loaded items deleted',
        (tester) async {
      // This test pumps an actual LdList widget so we can verify the
      // _buildEmpty / _buildListView branch is chosen correctly.

      final serverItems = List.generate(10, (i) => _Item(i + 1));

      final controller = _makeController(
        (params) async {
          final slice =
              serverItems.skip(params.offset).take(params.pageSize).toList();
          return LdListPage<_Item>(
            newItems: slice,
            hasMore: params.offset + params.pageSize < serverItems.length,
            total: serverItems.length,
          );
        },
        deleteItem: (ctx, id) async {},
      );

      // Build a minimal LdList widget
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            child: Scaffold(
              body: Builder(builder: (ctx) {
                return LdList<_Item, int>(
                  paginator: controller,
                  itemBuilder: (ctx, item, i) =>
                      Text('Item ${item.value.id}', key: ValueKey(item.value.id)),
                );
              }),
            ),
          ),
        ),
      );

      // Let initial load complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Item 1'), findsOneWidget);

      // Capture ctx from the tree for delete calls
      final BuildContext listCtx = tester.element(find.byType(LdList<_Item, int>));

      // Delete all loaded items — await each so the confirms run synchronously
      for (final id in [1, 2, 3, 4, 5]) {
        await controller.model!.delete(context: listCtx, id: id);
        // Flush the micro-task-deferred _onDataChange timer after each delete
        await tester.pump(Duration.zero);
      }

      // One final pump to let any remaining deferred callbacks run
      await tester.pump(Duration.zero);

      // The list must NOT show the LdListEmpty widget while totalItems > 0
      expect(find.byType(LdListEmpty), findsNothing,
          reason:
              'empty state must not appear while totalItems > 0 (unloaded items remain)');

      // Let the gap-fill fetch that the placeholder rows trigger complete, then
      // dispose cleanly (no pending timers).
      await tester.pumpAndSettle(const Duration(seconds: 2));
      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // BUG #1 — confirmItemUpdate throws after a concurrent refresh evicts the
  //          updating item to _detachedItemsById
  //
  // Root cause: LdListController.confirmItemUpdate updates _detachedItemsById
  // then unconditionally falls through to super.confirmItemUpdate, which scans
  // _items for an `updating` entry — but after the refresh _items no longer
  // contains such an entry, so it throws.
  // ──────────────────────────────────────────────────────────────────────────
  group('Bug #1: confirmItemUpdate after concurrent refresh', () {
    testWidgets('does not throw when refresh evicts the updating item to detached map',
        (tester) async {
      final updateGate = Completer<void>();
      final items = List.generate(5, (i) => _Item(i + 1, 'original'));

      final controller = LdListController.fromModel(
        LdCallbackModel<_Item, int>(
          fetchListWithParameters: (params) async {
            final slice =
                items.skip(params.offset).take(params.pageSize).toList();
            return LdListPage<_Item>(
              newItems: slice,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (ctx, id) async => items.firstWhere((i) => i.id == id),
          updateItem: (ctx, id, newItem) async {
            await updateGate.future; // hold the update while refresh runs
            return newItem;
          },
          pageSize: 5,
          autoCache: false,
          autoInvalidateCache: false,
        ),
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Start an update for id=2 — will block on updateGate
      final updateFuture =
          controller.model!.update(ctx, 2, _Item(2, 'updated'));

      // Give scheduleItemUpdate a moment to run (item is now in `updating` state)
      await tester.pump(const Duration(milliseconds: 10));
      expect(controller.getItemById(2)?.state, LdPaginatorItemState.updating);

      // Trigger a refresh while the update is in-flight — this will evict the
      // updating item to _detachedItemsById
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Release the update — confirmItemUpdate must NOT throw
      updateGate.complete();
      await expectLater(updateFuture, completes,
          reason: 'confirmItemUpdate must not throw after refresh evicted item to detached map');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(controller.hasError, isFalse);
      controller.dispose();
    });

    testWidgets('confirmed value is visible after update + concurrent refresh',
        (tester) async {
      final updateGate = Completer<void>();
      final items = List.generate(5, (i) => _Item(i + 1, 'original'));

      final controller = LdListController.fromModel(
        LdCallbackModel<_Item, int>(
          fetchListWithParameters: (params) async {
            final slice =
                items.skip(params.offset).take(params.pageSize).toList();
            return LdListPage<_Item>(
              newItems: slice,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (ctx, id) async => items.firstWhere((i) => i.id == id),
          updateItem: (ctx, id, newItem) async {
            await updateGate.future;
            return _Item(id, 'server-confirmed');
          },
          pageSize: 5,
          autoCache: false,
          autoInvalidateCache: false,
        ),
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final updateFuture =
          controller.model!.update(ctx, 3, _Item(3, 'optimistic'));
      await tester.pump(const Duration(milliseconds: 10));

      // Refresh while update in-flight
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Release update
      updateGate.complete();
      await updateFuture;
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After confirm the item should carry the server-confirmed label
      final item = controller.getItemById(3);
      expect(item?.value?.label, 'server-confirmed',
          reason: 'confirmed value must be applied even after concurrent refresh');
      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // BUG #2 — Short page from server (newItems.length < pageSize) causes a
  //          permanent spinner because _requestedOffsets handling prevents the
  //          unsatisfied indices from ever being re-fetched.
  //
  // Sub-case A: via _fetchItems — offset is removed from _requestedOffsets
  //   unconditionally, so gap-fill immediately re-requests offset 0, server
  //   returns 3 items again, infinite loop.
  //
  // Sub-case B: via _commitRefreshState — a short-page refresh offset is added
  //   to _requestedOffsets, blocking gap-fills for the unsatisfied indices.
  // ──────────────────────────────────────────────────────────────────────────
  group('Bug #2: short server page does not cause infinite loop or permanent spinner', () {
    testWidgets('gap-fill for unsatisfied indices completes after server returns full page',
        (tester) async {
      // First call returns 3 items for offset=0, pageSize=5.
      // Second call (triggered by gap at indices 3-4) returns remaining 2.
      var fetchCount = 0;
      final controller = _makeController((params) async {
        fetchCount++;
        if (fetchCount == 1) {
          // Short page: only 3 of 5 items
          return LdListPage<_Item>(
            newItems: [_Item(1), _Item(2), _Item(3)],
            hasMore: true,
            total: 5,
          );
        }
        // Full page on retry
        return LdListPage<_Item>(
          newItems: [_Item(1), _Item(2), _Item(3), _Item(4), _Item(5)],
          hasMore: false,
          total: 5,
        );
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After settling, all 5 items should be loaded — no permanent spinner
      expect(controller.totalItems, 5);
      // The paginator must not loop more than a handful of times
      expect(fetchCount, lessThanOrEqualTo(5),
          reason: 'short page must not cause an infinite re-fetch loop');

      controller.dispose();
    });

    testWidgets(
        'refresh with short page does not permanently block gap-fills for unsatisfied indices',
        (tester) async {
      // Initial load: 5 items. Refresh returns only 3. Indices 3-4 must
      // eventually be loaded (either re-fetched or handled gracefully) and
      // must NOT spin forever.
      var callCount = 0;
      final controller = _makeController((params) async {
        callCount++;
        if (callCount == 1) {
          // First load: full page
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(i + 1)),
            hasMore: false,
            total: 5,
          );
        }
        if (callCount == 2) {
          // Refresh: short page — only 3 items, but total still claims 5
          return LdListPage<_Item>(
            newItems: [_Item(1), _Item(2), _Item(3)],
            hasMore: true,
            total: 5,
          );
        }
        // Subsequent calls: return full data
        return LdListPage<_Item>(
          newItems: List.generate(5, (i) => _Item(i + 1)),
          hasMore: false,
          total: 5,
        );
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Must not spin forever
      expect(callCount, lessThanOrEqualTo(6),
          reason: 'short-page refresh must not cause an infinite gap-fill loop');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // BUG #3 — refreshList race window: _getOffsetById await in the override
  //          means two concurrent refreshes can both proceed past the
  //          isControlledRefresh guard and race to commit their results.
  // ──────────────────────────────────────────────────────────────────────────
  group('Bug #3: refreshList race window with _getOffsetById', () {
    testWidgets('second refresh is suppressed while first is resolving anchor offset',
        (tester) async {
      var fetchCount = 0;
      final anchorGate = Completer<void>();

      final items = List.generate(5, (i) => _Item(i + 1));

      final controller = LdListController.fromModel(
        LdCallbackModel<_Item, int>(
          fetchListWithParameters: (params) async {
            fetchCount++;
            final slice =
                items.skip(params.offset).take(params.pageSize).toList();
            return LdListPage<_Item>(
              newItems: slice,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (ctx, id) async => items.firstWhere((i) => i.id == id),
          // Slow anchor resolution — opens the race window
          getOffsetByIdFn: (params) async {
            await anchorGate.future;
            return 0;
          },
          pageSize: 5,
          autoCache: false,
          autoInvalidateCache: false,
        ),
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      fetchCount = 0; // reset; only count refreshes

      // Fire two invalidate refreshes simultaneously — both enter the
      // _getOffsetById await before _isControlledRefresh is set.
      final r1 = controller.refreshList(
          context: ctx, reason: LdFetchReason.invalidate);
      final r2 = controller.refreshList(
          context: ctx, reason: LdFetchReason.invalidate);

      // Release the anchor gate so both can proceed
      anchorGate.complete();
      await Future.wait([r1, r2]);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Only one full refresh fetch should have been made (the second must be
      // suppressed once the first sets _isControlledRefresh = true)
      expect(fetchCount, 1,
          reason: 'concurrent invalidate refreshes must not both fetch; second must be suppressed');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // RISK #4 — Orphaned _items entries when totalItems shrinks
  //
  // After a fetch returns a smaller total, entries in _items at indices >=
  // new total should not pollute id lookups.
  // ──────────────────────────────────────────────────────────────────────────
  group('Risk #4: orphaned _items entries after totalItems shrinks', () {
    testWidgets('getItemIndexById does not return a stale orphaned index', (tester) async {
      // Load 10 items across two pages. Then server shrinks to 3. A new fetch
      // of offset=0 returns total=3. Items at indices 3-9 must not remain
      // accessible via getItemIndexById, as they are no longer valid.
      var callCount = 0;
      final controller = _makeController((params) async {
        callCount++;
        if (callCount <= 2) {
          // First two fetches: 5 items each, total=10
          final start = params.offset;
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(start + i + 1)),
            hasMore: start == 0,
            total: 10,
          );
        }
        // After shrink: only 3 items at offset=0
        return LdListPage<_Item>(
          newItems: [_Item(1), _Item(2), _Item(3)],
          hasMore: false,
          total: 3,
        );
      });

      final ctx = await _ctx(tester);

      // Load both pages
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await controller.fetchPageAtOffset(ctx, 5, reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 10);

      // Refresh — server now returns only 3 items
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(controller.totalItems, 3);

      // Items at indices >= 3 are beyond the new total. Their ids (4-10) must
      // NOT be findable via getItemIndexById — they are stale orphans.
      for (final id in [4, 5, 6, 7, 8, 9, 10]) {
        final index = controller.getItemIndexById(id);
        expect(index, isNull,
            reason: 'id=$id is beyond new totalItems=3 and must not be found');
      }
      controller.dispose();
    });

    testWidgets('confirmItemDeletion does not operate on stale orphaned index', (tester) async {
      // Reproduce the id-lookup pollution scenario: load pages 0 and 1, then
      // a page-0 re-fetch returns a smaller total leaving page-1 orphaned.
      // A new item with id=6 (previously orphaned) arrives in a subsequent
      // fetch — getItemIndexById must return the new index, not the stale one.
      var callCount = 0;

      final controller = _makeController(
        (params) async {
          callCount++;
          if (callCount == 1) {
            return LdListPage<_Item>(
              newItems: List.generate(5, (i) => _Item(i + 1)),
              hasMore: true,
              total: 10,
            );
          }
          if (callCount == 2) {
            // Page 1: ids 6-10 land at indices 5-9
            return LdListPage<_Item>(
              newItems: List.generate(5, (i) => _Item(i + 6)),
              hasMore: false,
              total: 10,
            );
          }
          // Refresh: total shrinks to 6, id=6 now lives at index 0
          return LdListPage<_Item>(
            newItems: [_Item(6), _Item(7), _Item(8), _Item(9), _Item(10)],
            hasMore: false,
            total: 5,
          );
        },
        deleteItem: (ctx, id) async {},
      );

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await controller.fetchPageAtOffset(ctx, 5, reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // id=6 is at index 5 in the stale map
      expect(controller.getItemIndexById(6), 5);

      // Refresh — total shrinks, id=6 is now at index 0
      await controller.refreshList(context: ctx, reason: LdFetchReason.refresh);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After refresh id=6 must be at the new index (0), not the stale one (5)
      final idx = controller.getItemIndexById(6);
      expect(idx, 0,
          reason: 'after refresh id=6 must be found at its new index, not the stale one');

      controller.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // RISK #5 — hasMore=false with total > offset+newItems.length causes
  //           infinite retry because _requestedOffsets is cleared but the
  //           gap remains, so every render re-queues the same offset.
  // ──────────────────────────────────────────────────────────────────────────
  group('Risk #5: hasMore=false with total > loaded does not loop forever', () {
    testWidgets('empty page with hasMore=false terminates gap-fills for that offset',
        (tester) async {
      // Server says total=10 but returns 0 items for offset=5 with hasMore=false.
      // The paginator must not re-fetch offset=5 indefinitely.
      var fetchCount = 0;
      final controller = _makeController((params) async {
        fetchCount++;
        if (params.offset == 0) {
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(i + 1)),
            hasMore: true,
            total: 10,
          );
        }
        // offset=5: server lies — hasMore=false but total=10
        return LdListPage<_Item>(
          newItems: [],
          hasMore: false,
          total: 10,
        );
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trigger a fetch for offset=5 and settle
      await controller.fetchPageAtOffset(ctx, 5, reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // fetchCount must be bounded — no infinite loop
      expect(fetchCount, lessThanOrEqualTo(5),
          reason: 'empty page with hasMore=false must not cause infinite re-fetching');

      controller.dispose();
    });

    testWidgets('empty page with hasMore=true and mismatched total also terminates',
        (tester) async {
      // Even more pathological: every call returns empty with hasMore=true.
      // The paginator must give up after a reasonable number of attempts.
      var fetchCount = 0;
      final controller = _makeController((params) async {
        fetchCount++;
        if (fetchCount == 1) {
          return LdListPage<_Item>(
            newItems: List.generate(5, (i) => _Item(i + 1)),
            hasMore: true,
            total: 10,
          );
        }
        // All subsequent fetches return empty but claim total=10
        return LdListPage<_Item>(
          newItems: [],
          hasMore: true,
          total: 10,
        );
      });

      final ctx = await _ctx(tester);
      await controller.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.initial);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await controller.fetchPageAtOffset(ctx, 5, reason: LdFetchReason.pagination);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(fetchCount, lessThanOrEqualTo(5),
          reason: 'empty page must not cause infinite gap-fill loop regardless of hasMore');

      controller.dispose();
    });
  });
}
