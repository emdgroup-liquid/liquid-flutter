import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// Test item class
class _TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;

  _TestItem(this.id, this.name, this.value, [this.active = true]);

  _TestItem copyWith({
    int? id,
    String? name,
    int? value,
    bool? active,
  }) {
    return _TestItem(
      id ?? this.id,
      name ?? this.name,
      value ?? this.value,
      active ?? this.active,
    );
  }

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, active: $active)';
}

// Helper to build a minimal widget and get a BuildContext
Widget _buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: LdThemeProvider(
      child: Scaffold(body: child),
    ),
  );
}

// Helper that pumps the widget and returns the BuildContext via a Builder.
// The returned context can be used for repository operations.
Future<BuildContext> _pumpAndGetContext(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(_buildTestWidget(Builder(builder: (context) {
    ctx = context;
    return const SizedBox();
  })));
  await tester.pump();
  return ctx;
}

// Load the repository with items by calling refreshList and settling.
Future<void> _loadRepository(
  WidgetTester tester,
  LdListController<dynamic, dynamic> repository,
  BuildContext context,
) async {
  await repository.refreshList(context: context);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  group('LdListController Tests', () {
    // Default test items
    final defaultItems = <_TestItem>[
      _TestItem(1, 'Item 1', 10),
      _TestItem(2, 'Item 2', 20),
      _TestItem(3, 'Item 3', 30),
    ];

    // Helper function to create a repository with mock functions
    LdListController<_TestItem, int> createRepository({
      Future<LdListPage<_TestItem>> Function(FetchPageParameters<_TestItem, int> parameters)? fetchListWithParameters,
      Future<_TestItem> Function(BuildContext context, int id)? getById,
      Future<int?> Function(FetchOffsetParameters<_TestItem, int> parameters)? getOffsetById,
      Future<void> Function(BuildContext context, int id)? deleteItem,
      Future<_TestItem?> Function(BuildContext context, int id, _TestItem newItem)? updateItem,
      Future<_TestItem> Function(BuildContext context, _TestItem? newItem)? createItem,
      Future<void> Function(BuildContext context, Set<int> ids)? deleteBatch,
      Future<void> Function(BuildContext context, Map<int, _TestItem> items)? updateBatch,
      int pageSize = 10,
      bool autoCache = true,
      bool autoInvalidateCache = true,
    }) {
      final items = defaultItems.toList();

      return LdListController(
        LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: fetchListWithParameters ??
              (parameters) async {
                final start = parameters.offset;
                final end = (start + parameters.pageSize < items.length) ? start + parameters.pageSize : items.length;
                return LdListPage<_TestItem>(
                  newItems: start < items.length ? items.sublist(start, end) : [],
                  hasMore: end < items.length,
                  total: items.length,
                );
              },
          getById: getById ?? (context, id) async => items.firstWhere((item) => item.id == id),
          getOffsetByIdFn: getOffsetById,
          deleteItem: deleteItem,
          updateItem: updateItem,
          createItem: createItem,
          deleteBatchFn: deleteBatch,
          updateBatchFn: updateBatch,
          pageSize: pageSize,
          autoCache: autoCache,
          autoInvalidateCache: autoInvalidateCache,
        ),
      );
    }

    group('getById Method', () {
      testWidgets('retrieves item from server when not in cache', (tester) async {
        var callCount = 0;
        final repository = createRepository(
          getById: (context, id) async {
            callCount++;
            return _TestItem(id, 'Server Item', 200);
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        final item = await repository.getById(ctx, 99);
        expect(callCount, equals(1));
        expect(item.id, equals(99));
        expect(item.name, equals('Server Item'));
      });

      testWidgets('retrieves item bypassing cache when skipCache is true', (tester) async {
        var callCount = 0;
        final repository = createRepository(
          getById: (context, id) async {
            callCount++;
            return _TestItem(id, 'Fetched Item', 100);
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        final item = await repository.getById(ctx, 1, skipCache: true);
        expect(callCount, equals(1));
        expect(item.name, equals('Fetched Item'));
      });
    });

    group('CRUD Operations - Create', () {
      testWidgets('creates item successfully', (tester) async {
        var createCallCount = 0;
        final repository = createRepository(
          createItem: (context, item) async {
            createCallCount++;
            return item!.copyWith(id: 100);
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.model.create(ctx, newItem);

        expect(createCallCount, equals(1));
        expect(createdItem, isNotNull);
        expect(createdItem.id, equals(100));
      });

      testWidgets('creates item with index parameter', (tester) async {
        final repository = createRepository(
          createItem: (context, item) async => item!.copyWith(id: 200),
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.model.create(ctx, newItem, index: 0);

        expect(createdItem, isNotNull);
      });

      testWidgets('handles creation error and rolls back', (tester) async {
        final repository = createRepository(
          createItem: (context, item) async {
            throw Exception('Creation failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        await expectLater(
          repository.model.create(ctx, newItem),
          throwsA(isA<Exception>()),
        );

        await tester.pump();
        final item = repository.getItemById(newItem.id);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackCreation));
      });

      testWidgets('throws assertion error when createItem callback is null', (tester) async {
        final repository = createRepository(createItem: null);

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        expect(() => repository.model.create(ctx, newItem), throwsAssertionError);
      });
    });

    group('CRUD Operations - Update', () {
      testWidgets('updates single item successfully', (tester) async {
        var updateCallCount = 0;
        final repository = createRepository(
          updateItem: (context, id, newItem) async {
            updateCallCount++;
            return newItem.copyWith(name: 'Updated ${newItem.name}');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.model.update(ctx, 1, updatedItem);

        expect(updateCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Updated Item 1'));
      });

      testWidgets('updates item with null return from server', (tester) async {
        final repository = createRepository(
          updateItem: (context, id, newItem) async => null,
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.model.update(ctx, 1, updatedItem);

        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Item 1'));
      });

      testWidgets('handles update error and rolls back', (tester) async {
        final repository = createRepository(
          updateItem: (context, id, newItem) async {
            throw Exception('Update failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await expectLater(() => repository.model.update(ctx, 1, updatedItem), throwsException);

        await tester.pump();

        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackUpdate));
      });

      testWidgets('updates batch with updateBatch callback', (tester) async {
        var updateBatchCallCount = 0;
        final repository = createRepository(
          updateBatch: (context, items) async {
            updateBatchCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          1: _TestItem(1, 'Updated 1', 15),
          2: _TestItem(2, 'Updated 2', 25),
        };
        await repository.model.updateBatch(ctx, itemsToUpdate);

        expect(updateBatchCallCount, equals(1));
      });

      testWidgets('updates batch without updateBatch callback uses updateItem', (tester) async {
        var updateItemCallCount = 0;
        final repository = createRepository(
          updateBatch: null,
          updateItem: (context, id, newItem) async {
            updateItemCallCount++;
            return newItem;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          1: _TestItem(1, 'Updated 1', 15),
          2: _TestItem(2, 'Updated 2', 25),
        };
        await repository.model.updateBatch(ctx, itemsToUpdate);

        expect(updateItemCallCount, equals(2));
      });

      testWidgets('handles batch update errors and rolls back', (tester) async {
        var rollbackCount = 0;
        final repository = createRepository(
          updateBatch: (context, items) async {
            rollbackCount = items.length;
            throw Exception('Batch update failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          1: _TestItem(1, 'Updated 1', 15),
          2: _TestItem(2, 'Updated 2', 25),
        };

        expect(() => repository.model.updateBatch(ctx, itemsToUpdate), throwsException);

        await tester.pump();
        final item1 = repository.getItemById(1);
        final item2 = repository.getItemById(2);
        expect(item1?.state, equals(LdPaginatorItemState.rolledBackUpdate));
        expect(item2?.state, equals(LdPaginatorItemState.rolledBackUpdate));
        expect(rollbackCount, equals(2));
      });
    });

    group('CRUD Operations - Delete', () {
      testWidgets('deletes single item successfully', (tester) async {
        var deleteCallCount = 0;
        final repository = createRepository(
          deleteItem: (context, id) async {
            deleteCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.model.delete(context: ctx, id: 1);

        expect(deleteCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.deleted));
      });

      testWidgets('handles deletion error and rolls back', (tester) async {
        final repository = createRepository(
          deleteItem: (context, id) async {
            throw Exception('Delete failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await expectLater(
          () => repository.model.delete(context: ctx, id: 1),
          throwsException,
        );

        await tester.pump();
        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackDeletion));
      });

      testWidgets('does nothing when deleteItem callback is null', (tester) async {
        final repository = createRepository(deleteItem: null);

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.model.delete(context: ctx, id: 1);

        final item = repository.getItemById(1);
        expect(item, isNotNull);
      });

      testWidgets('deletes batch with deleteBatch callback', (tester) async {
        var deleteBatchCallCount = 0;
        final repository = createRepository(
          deleteBatch: (context, ids) async {
            deleteBatchCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.model.deleteBatch(context: ctx, ids: {1, 2});

        expect(deleteBatchCallCount, equals(1));
        expect(repository.getItemById(1)?.state, equals(LdPaginatorItemState.deleted));
        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleted));
      });

      testWidgets('deletes batch without deleteBatch callback calls delete individually', (tester) async {
        var deleteCallCount = 0;
        final repository = createRepository(
          deleteBatch: null,
          deleteItem: (context, id) async {
            deleteCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.model.deleteBatch(context: ctx, ids: {1, 2});

        expect(deleteCallCount, equals(2));
      });

      testWidgets('deletes batch including detached selection items', (tester) async {
        var currentItems = defaultItems.toList();
        final repository = LdListController(LdCallbackModel<_TestItem, int>(
          pageSize: 1,
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, currentItems.length);
            return LdListPage<_TestItem>(
              newItems: start < currentItems.length ? currentItems.sublist(start, end) : [],
              hasMore: end < currentItems.length,
              total: currentItems.length,
            );
          },
          getById: (context, id) async => currentItems.firstWhere((item) => item.id == id),
          getOffsetByIdFn: (parameters) async {
            return currentItems.indexWhere((item) => item.id == parameters.id);
          },
          deleteItem: (context, id) async {
            currentItems.removeWhere((item) => item.id == id);
          },
        ));

        final ctx = await _pumpAndGetContext(tester);

        await tester.pumpAndSettle(const Duration(seconds: 1));
        await repository.loadViewingItem(ctx, 2);
        await repository.loadViewingItem(ctx, 3);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await repository.model.deleteBatch(context: ctx, ids: {1, 2, 3});
        await tester.pump();

        // Item 1 was never loaded into the controller, so it stays unknown (null).
        expect(repository.getItemById(1), isNull);
        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleted));
        expect(repository.getItemById(3)?.state, equals(LdPaginatorItemState.deleted));
        expect(currentItems, isEmpty);
      });

      testWidgets('does not overwrite deleting items during page fetch', (tester) async {
        var currentItems = defaultItems.toList();
        final repository = LdListController(LdCallbackModel<_TestItem, int>(
          pageSize: 3,
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, currentItems.length);
            return LdListPage<_TestItem>(
              newItems: start < currentItems.length ? currentItems.sublist(start, end) : [],
              hasMore: end < currentItems.length,
              total: currentItems.length,
            );
          },
          getById: (context, id) async => currentItems.firstWhere((item) => item.id == id),
          deleteItem: (context, id) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            currentItems.removeWhere((item) => item.id == id);
          },
        ));

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final deleteFuture = repository.model.delete(context: ctx, id: 2);
        await tester.pump();

        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleting));

        await repository.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.refresh);
        await tester.pump();

        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleting));

        await tester.pump(const Duration(milliseconds: 100));
        await deleteFuture;
        await tester.pump();

        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleted));
      });

      testWidgets('handles batch deletion errors and refreshes list', (tester) async {
        final repository = createRepository(
          deleteBatch: (context, ids) async {
            throw Exception('Batch delete failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        // batch delete throws, but shouldn't crash entirely
        try {
          await repository.model.deleteBatch(context: ctx, ids: {1, 2});
        } catch (_) {}

        await tester.pumpAndSettle(const Duration(seconds: 1));
        // Repository should still have items (refreshed after error)
        expect(repository.itemsMap, isNotEmpty);
      });

      testWidgets('partial deleteBatch success: confirms succeeded, rolls back failed', (tester) async {
        // Manage a mutable backing store so refreshes reflect real deletions.
        final currentItems = [_TestItem(1, 'Item 1', 10), _TestItem(2, 'Item 2', 20)];

        final repository = LdListController(
          LdCallbackModel<_TestItem, int>(
            pageSize: 10,
            fetchListWithParameters: (parameters) async {
              final start = parameters.offset;
              final end = (start + parameters.pageSize).clamp(0, currentItems.length);
              return LdListPage<_TestItem>(
                newItems: start < currentItems.length ? currentItems.sublist(start, end) : [],
                hasMore: end < currentItems.length,
                total: currentItems.length,
              );
            },
            getById: (context, id) async => currentItems.firstWhere((item) => item.id == id),
            deleteItem: (context, id) async {
              if (id == 2) throw Exception('delete failed for id $id');
              currentItems.removeWhere((item) => item.id == id);
            },
          ),
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        expect(repository.getItemById(1), isNotNull);
        expect(repository.getItemById(2), isNotNull);

        // deleteBatch with no deleteBatchFn falls back to per-item deletes.
        // The controller re-throws the cause of any partial failure.
        try {
          await repository.model.deleteBatch(context: ctx, ids: {1, 2});
        } catch (_) {
          // expected: partial failure throws for the failed item
        }

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Item 1 succeeded — must be removed from the controller.
        expect(repository.getItemById(1), isNull);
        // Item 2 failed — must still be present (rolled back).
        expect(repository.getItemById(2), isNotNull);
      });
    });

    group('initWithSelection', () {
      testWidgets('anchors list when getOffsetById is provided', (tester) async {
        var getOffsetCallCount = 0;
        var fetchCallCount = 0;
        final repository = LdListController(LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            fetchCallCount++;
            return LdListPage<_TestItem>(
              newItems: [_TestItem(2, 'Item 2', 20)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (context, id) async => _TestItem(id, 'Test', 0),
          getOffsetByIdFn: (parameters) async {
            getOffsetCallCount++;
            return 1; // Item at offset 1
          },
        ));

        final ctx = await _pumpAndGetContext(tester);
        await repository.initWithSelection(ctx, {2});
        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(getOffsetCallCount, equals(1));
        expect(fetchCallCount, greaterThan(0));
        expect(repository.initialOffset, equals(1));
      });

      testWidgets('handles null return from getOffsetById', (tester) async {
        final repository = LdListController(LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (context, id) async => _TestItem(id, 'Test', 0),
          getOffsetByIdFn: (parameters) async => null,
        ));

        final ctx = await _pumpAndGetContext(tester);
        await repository.initWithSelection(ctx, {99});

        expect(repository.initialOffset, equals(0));
      });

      testWidgets('does nothing when getOffsetById is null', (tester) async {
        final repository = createRepository(getOffsetById: null);

        final ctx = await _pumpAndGetContext(tester);
        await repository.initWithSelection(ctx, {1});

        // Should complete without error
        expect(repository.initialOffset, equals(0));
      });
    });

    group('loadViewingItem', () {
      testWidgets('loads detached item and notifies stream listeners', (tester) async {
        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 1,
          fetchListWithParameters: (parameters) async {
            return LdListPage<_TestItem>(
              newItems: [_TestItem(1, 'Item 1', 10)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (context, id) async => _TestItem(id, 'Detached $id', id * 10),
        ));

        final ctx = await _pumpAndGetContext(tester);
        final loaded = await repository.loadViewingItem(ctx, 99);

        expect(loaded.id, equals(99));
        expect(repository.getItemById(99)?.value?.name, equals('Detached 99'));
      });

      testWidgets('rethrows when getById fails', (tester) async {
        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (context, id) async => throw StateError('No element'),
        ));

        final ctx = await _pumpAndGetContext(tester);

        await expectLater(
          repository.loadViewingItem(ctx, 99),
          throwsA(isA<StateError>()),
        );
        expect(repository.getItemById(99), isNull);
      });

      testWidgets('returns cached item without calling getById again', (tester) async {
        var getByIdCallCount = 0;
        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            return LdListPage<_TestItem>(
              newItems: [_TestItem(1, 'Item 1', 10)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (context, id) async {
            getByIdCallCount++;
            return _TestItem(id, 'Item $id', id * 10);
          },
        ));

        final ctx = await _pumpAndGetContext(tester);
        await repository.loadViewingItem(ctx, 1);
        await repository.loadViewingItem(ctx, 1);

        expect(getByIdCallCount, equals(1));
      });
    });

    group('refresh behavior', () {
      testWidgets('refreshList applies server order after backend reorder', (tester) async {
        var serverItems = <_TestItem>[
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          pageSize: 3,
          fetchListWithParameters: (parameters) async {
            final end = (parameters.offset + parameters.pageSize).clamp(0, serverItems.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < serverItems.length ? serverItems.sublist(parameters.offset, end) : [],
              hasMore: end < serverItems.length,
              total: serverItems.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final firstOrder = repository.itemsMap.entries.map((e) => e.value.value?.id).toList();
        expect(firstOrder, equals([1, 2, 3]));

        serverItems = <_TestItem>[
          _TestItem(3, 'Item 3', 30),
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
        ];

        await repository.refreshList(context: ctx, reason: LdFetchReason.refresh);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final refreshedOrder = repository.itemsMap.entries.map((e) => e.value.value?.id).toList();
        expect(refreshedOrder, equals([3, 1, 2]));
      });

      testWidgets('refreshList keeps current anchor by resolving offset', (tester) async {
        var resolvedOffset = 4;
        final serverItems = List.generate(12, (index) => _TestItem(index + 1, 'Item ${index + 1}', index + 1));
        final requestedOffsets = <int>[];
        final repository = createRepository(
          pageSize: 2,
          getOffsetById: (parameters) async => resolvedOffset,
          fetchListWithParameters: (parameters) async {
            requestedOffsets.add(parameters.offset);
            final end = (parameters.offset + parameters.pageSize).clamp(0, serverItems.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < serverItems.length ? serverItems.sublist(parameters.offset, end) : [],
              hasMore: end < serverItems.length,
              total: serverItems.length,
            );
          },
        );
        repository.initialOffset = 4;

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(requestedOffsets.last, equals(4));
        expect(repository.getItemAt(4)?.value?.id, equals(5));

        resolvedOffset = 8;
        await repository.refreshList(context: ctx, reason: LdFetchReason.refresh);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.initialOffset, equals(8));
        expect(requestedOffsets, contains(8));
        expect(requestedOffsets, containsAll([6, 8, 10]));
        expect(repository.getItemAt(8)?.value?.id, equals(9));
      });

      testWidgets('refreshList falls back to initialOffset when offset lookup is null', (tester) async {
        final requestedOffsets = <int>[];
        final serverItems = List.generate(6, (index) => _TestItem(index + 1, 'Item ${index + 1}', index + 1));
        final repository = createRepository(
          pageSize: 2,
          getOffsetById: (parameters) async => null,
          fetchListWithParameters: (parameters) async {
            requestedOffsets.add(parameters.offset);
            final end = (parameters.offset + parameters.pageSize).clamp(0, serverItems.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < serverItems.length ? serverItems.sublist(parameters.offset, end) : [],
              hasMore: end < serverItems.length,
              total: serverItems.length,
            );
          },
        );
        repository.initialOffset = 2;

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(requestedOffsets.last, equals(2));
        expect(repository.initialOffset, equals(2));
      });

      testWidgets('refreshList clears stale pages so old page order is not reused', (tester) async {
        var serverItems = <_TestItem>[
          _TestItem(1, 'Item 1', 1),
          _TestItem(2, 'Item 2', 2),
          _TestItem(3, 'Item 3', 3),
          _TestItem(4, 'Item 4', 4),
          _TestItem(5, 'Item 5', 5),
          _TestItem(6, 'Item 6', 6),
        ];
        final repository = createRepository(
          pageSize: 3,
          fetchListWithParameters: (parameters) async {
            final end = (parameters.offset + parameters.pageSize).clamp(0, serverItems.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < serverItems.length ? serverItems.sublist(parameters.offset, end) : [],
              hasMore: end < serverItems.length,
              total: serverItems.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await repository.fetchPageAtOffset(ctx, 3);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final initialSecondPage = [3, 4, 5].map((index) => repository.getItemAt(index)?.value?.id).toList();
        expect(initialSecondPage, equals([4, 5, 6]));

        serverItems = <_TestItem>[
          _TestItem(1, 'Item 1', 1),
          _TestItem(2, 'Item 2', 2),
          _TestItem(3, 'Item 3', 3),
          _TestItem(6, 'Item 6', 6),
          _TestItem(5, 'Item 5', 5),
          _TestItem(4, 'Item 4', 4),
        ];

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await repository.fetchPageAtOffset(ctx, 3);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final refreshedSecondPage = [3, 4, 5].map((index) => repository.getItemAt(index)?.value?.id).toList();
        expect(refreshedSecondPage, equals([6, 5, 4]));
      });
    });

    group('fetch reason and cache', () {
      testWidgets('filter refresh passes filter reason and resets view', (tester) async {
        final reasons = <LdFetchReason>[];
        final repository = createRepository(
          pageSize: 2,
          fetchListWithParameters: (parameters) async {
            reasons.add(parameters.reason);
            final items = defaultItems;
            final end = (parameters.offset + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < items.length ? items.sublist(parameters.offset, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await repository.fetchPageAtOffset(ctx, 2);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await repository.refreshList(context: ctx, reason: LdFetchReason.filter);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(reasons.last, equals(LdFetchReason.filter));
        expect(repository.getItemAt(0)?.value?.id, equals(1));
        expect(repository.getItemAt(2), isNull);
      });

      testWidgets('fetch exposes repository cache to fetchListWithParameters', (tester) async {
        final repository = createRepository(
          fetchListWithParameters: (parameters) async {
            parameters.cache.writePage(
              'seen',
              offset: 0,
              items: [_TestItem(99, 'cached', 0)],
              total: 1,
            );
            return LdListPage<_TestItem>(
              newItems: defaultItems,
              hasMore: false,
              total: defaultItems.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.cache.readPage('seen', 0)?.first.id, equals(99));
      });

      testWidgets('auto-invalidate clears cache on refresh', (tester) async {
        var fetchCount = 0;
        final repository = createRepository(
          pageSize: 2,
          fetchListWithParameters: (parameters) async {
            fetchCount++;
            final items = defaultItems;
            final end = (parameters.offset + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < items.length ? items.sublist(parameters.offset, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(1));

        await repository.fetchPageAtOffset(ctx, 2, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(2));

        await repository.fetchPageAtOffset(ctx, 2, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(2));

        await repository.refreshList(context: ctx, reason: LdFetchReason.refresh);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(3));

        await repository.fetchPageAtOffset(ctx, 2, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(4));
      });

      testWidgets('auto-read returns cached page without calling user fetch', (tester) async {
        var fetchCount = 0;
        final repository = createRepository(
          pageSize: 2,
          fetchListWithParameters: (parameters) async {
            fetchCount++;
            final items = defaultItems;
            final end = (parameters.offset + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < items.length ? items.sublist(parameters.offset, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(1));

        await repository.fetchPageAtOffset(ctx, 0, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(1));
      });

      testWidgets('auto-write stores page and second pagination hit uses cache', (tester) async {
        var fetchCount = 0;
        final repository = createRepository(
          pageSize: 1,
          fetchListWithParameters: (parameters) async {
            fetchCount++;
            final items = defaultItems;
            final end = (parameters.offset + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < items.length ? items.sublist(parameters.offset, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(1));

        await repository.fetchPageAtOffset(ctx, 1, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(2));

        await repository.fetchPageAtOffset(ctx, 1, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(fetchCount, equals(2));
      });

      testWidgets('autoCache false skips read and write', (tester) async {
        final repository = createRepository(
          pageSize: 2,
          autoCache: false,
          fetchListWithParameters: (parameters) async {
            final items = defaultItems;
            final end = (parameters.offset + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < items.length ? items.sublist(parameters.offset, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);

        await repository.refreshList(context: ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(repository.cache.readPage('', 0), isNull);

        await repository.fetchPageAtOffset(ctx, 2, reason: LdFetchReason.pagination);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(repository.cache.readPage('', 2), isNull);
      });
    });

    group('mutation cache invalidation', () {
      Future<BuildContext> pumpContextWithSortFilter(
        WidgetTester tester,
        LdMonkeySortAndFilterState<_TestItem, int> sortAndFilterState,
      ) async {
        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              LiquidLocalizations.delegate,
            ],
            home: LdThemeProvider(
              child: Provider<LdMonkeySortAndFilterState<_TestItem, int>>.value(
                value: sortAndFilterState,
                child: Builder(
                  builder: (ctx) {
                    context = ctx;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        return context;
      }

      testWidgets('update removes only title-sort cache key', (tester) async {
        final sortAndFilterState = LdMonkeySortAndFilterState<_TestItem, int>(
          filters: {},
          sortOptions: [
            LdSortOption<_TestItem, int>(
              name: 'title',
              label: (_) => 'Title',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.name != after?.name,
            ),
            LdSortOption<_TestItem, int>(
              name: 'value',
              label: (_) => 'Value',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.value != after?.value,
            ),
          ],
        );

        final repository = createRepository(
          getOffsetById: (params) async => params.id - 1,
          updateItem: (context, id, newItem) async => newItem,
        );

        final ctx = await pumpContextWithSortFilter(tester, sortAndFilterState);
        await _loadRepository(tester, repository, ctx);

        const titleKey = 'sort:title=title-asc';
        const valueKey = 'sort:value=value-asc';
        repository.cache.writePage(
          titleKey,
          offset: 0,
          items: [_TestItem(1, 'Item 1', 10)],
          total: 3,
        );
        repository.cache.writePage(
          valueKey,
          offset: 0,
          items: [_TestItem(1, 'Item 1', 10)],
          total: 3,
        );

        await repository.model.update(ctx, 1, _TestItem(1, 'Renamed Item 1', 10));

        expect(repository.cache.readPage(titleKey, 0), isNull);
        expect(repository.cache.readPage(valueKey, 0), isNotNull);
      });

      testWidgets('create clears cached pages', (tester) async {
        final repository = createRepository(
          createItem: (context, item) async => item!.copyWith(id: 100),
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);
        repository.cache.writePage(
          'stale',
          offset: 0,
          items: defaultItems,
          total: defaultItems.length,
        );

        await repository.model.create(ctx, _TestItem(0, 'New Item', 50));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.cache.readPage('stale', 0), isNull);
      });

      testWidgets('cache is NOT invalidated when update persist fails', (tester) async {
        final repository = createRepository(
          getOffsetById: (params) async => params.id - 1,
          updateItem: (context, id, newItem) async {
            throw Exception('Update failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        const cacheKey = 'keep-this';
        repository.cache.writePage(
          cacheKey,
          offset: 0,
          items: defaultItems,
          total: defaultItems.length,
        );

        await expectLater(
          () => repository.model.update(ctx, 1, _TestItem(1, 'Updated', 99)),
          throwsException,
        );

        // Cache must NOT have been cleared — persist never succeeded.
        expect(repository.cache.readPage(cacheKey, 0), isNotNull);
      });
    });

    group('greedy repository', () {
      testWidgets('ensureGreedyLoaded fetches all pages once', (tester) async {
        var fetchCount = 0;
        final repository = LdListController.fromModel(LdCallbackModel.greedy<_TestItem, int>(
          pageSize: 2,
          getById: (context, id) async => _TestItem(id, 'Item $id', id),
          fetchListWithParameters: (parameters) async {
            fetchCount++;
            final all = List.generate(5, (index) => _TestItem(index + 1, 'Item ${index + 1}', index + 1));
            final end = (parameters.offset + parameters.pageSize).clamp(0, all.length);
            return LdListPage<_TestItem>(
              newItems: parameters.offset < all.length ? all.sublist(parameters.offset, end) : [],
              hasMore: end < all.length,
              total: all.length,
            );
          },
        ));

        final ctx = await _pumpAndGetContext(tester);

        await repository.ensureGreedyLoaded(ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(fetchCount, equals(3));
        expect(repository.isDataComplete, isTrue);
        expect(repository.totalItems, equals(5));
        expect(repository.getItemAt(4)?.value?.id, equals(5));

        await repository.ensureGreedyLoaded(ctx);
        expect(fetchCount, equals(3));
      });

      testWidgets('fromList uses greedy loading', (tester) async {
        final repository = LdListController.fromModel(LdCallbackModel.fromList<_TestItem, int>(
          list: defaultItems,
        ));

        final ctx = await _pumpAndGetContext(tester);
        await repository.ensureGreedyLoaded(ctx);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.isGreedy, isTrue);
        expect(repository.isDataComplete, isTrue);
        expect(repository.totalItems, equals(3));
      });
    });

    group('mutation layout', () {
      testWidgets('create repositions item when getOffsetById is configured', (tester) async {
        final items = List.generate(10, (i) => _TestItem(i + 1, 'Item ${i + 1}', i + 1));
        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 5,
          getOffsetByIdFn: (params) async => items.indexWhere((item) => item.id == params.id),
          createItem: (context, item) async {
            final created = _TestItem(11, 'New Item', 11);
            items.add(created);
            items.sort((a, b) => a.value.compareTo(b.value));
            return created;
          },
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : <_TestItem>[],
              hasMore: end < items.length,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ));

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.model.create(ctx, _TestItem(0, 'New Item', 11));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final expectedIndex = items.indexWhere((item) => item.id == 11);
        expect(repository.getItemIndexById(11), equals(expectedIndex));
      });

      test('canCompactIndicesAfterDeletion requires contiguous loaded indices', () {
        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          fetchListWithParameters: (_) async => LdListPage<_TestItem>(
            newItems: const [],
            hasMore: false,
            total: 0,
          ),
          getById: (context, id) async => _TestItem(id, 'Item $id', id),
        ));

        repository.replaceItems({
          0: LdPaginatorItem(value: _TestItem(1, 'Item 1', 1), state: LdPaginatorItemState.loaded),
          1: LdPaginatorItem(value: _TestItem(2, 'Item 2', 2), state: LdPaginatorItemState.loaded),
          2: LdPaginatorItem(value: _TestItem(3, 'Item 3', 3), state: LdPaginatorItemState.loaded),
          10: LdPaginatorItem(value: _TestItem(11, 'Item 11', 11), state: LdPaginatorItemState.loaded),
        });
        repository.totalItems = 15;

        expect(repository.canCompactIndicesAfterDeletion(1), isFalse);
        expect(repository.canCompactIndicesAfterDeletion(9), isTrue);
      });

      testWidgets('update keeps index when layout is not affected', (tester) async {
        final sortAndFilterState = LdMonkeySortAndFilterState<_TestItem, int>(
          filters: {},
          sortOptions: [
            LdSortOption<_TestItem, int>(
              name: 'value',
              label: (_) => 'Value',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.value != after?.value,
            ),
          ],
        );

        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: LdThemeProvider(
              child: Provider<LdMonkeySortAndFilterState<_TestItem, int>>.value(
                value: sortAndFilterState,
                child: Builder(
                  builder: (context) {
                    ctx = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final repository = createRepository(
          getOffsetById: (params) async => params.id - 1,
          updateItem: (context, id, newItem) async => newItem,
        );
        await _loadRepository(tester, repository, ctx);

        const indexBefore = 0;
        expect(repository.getItemIndexById(1), equals(indexBefore));

        await repository.model.update(
          ctx,
          1,
          _TestItem(1, 'Renamed Item 1', 10),
        );
        await tester.pumpAndSettle();

        expect(repository.getItemIndexById(1), equals(indexBefore));
        expect(repository.getItemById(1)?.value?.name, equals('Renamed Item 1'));
      });

      testWidgets('update repositions item when sort layout is affected', (tester) async {
        final items = List.generate(5, (i) => _TestItem(i + 1, 'Item ${i + 1}', i + 1));
        final sortAndFilterState = LdMonkeySortAndFilterState<_TestItem, int>(
          filters: {},
          sortOptions: [
            LdSortOption<_TestItem, int>(
              name: 'value',
              label: (_) => 'Value',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.value != after?.value,
            ),
          ],
        );

        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: LdThemeProvider(
              child: Provider<LdMonkeySortAndFilterState<_TestItem, int>>.value(
                value: sortAndFilterState,
                child: Builder(
                  builder: (context) {
                    ctx = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 5,
          getOffsetByIdFn: (params) async => items.indexWhere((item) => item.id == params.id),
          updateItem: (context, id, newItem) async {
            final index = items.indexWhere((item) => item.id == id);
            items[index] = newItem;
            items.sort((a, b) => a.value.compareTo(b.value));
            return newItem;
          },
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : <_TestItem>[],
              hasMore: end < items.length,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ));

        await _loadRepository(tester, repository, ctx);

        await repository.model.update(ctx, 1, _TestItem(1, 'Item 1', 99));
        await tester.pumpAndSettle();

        expect(repository.getItemIndexById(1), equals(items.length - 1));
      });

      testWidgets('update closes the source gap without dropping other items', (tester) async {
        final items = List.generate(5, (i) => _TestItem(i + 1, 'Item ${i + 1}', i + 1));
        final sortAndFilterState = LdMonkeySortAndFilterState<_TestItem, int>(
          filters: {},
          sortOptions: [
            LdSortOption<_TestItem, int>(
              name: 'value',
              label: (_) => 'Value',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.value != after?.value,
            ),
          ],
        );

        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: LdThemeProvider(
              child: Provider<LdMonkeySortAndFilterState<_TestItem, int>>.value(
                value: sortAndFilterState,
                child: Builder(
                  builder: (context) {
                    ctx = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 10,
          getOffsetByIdFn: (params) async => items.indexWhere((item) => item.id == params.id),
          updateItem: (context, id, newItem) async {
            final index = items.indexWhere((item) => item.id == id);
            items[index] = newItem;
            items.sort((a, b) => a.value.compareTo(b.value));
            return newItem;
          },
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : <_TestItem>[],
              hasMore: end < items.length,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ));

        await _loadRepository(tester, repository, ctx);

        // Move item 1 (index 0) to the end. All five items are loaded, so the
        // shift must stay local and keep every item present in order.
        await repository.model.update(ctx, 1, _TestItem(1, 'Item 1', 99));
        await tester.pumpAndSettle();

        expect(repository.totalItems, equals(5));
        expect(
          List.generate(5, (i) => repository.getItemAt(i)?.value?.id),
          equals([2, 3, 4, 5, 1]),
        );
      });

      testWidgets('update closes gaps when item moves beyond the loaded range', (tester) async {
        final items = List.generate(30, (i) => _TestItem(i + 1, 'Item ${i + 1}', i + 1));
        final fetchedOffsets = <int>[];
        final sortAndFilterState = LdMonkeySortAndFilterState<_TestItem, int>(
          filters: {},
          sortOptions: [
            LdSortOption<_TestItem, int>(
              name: 'value',
              label: (_) => 'Value',
              icon: (_) => const SizedBox.shrink(),
              isOn: true,
              affectedByUpdate: (before, after) => before?.value != after?.value,
            ),
          ],
        );

        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: LdThemeProvider(
              child: Provider<LdMonkeySortAndFilterState<_TestItem, int>>.value(
                value: sortAndFilterState,
                child: Builder(
                  builder: (context) {
                    ctx = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 10,
          getOffsetByIdFn: (params) async => items.indexWhere((item) => item.id == params.id),
          updateItem: (context, id, newItem) async {
            final index = items.indexWhere((item) => item.id == id);
            items[index] = newItem;
            items.sort((a, b) => a.value.compareTo(b.value));
            return newItem;
          },
          fetchListWithParameters: (parameters) async {
            fetchedOffsets.add(parameters.offset);
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : <_TestItem>[],
              hasMore: end < items.length,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ));

        await _loadRepository(tester, repository, ctx);

        // Only the first page (indices 0-9) is loaded.
        expect(repository.getItemIndexById(3), equals(2));
        expect(repository.getItemAt(9)?.value?.id, equals(10));
        expect(repository.getItemAt(20), isNull);

        // Move item 3 to the very end. The destination (index 29) lives outside
        // the loaded range; the shift must keep the loaded items consistent with
        // the new server order and leave no orphaned gap at the source.
        await repository.model.update(ctx, 3, _TestItem(3, 'Item 3', 100));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.totalItems, equals(30));
        expect(repository.getItemById(3)?.value?.value, equals(100));
        expect(repository.getItemIndexById(3), equals(29));

        // The source gap is closed by shifting the trailing loaded items up, so
        // the item that followed the moved one (id 4) now sits at index 2.
        expect(repository.getItemAt(2)?.value?.id, equals(4));

        // Index 9 now refers to a genuinely unloaded item (id 11). It is a gap
        // rather than a stale duplicate, and it must be refetchable.
        expect(repository.getItemAt(9), isNull);

        fetchedOffsets.clear();
        await repository.fetchPageAtOffset(ctx, 9);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(fetchedOffsets, contains(0));
        expect(repository.getItemAt(9)?.value?.id, equals(11));
      });

      testWidgets('create refreshes list when getOffsetById is not configured', (tester) async {
        final items = defaultItems.toList();
        final fetchReasons = <LdFetchReason>[];

        final repository = createRepository(
          createItem: (context, item) async {
            final created = _TestItem(4, 'New Item', 40);
            items.add(created);
            return created;
          },
          fetchListWithParameters: (parameters) async {
            fetchReasons.add(parameters.reason);
            final start = parameters.offset;
            final end = (start + parameters.pageSize < items.length) ? start + parameters.pageSize : items.length;
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);
        fetchReasons.clear();

        await repository.model.create(ctx, _TestItem(0, 'New Item', 40));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(fetchReasons, contains(LdFetchReason.invalidate));
        expect(repository.getItemById(4)?.value?.name, equals('New Item'));
      });

      testWidgets('delete with sparse map gaps refreshes instead of shifting', (tester) async {
        final items = defaultItems.toList();
        final fetchReasons = <LdFetchReason>[];
        final repository = createRepository(
          deleteItem: (context, id) async {
            items.removeWhere((item) => item.id == id);
          },
          fetchListWithParameters: (parameters) async {
            fetchReasons.add(parameters.reason);
            final start = parameters.offset;
            final end = (start + parameters.pageSize < items.length) ? start + parameters.pageSize : items.length;
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : [],
              hasMore: end < items.length,
              total: items.length,
            );
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        repository.replaceItems({
          0: LdPaginatorItem(value: defaultItems[0], state: LdPaginatorItemState.loaded),
          1: LdPaginatorItem(value: defaultItems[1], state: LdPaginatorItemState.loaded),
          2: LdPaginatorItem(value: defaultItems[2], state: LdPaginatorItemState.loaded),
          10: LdPaginatorItem(value: _TestItem(11, 'Item 11', 11), state: LdPaginatorItemState.loaded),
        });
        repository.totalItems = 12;
        fetchReasons.clear();

        await repository.model.delete(context: ctx, id: 2);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(fetchReasons, contains(LdFetchReason.invalidate));
        expect(repository.getItemById(2)?.state, equals(LdPaginatorItemState.deleted));
      });
    });

    group('reorder', () {
      testWidgets('reorder shuffles indices and updates without getOffsetById', (tester) async {
        final items = List.generate(4, (index) => _TestItem(index + 1, 'Item ${index + 1}', index + 1));
        var updateCalls = 0;
        var getOffsetCalls = 0;

        final repository = LdListController.fromModel(LdCallbackModel<_TestItem, int>(
          pageSize: 10,
          initialItems: items,
          getOffsetByIdFn: (params) async {
            getOffsetCalls++;
            return items.indexWhere((item) => item.id == params.id);
          },
          updateItem: (context, id, newItem) async {
            updateCalls++;
            final index = items.indexWhere((item) => item.id == id);
            items[index] = newItem;
            return newItem;
          },
          fetchListWithParameters: (parameters) async {
            final start = parameters.offset;
            final end = (start + parameters.pageSize).clamp(0, items.length);
            return LdListPage<_TestItem>(
              newItems: start < items.length ? items.sublist(start, end) : <_TestItem>[],
              hasMore: end < items.length,
              total: items.length,
            );
          },
          getById: (context, id) async => items.firstWhere((item) => item.id == id),
        ));

        final ctx = await _pumpAndGetContext(tester);

        await repository.reorder(
          ctx,
          id: 2,
          fromIndex: 1,
          toIndex: 3,
          reorderHandler: (context, item, from, to) async => item.copyWith(value: to),
        );
        await tester.pump();

        expect(updateCalls, equals(1));
        expect(getOffsetCalls, equals(0));
        expect(repository.getItemAt(0)?.value?.id, equals(1));
        expect(repository.getItemAt(1)?.value?.id, equals(3));
        expect(repository.getItemAt(2)?.value?.id, equals(4));
        expect(repository.getItemAt(3)?.value?.id, equals(2));
      });
    });
  });
}
