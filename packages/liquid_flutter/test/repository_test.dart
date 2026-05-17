import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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

// Mock filter option for testing
class _MockFilterOption<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  final String _serializedValue;

  _MockFilterOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    String serializedValue = 'mock',
  }) : _serializedValue = serializedValue;

  @override
  String serialize() => _serializedValue;

  @override
  LdFilterOption<T, IdType> marshalSerialized(String entry) {
    return copyWith(isOn: true);
  }

  @override
  LdFilterOption<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
  }) {
    return _MockFilterOption<T, IdType>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      serializedValue: _serializedValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

// Mock sort option for testing
class _MockSortOption<T extends Identifiable<IdType>, IdType> extends LdSortOption<T, IdType> {
  _MockSortOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
  });
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
  LdRepository<dynamic, dynamic> repository,
  BuildContext context,
) async {
  await repository.refreshList(context: context);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  group('LdRepository Tests', () {
    // Default test items
    final defaultItems = <_TestItem>[
      _TestItem(1, 'Item 1', 10),
      _TestItem(2, 'Item 2', 20),
      _TestItem(3, 'Item 3', 30),
    ];

    // Helper function to create a repository with mock functions
    LdRepository<_TestItem, int> createRepository({
      Future<LdListPage<_TestItem>> Function(FetchPageParameters<_TestItem, int> parameters)? fetchListWithParameters,
      Future<_TestItem> Function(int id)? getById,
      Future<int?> Function(FetchOffsetParameters<_TestItem, int> parameters)? getOffsetById,
      Future<void> Function(int id)? deleteItem,
      Future<_TestItem?> Function(int id, _TestItem newItem)? updateItem,
      Future<_TestItem?> Function(_TestItem? newItem)? createItem,
      Future<void> Function(Set<int> ids)? deleteBatch,
      Future<void> Function(Set<_TestItem> items)? updateBatch,
      int pageSize = 10,
    }) {
      final items = defaultItems.toList();

      return LdRepository<_TestItem, int>(
        fetchListWithParameters: fetchListWithParameters ??
            (parameters) async {
              final start = parameters.offset;
              final end = (start + parameters.pageSize < items.length)
                  ? start + parameters.pageSize
                  : items.length;
              return LdListPage<_TestItem>(
                newItems: start < items.length ? items.sublist(start, end) : [],
                hasMore: end < items.length,
                total: items.length,
              );
            },
        getById: getById ?? (id) async => items.firstWhere((item) => item.id == id),
        getOffsetById: getOffsetById,
        deleteItem: deleteItem,
        updateItem: updateItem,
        createItem: createItem,
        deleteBatch: deleteBatch,
        updateBatch: updateBatch,
        pageSize: pageSize,
      );
    }

    group('getById Method', () {
      test('retrieves item from server when not in cache', () async {
        var callCount = 0;
        final repository = createRepository(
          getById: (id) async {
            callCount++;
            return _TestItem(id, 'Server Item', 200);
          },
        );

        final item = await repository.getById(99);
        expect(callCount, equals(1));
        expect(item.id, equals(99));
        expect(item.name, equals('Server Item'));
      });

      test('retrieves item bypassing cache when skipCache is true', () async {
        var callCount = 0;
        final repository = createRepository(
          getById: (id) async {
            callCount++;
            return _TestItem(id, 'Fetched Item', 100);
          },
        );

        final item = await repository.getById(1, skipCache: true);
        expect(callCount, equals(1));
        expect(item.name, equals('Fetched Item'));
      });
    });

    group('CRUD Operations - Create', () {
      testWidgets('creates item successfully', (tester) async {
        var createCallCount = 0;
        final repository = createRepository(
          createItem: (item) async {
            createCallCount++;
            return item?.copyWith(id: 100);
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.create(newItem);

        expect(createCallCount, equals(1));
        expect(createdItem, isNotNull);
        expect(createdItem!.id, equals(100));
      });

      testWidgets('creates item with index parameter', (tester) async {
        final repository = createRepository(
          createItem: (item) async => item?.copyWith(id: 200),
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.create(newItem, index: 0);

        expect(createdItem, isNotNull);
      });

      testWidgets('handles creation error and rolls back', (tester) async {
        final repository = createRepository(
          createItem: (item) async {
            throw Exception('Creation failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        final result = await repository.create(newItem);

        expect(result, isNull);

        await tester.pump();
        final item = repository.getItemById(newItem.id);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackCreation));
      });

      testWidgets('throws assertion error when createItem callback is null', (tester) async {
        final repository = createRepository(createItem: null);

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final newItem = _TestItem(0, 'New Item', 50);
        expect(() => repository.create(newItem), throwsAssertionError);
      });
    });

    group('CRUD Operations - Update', () {
      testWidgets('updates single item successfully', (tester) async {
        var updateCallCount = 0;
        final repository = createRepository(
          updateItem: (id, newItem) async {
            updateCallCount++;
            return newItem.copyWith(name: 'Updated ${newItem.name}');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.update(1, updatedItem);

        expect(updateCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Updated Item 1'));
      });

      testWidgets('updates item with null return from server', (tester) async {
        final repository = createRepository(
          updateItem: (id, newItem) async => null,
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.update(1, updatedItem);

        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Item 1'));
      });

      testWidgets('handles update error and rolls back', (tester) async {
        final repository = createRepository(
          updateItem: (id, newItem) async {
            throw Exception('Update failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await expectLater(() => repository.update(1, updatedItem), throwsException);

        await tester.pump();

        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackUpdate));
      });

      testWidgets('updates batch with updateBatch callback', (tester) async {
        var updateBatchCallCount = 0;
        final repository = createRepository(
          updateBatch: (items) async {
            updateBatchCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };
        await repository.updateBatch(itemsToUpdate);

        expect(updateBatchCallCount, equals(1));
      });

      testWidgets('updates batch without updateBatch callback uses updateItem', (tester) async {
        var updateItemCallCount = 0;
        final repository = createRepository(
          updateBatch: null,
          updateItem: (id, newItem) async {
            updateItemCallCount++;
            return newItem;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };
        await repository.updateBatch(itemsToUpdate);

        expect(updateItemCallCount, equals(2));
      });

      testWidgets('handles batch update errors and rolls back', (tester) async {
        var rollbackCount = 0;
        final repository = createRepository(
          updateBatch: (items) async {
            rollbackCount = items.length;
            throw Exception('Batch update failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };

        expect(() => repository.updateBatch(itemsToUpdate), throwsException);

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
          deleteItem: (id) async {
            deleteCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.delete(context: ctx, id: 1);

        expect(deleteCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item, isNull);
      });

      testWidgets('handles deletion error and rolls back', (tester) async {
        final repository = createRepository(
          deleteItem: (id) async {
            throw Exception('Delete failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await expectLater(
          () => repository.delete(context: ctx, id: 1),
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

        await repository.delete(context: ctx, id: 1);

        final item = repository.getItemById(1);
        expect(item, isNotNull);
      });

      testWidgets('deletes batch with deleteBatch callback', (tester) async {
        var deleteBatchCallCount = 0;
        final repository = createRepository(
          deleteBatch: (ids) async {
            deleteBatchCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.deleteBatch(context: ctx, ids: {1, 2});

        expect(deleteBatchCallCount, equals(1));
        expect(repository.getItemById(1), isNull);
        expect(repository.getItemById(2), isNull);
      });

      testWidgets('deletes batch without deleteBatch callback calls delete individually', (tester) async {
        var deleteCallCount = 0;
        final repository = createRepository(
          deleteBatch: null,
          deleteItem: (id) async {
            deleteCallCount++;
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        await repository.deleteBatch(context: ctx, ids: {1, 2});

        expect(deleteCallCount, equals(2));
      });

      testWidgets('handles batch deletion errors and refreshes list', (tester) async {
        final repository = createRepository(
          deleteBatch: (ids) async {
            throw Exception('Batch delete failed');
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await _loadRepository(tester, repository, ctx);

        // batch delete throws, but shouldn't crash entirely
        try {
          await repository.deleteBatch(context: ctx, ids: {1, 2});
        } catch (_) {}

        await tester.pumpAndSettle(const Duration(seconds: 1));
        // Repository should still have items (refreshed after error)
        expect(repository.itemsMap, isNotEmpty);
      });
    });

    group('initWithSelection', () {
      testWidgets('initializes with selection when getOffsetById is provided', (tester) async {
        var getOffsetCallCount = 0;
        var fetchCallCount = 0;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            fetchCallCount++;
            return LdListPage<_TestItem>(
              newItems: [_TestItem(2, 'Item 2', 20)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          getOffsetById: (parameters) async {
            getOffsetCallCount++;
            return 1; // Item at offset 1
          },
        );

        final ctx = await _pumpAndGetContext(tester);
        await repository.initWithSelection(ctx, {2});
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(getOffsetCallCount, equals(1));
        expect(fetchCallCount, greaterThan(0));
        expect(repository.initialOffset, equals(1));
      });

      testWidgets('handles null return from getOffsetById', (tester) async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: (parameters) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          getOffsetById: (parameters) async => null,
        );

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
              newItems: parameters.offset < serverItems.length
                  ? serverItems.sublist(parameters.offset, end)
                  : [],
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

        // hard: true clears and re-fetches so the new server order is applied
        await repository.refreshList(context: ctx, hard: true);
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
              newItems: parameters.offset < serverItems.length
                  ? serverItems.sublist(parameters.offset, end)
                  : [],
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
        // hard: true re-fetches from the resolved anchor offset
        await repository.refreshList(context: ctx, hard: true);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(repository.initialOffset, equals(8));
        expect(requestedOffsets.last, equals(8));
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
              newItems: parameters.offset < serverItems.length
                  ? serverItems.sublist(parameters.offset, end)
                  : [],
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
              newItems: parameters.offset < serverItems.length
                  ? serverItems.sublist(parameters.offset, end)
                  : [],
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
  });
}
