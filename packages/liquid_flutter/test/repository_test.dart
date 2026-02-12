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
  final bool Function(T item) _optimisticFilterFunc;
  final String _serializedValue;

  _MockFilterOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required bool Function(T item) optimisticFilterFunc,
    String serializedValue = 'mock',
  })  : _optimisticFilterFunc = optimisticFilterFunc,
        _serializedValue = serializedValue;

  @override
  String serialize() => _serializedValue;

  @override
  LdFilterOption<T, IdType> marshalSerialized(String entry) {
    return copyWith(isOn: true);
  }

  @override
  bool optimisticFilter(T item) => _optimisticFilterFunc(item);

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
      optimisticFilterFunc: _optimisticFilterFunc,
      serializedValue: _serializedValue,
    );
  }

  @override
  Widget build(BuildContext context, LdRepository<T, IdType> repository) {
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
    super.optimisticSort,
  });
}

void main() {
  group('LdRepository Tests', () {
    // Helper function to create a repository with mock functions
    LdRepository<_TestItem, int> createRepository({
      bool autoLoad = false,
      Future<LdListPage<_TestItem>> Function({
        required int offset,
        required int pageSize,
        String? pageToken,
        Set<LdFilterOption<_TestItem, int>>? filters,
        List<LdSortOption<_TestItem, int>>? sortOptions,
      })? fetchListWithParameters,
      Future<_TestItem> Function(int id)? getById,
      Future<int?> Function(int id,
              {Set<LdFilterOption<_TestItem, int>>? filters, List<LdSortOption<_TestItem, int>>? sortOptions})?
          getOffsetById,
      Future<void> Function(int id)? deleteItem,
      Future<_TestItem?> Function(int id, _TestItem newItem)? updateItem,
      Future<_TestItem?> Function(_TestItem? newItem)? createItem,
      Future<void> Function(Set<int> ids)? deleteBatch,
      Future<void> Function(Set<_TestItem> items)? updateBatch,
      Set<LdFilterOption<_TestItem, int>>? filters,
      List<LdSortOption<_TestItem, int>>? sortOptions,
      int pageSize = 10,
      List<_TestItem>? initialItems,
    }) {
      final items = <_TestItem>[
        _TestItem(1, 'Item 1', 10),
        _TestItem(2, 'Item 2', 20),
        _TestItem(3, 'Item 3', 30),
      ];

      return LdRepository<_TestItem, int>(
        fetchListWithParameters: fetchListWithParameters ??
            ({
              required offset,
              required pageSize,
              pageToken,
              filters,
              sortOptions,
            }) async {
              await Future.delayed(const Duration(milliseconds: 10));
              final start = offset;
              final end = (start + pageSize < items.length) ? start + pageSize : items.length;
              return LdListPage<_TestItem>(
                newItems: start < items.length ? items.sublist(start, end) : [],
                hasMore: end < items.length,
                total: items.length,
              );
            },
        getById: getById ??
            (id) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return items.firstWhere((item) => item.id == id);
            },
        getOffsetById: getOffsetById,
        deleteItem: deleteItem,
        updateItem: updateItem,
        createItem: createItem,
        deleteBatch: deleteBatch,
        updateBatch: updateBatch,
        filters: filters,
        sortOptions: sortOptions,
        pageSize: pageSize,
      );
    }

    group('Constructor and Initialization', () {
      test('initializes with default titles', () {
        final repository = createRepository();
        expect(repository.singularItemTitle, equals('Item'));
        expect(repository.pluralItemTitle, equals('Items'));
      });

      test('initializes with custom titles', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          singularItemTitle: 'Task',
          pluralItemTitle: 'Tasks',
        );
        expect(repository.singularItemTitle, equals('Task'));
        expect(repository.pluralItemTitle, equals('Tasks'));
      });

      test('initializes filters correctly', () {
        final filter1 = _MockFilterOption<_TestItem, int>(
          name: 'filter1',
          label: (context) => 'Filter 1',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
        );
        final filter2 = _MockFilterOption<_TestItem, int>(
          name: 'filter2',
          label: (context) => 'Filter 2',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );

        final repository = createRepository(
          filters: {filter1, filter2},
        );

        expect(repository.filters.length, equals(2));
        expect(repository.filters['filter1'], isNotNull);
        expect(repository.filters['filter2'], isNotNull);
        expect(repository.filters['filter2']!.isOn, isTrue);
        expect(repository.activeFilters.length, equals(1));
      });

      test('initializes sortOptions correctly', () {
        final sort1 = _MockSortOption<_TestItem, int>(
          name: 'sort1',
          label: (context) => 'Sort 1',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );
        final sort2 = _MockSortOption<_TestItem, int>(
          name: 'sort2',
          label: (context) => 'Sort 2',
          icon: (context) => const Icon(Icons.sort),
          isOn: false,
        );

        final repository = createRepository(
          sortOptions: [sort1, sort2],
        );

        expect(repository.sortOptions.length, equals(2));
        expect(repository.sortOptions.where((s) => s.isOn).length, equals(1));
      });

      test('filter and sort streams are initialized', () {
        final repository = createRepository();
        expect(repository.filterStream, isNotNull);
        expect(repository.sortStream, isNotNull);
      });
    });

    group('getById Method', () {
      test('retrieves item from cache when available', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(initialItems: items);
        await Future.delayed(const Duration(milliseconds: 100));

        // Item should be in cache now
        final item = await repository.getById(1);
        expect(item.id, equals(1));
        expect(item.name, equals('Item 1'));
      });

      test('retrieves item bypassing cache when skipCache is true', () async {
        var callCount = 0;
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          getById: (id) async {
            callCount++;
            return _TestItem(id, 'Fetched Item', 100);
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final item = await repository.getById(1, skipCache: true);
        expect(callCount, equals(1));
        expect(item.name, equals('Fetched Item'));
      });

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
    });

    group('CRUD Operations - Create', () {
      test('creates item successfully', () async {
        var createCallCount = 0;
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          createItem: (item) async {
            createCallCount++;
            return item?.copyWith(id: 100);
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.create(newItem);

        expect(createCallCount, equals(1));
        expect(createdItem, isNotNull);
        expect(createdItem!.id, equals(100));
      });

      test('creates item with index parameter', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          createItem: (item) async => item?.copyWith(id: 200),
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final newItem = _TestItem(0, 'New Item', 50);
        final createdItem = await repository.create(newItem, index: 0);

        expect(createdItem, isNotNull);
      });

      test('handles creation error and rolls back', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          createItem: (item) async {
            throw Exception('Creation failed');
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final newItem = _TestItem(0, 'New Item', 50);
        expect(() => repository.create(newItem), throwsException);

        // Wait for rollback
        await Future.delayed(const Duration(milliseconds: 100));
        final item = repository.getItemById(newItem.id);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackCreation));
      });

      test('throws assertion error when createItem callback is null', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          createItem: null,
          initialItems: items,
        );
        final newItem = _TestItem(0, 'New Item', 50);
        expect(() => repository.create(newItem), throwsAssertionError);
      });
    });

    group('CRUD Operations - Update', () {
      test('updates single item successfully', () async {
        var updateCallCount = 0;
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          updateItem: (id, newItem) async {
            updateCallCount++;
            return newItem.copyWith(name: 'Updated ${newItem.name}');
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.update(1, updatedItem);

        expect(updateCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Updated Item 1'));
      });

      test('updates item with null return from server', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          updateItem: (id, newItem) async => null,
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await repository.update(1, updatedItem);

        final item = repository.getItemById(1);
        expect(item?.value?.name, equals('Updated Item 1'));
      });

      test('handles update error and rolls back', () async {
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          updateItem: (id, newItem) async {
            throw Exception('Update failed');
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final updatedItem = _TestItem(1, 'Updated Item 1', 15);
        await expectLater(() => repository.update(1, updatedItem), throwsException);

        await Future.delayed(const Duration(milliseconds: 100));

        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackUpdate));
      });

      test('updates batch with updateBatch callback', () async {
        var updateBatchCallCount = 0;
        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];
        final repository = createRepository(
          updateBatch: (items) async {
            updateBatchCallCount++;
          },
          initialItems: items,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };
        await repository.updateBatch(itemsToUpdate);

        expect(updateBatchCallCount, equals(1));
      });

      test('updates batch without updateBatch callback uses updateItem', () async {
        var updateItemCallCount = 0;
        final repository = createRepository(
          updateBatch: null,
          updateItem: (id, newItem) async {
            updateItemCallCount++;
            return newItem;
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };
        await repository.updateBatch(itemsToUpdate);

        expect(updateItemCallCount, equals(2));
      });

      test('handles batch update errors and rolls back', () async {
        var rollbackCount = 0;
        final repository = createRepository(
          updateBatch: (items) async {
            rollbackCount = items.length;
            throw Exception('Batch update failed');
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final itemsToUpdate = {
          _TestItem(1, 'Updated 1', 15),
          _TestItem(2, 'Updated 2', 25),
        };

        expect(() => repository.updateBatch(itemsToUpdate), throwsException);

        await Future.delayed(const Duration(milliseconds: 100));
        final item1 = repository.getItemById(1);
        final item2 = repository.getItemById(2);
        expect(item1?.state, equals(LdPaginatorItemState.rolledBackUpdate));
        expect(item2?.state, equals(LdPaginatorItemState.rolledBackUpdate));
        expect(rollbackCount, equals(2));
      });
    });

    group('CRUD Operations - Delete', () {
      test('deletes single item successfully', () async {
        var deleteCallCount = 0;
        final repository = createRepository(
          deleteItem: (id) async {
            deleteCallCount++;
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        await repository.delete(1);

        expect(deleteCallCount, equals(1));
        final item = repository.getItemById(1);
        expect(item, isNull);
      });

      test('handles deletion error and rolls back', () async {
        final repository = createRepository(
          deleteItem: (id) async {
            throw Exception('Delete failed');
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        expect(() => repository.delete(1), throwsException);

        await Future.delayed(const Duration(milliseconds: 100));
        final item = repository.getItemById(1);
        expect(item?.state, equals(LdPaginatorItemState.rolledBackDeletion));
      });

      test('does nothing when deleteItem callback is null', () async {
        final repository = createRepository(
          deleteItem: null,
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        await repository.delete(1);

        final item = repository.getItemById(1);
        expect(item, isNotNull);
      });

      test('deletes batch with deleteBatch callback', () async {
        var deleteBatchCallCount = 0;
        final repository = createRepository(
          deleteBatch: (ids) async {
            deleteBatchCallCount++;
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        await repository.deleteBatch({1, 2});

        expect(deleteBatchCallCount, equals(1));
        expect(repository.getItemById(1), isNull);
        expect(repository.getItemById(2), isNull);
      });

      test('deletes batch without deleteBatch callback calls delete individually', () async {
        var deleteCallCount = 0;
        final repository = createRepository(
          deleteBatch: null,
          deleteItem: (id) async {
            deleteCallCount++;
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        await repository.deleteBatch({1, 2});

        expect(deleteCallCount, equals(2));
      });

      test('handles batch deletion errors and refreshes list', () async {
        final repository = createRepository(
          deleteBatch: (ids) async {
            throw Exception('Batch delete failed');
          },
          autoLoad: true,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        expect(() => repository.deleteBatch({1, 2}), throwsException);

        await Future.delayed(const Duration(milliseconds: 100));
        // Repository should have refreshed the list
        expect(repository.itemsMap, isNotEmpty);
      });
    });

    group('Filtering', () {
      test('updateFilter updates filter and emits stream', () async {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'testFilter',
          label: (context) => 'Test Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => item.value > 15,
        );

        final repository = createRepository(
          filters: {filter},
        );

        var streamEmitted = false;
        repository.filterStream.listen((filters) {
          streamEmitted = true;
        });

        await repository.updateFilter('testFilter', (f) => f!.copyWith(isOn: true));

        expect(streamEmitted, isTrue);
        expect(repository.filters['testFilter']!.isOn, isTrue);
      });

      test('updateFilter throws assertion when filter does not exist', () {
        final repository = createRepository();

        expect(
          () => repository.updateFilter('nonExistent', (f) => f!.copyWith(isOn: true)),
          throwsA(isA<AssertionError>()),
        );
      });

      test('activeFilters returns only active filters', () {
        final filter1 = _MockFilterOption<_TestItem, int>(
          name: 'filter1',
          label: (context) => 'Filter 1',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );
        final filter2 = _MockFilterOption<_TestItem, int>(
          name: 'filter2',
          label: (context) => 'Filter 2',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: false,
        );

        final repository = createRepository(
          filters: {filter1, filter2},
        );

        expect(repository.activeFilters.length, equals(1));
        expect(repository.activeFilters.first.name, equals('filter1'));
      });

      test('queryParameters includes active filters', () {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'testFilter',
          label: (context) => 'Test Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );

        final repository = createRepository(
          filters: {filter},
        );

        final params = repository.queryParameters;
        expect(params.containsKey('testFilter'), isTrue);
        expect(params['testFilter'], equals('mock'));
      });

      test('applyOptimisticFilterAndSorting filters items correctly', () async {
        final filter = LdFilterRange<_TestItem, int>(
          name: 'valueRange',
          label: (context) => 'Value Range',
          icon: (context) => const Icon(Icons.filter_list),
          min: 0,
          max: 100,
          range: const RangeValues(0, 100),
          isOn: true,
          optimisticFilter: (item, range) => item.value >= range.start && item.value <= range.end,
        );

        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 20),
          _TestItem(3, 'Item 3', 30),
        ];

        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(
              newItems: items,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (id) async => items.firstWhere((item) => item.id == id),
          filters: {filter},
        );

        // Initialize items in repository
        await Future.delayed(const Duration(milliseconds: 100));

        // Add items manually to test filtering
        repository.replaceItems({
          0: LdPaginatorItem<_TestItem>(value: items[0], state: LdPaginatorItemState.loaded),
          1: LdPaginatorItem<_TestItem>(value: items[1], state: LdPaginatorItemState.loaded),
          2: LdPaginatorItem<_TestItem>(value: items[2], state: LdPaginatorItemState.loaded),
        });
        repository.totalItems = 3;

        // NARROWING phase:
        // tighten the active range filter so only items in [20, 30] remain visible.
        await repository.updateFilter(
          'valueRange',
          (f) => (f as LdFilterRange<_TestItem, int>).copyWith(range: const RangeValues(20, 30), isOn: true),
        );

        final narrowedVisibleIds = repository.itemsMap.values
            .where((item) => item.value != null && item.state != LdPaginatorItemState.filteredOut)
            .map((item) => item.value!.id)
            .toSet();

        // After narrowing, only ids 2 and 3 should still be visible.
        expect(narrowedVisibleIds, equals({2, 3}));

        // While the filter is still narrowed, a refresh should not resurrect
        // filtered-out items into the visible range.
        await repository.refreshList();

        final afterRefreshVisibleIds = repository.itemsMap.values
            .where((item) => item.value != null && item.state != LdPaginatorItemState.filteredOut)
            .map((item) => item.value!.id)
            .toSet();

        expect(afterRefreshVisibleIds, equals({2, 3}));

        // BROADENING phase (regression coverage):
        // broaden the same active filter again and verify previously filtered-out
        // items are restored without disabling/removing the filter.
        await repository.updateFilter(
          'valueRange',
          (f) => (f as LdFilterRange<_TestItem, int>).copyWith(range: const RangeValues(0, 30), isOn: true),
        );

        final broadenedVisibleIds = repository.itemsMap.values
            .where((item) => item.value != null && item.state != LdPaginatorItemState.filteredOut)
            .map((item) => item.value!.id)
            .toSet();

        // Item 1 must reappear here. This is the bug we are guarding against.
        expect(broadenedVisibleIds, equals({1, 2, 3}));
      });
    });

    group('Sorting', () {
      test('updateSortOption updates sort and emits stream', () async {
        final sort = _MockSortOption<_TestItem, int>(
          name: 'testSort',
          label: (context) => 'Test Sort',
          icon: (context) => const Icon(Icons.sort),
          optimisticSort: (a, b) => a.value.compareTo(b.value),
        );

        final repository = createRepository(
          sortOptions: [sort],
        );

        var streamEmitted = false;
        repository.sortStream.listen((sorts) {
          streamEmitted = true;
        });

        await repository.updateSortOption(sort.copyWith(isOn: true));

        expect(streamEmitted, isTrue);
        expect(repository.sortOptions.firstWhere((s) => s.name == 'testSort').isOn, isTrue);
      });

      test('updateSortOption throws assertion when sort option does not exist', () {
        final repository = createRepository();
        final sort = _MockSortOption<_TestItem, int>(
          name: 'nonExistent',
          label: (context) => 'Non Existent',
          icon: (context) => const Icon(Icons.sort),
        );

        expect(
          () => repository.updateSortOption(sort),
          throwsA(isA<AssertionError>()),
        );
      });

      test('setActiveSortOption activates only one sort option', () async {
        final sort1 = _MockSortOption<_TestItem, int>(
          name: 'sort1',
          label: (context) => 'Sort 1',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );
        final sort2 = _MockSortOption<_TestItem, int>(
          name: 'sort2',
          label: (context) => 'Sort 2',
          icon: (context) => const Icon(Icons.sort),
          isOn: false,
        );

        final repository = createRepository(
          sortOptions: [sort1, sort2],
        );

        await repository.setActiveSortOption('sort2');

        expect(repository.sortOptions.firstWhere((s) => s.name == 'sort1').isOn, isFalse);
        expect(repository.sortOptions.firstWhere((s) => s.name == 'sort2').isOn, isTrue);
      });

      test('queryParameters includes active sort options', () {
        final sort = _MockSortOption<_TestItem, int>(
          name: 'testSort',
          label: (context) => 'Test Sort',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );

        final repository = createRepository(
          sortOptions: [sort],
        );

        final params = repository.queryParameters;
        expect(params.containsKey('sort'), isTrue);
        expect(params['sort'], equals('testSort'));
      });

      test('applyOptimisticFilterAndSorting sorts items correctly', () async {
        final sort = _MockSortOption<_TestItem, int>(
          name: 'valueSort',
          label: (context) => 'Value Sort',
          icon: (context) => const Icon(Icons.sort),
          optimisticSort: (a, b) => b.value.compareTo(a.value), // Descending
          isOn: true,
        );

        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 30),
          _TestItem(3, 'Item 3', 20),
        ];

        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(
              newItems: items,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (id) async => items.firstWhere((item) => item.id == id),
          sortOptions: [sort],
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Add items manually to test sorting
        repository.replaceItems({
          0: LdPaginatorItem<_TestItem>(value: items[0], state: LdPaginatorItemState.loaded),
          1: LdPaginatorItem<_TestItem>(value: items[1], state: LdPaginatorItemState.loaded),
          2: LdPaginatorItem<_TestItem>(value: items[2], state: LdPaginatorItemState.loaded),
        });
        repository.totalItems = 3;

        await repository.setActiveSortOption('valueSort');
        await Future.delayed(const Duration(milliseconds: 600)); // Wait for optimistic sorting delay

        final sortedItems =
            repository.itemsMap.values.where((item) => item.value != null).map((item) => item.value!).toList();

        expect(sortedItems.length, equals(3));
        // Should be sorted descending by value
        expect(sortedItems[0].value, equals(30));
        expect(sortedItems[1].value, equals(20));
        expect(sortedItems[2].value, equals(10));
      });
    });

    group('Optimistic Filtering and Sorting', () {
      test('applyOptimisticFilterAndSorting refreshes list when no filters or sorts', () async {
        var refreshCallCount = 0;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            if (offset == 0) refreshCallCount++;
            return LdListPage<_TestItem>(
              newItems: [],
              hasMore: false,
              total: 0,
            );
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        await repository.applyOptimisticFilterAndSorting();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(refreshCallCount, greaterThan(0));
      });

      test('applyOptimisticFilterAndSorting handles combination of filters and sorts', () async {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'filter',
          label: (context) => 'Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => item.value > 15,
          isOn: true,
        );
        final sort = _MockSortOption<_TestItem, int>(
          name: 'sort',
          label: (context) => 'Sort',
          icon: (context) => const Icon(Icons.sort),
          optimisticSort: (a, b) => b.value.compareTo(a.value),
          isOn: true,
        );

        final items = [
          _TestItem(1, 'Item 1', 10),
          _TestItem(2, 'Item 2', 30),
          _TestItem(3, 'Item 3', 20),
        ];

        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(
              newItems: items,
              hasMore: false,
              total: items.length,
            );
          },
          getById: (id) async => items.firstWhere((item) => item.id == id),
          filters: {filter},
          sortOptions: [sort],
        );

        repository.replaceItems({
          0: LdPaginatorItem<_TestItem>(value: items[0], state: LdPaginatorItemState.loaded),
          1: LdPaginatorItem<_TestItem>(value: items[1], state: LdPaginatorItemState.loaded),
          2: LdPaginatorItem<_TestItem>(value: items[2], state: LdPaginatorItemState.loaded),
        });
        repository.totalItems = 3;

        await repository.applyOptimisticFilterAndSorting();
        await Future.delayed(const Duration(milliseconds: 600));

        final processedItems = repository.itemsMap.values
            .where((item) => item.value != null && item.state != LdPaginatorItemState.filteredOut)
            .map((item) => item.value!)
            .toList();

        // Should be filtered (value > 15) and sorted descending
        expect(processedItems.length, greaterThan(0));
        expect(processedItems.every((item) => item.value > 15), isTrue);
        if (processedItems.length > 1) {
          expect(processedItems[0].value, greaterThanOrEqualTo(processedItems[1].value));
        }
      });
    });

    group('initWithSelection', () {
      test('initializes with selection when getOffsetById is provided', () async {
        var getOffsetCallCount = 0;
        var fetchCallCount = 0;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            fetchCallCount++;
            return LdListPage<_TestItem>(
              newItems: [_TestItem(2, 'Item 2', 20)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          getOffsetById: (id, {filters, sortOptions}) async {
            getOffsetCallCount++;
            return 1; // Item at offset 1
          },
        );

        await repository.initWithSelection({2});

        expect(getOffsetCallCount, equals(1));
        expect(fetchCallCount, greaterThan(0));
        expect(repository.initialOffset, equals(1));
      });

      test('handles null return from getOffsetById', () async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          getOffsetById: (id, {filters, sortOptions}) async => null,
        );

        await repository.initWithSelection({99});

        expect(repository.initialOffset, equals(0));
      });

      test('does nothing when getOffsetById is null', () async {
        final repository = createRepository(
          getOffsetById: null,
        );

        await repository.initWithSelection({1});

        // Should complete without error
        expect(repository.initialOffset, equals(0));
      });
    });

    group('Query Parameters', () {
      test('queryParameters includes active filters', () {
        final filter1 = _MockFilterOption<_TestItem, int>(
          name: 'filter1',
          label: (context) => 'Filter 1',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );
        final filter2 = _MockFilterOption<_TestItem, int>(
          name: 'filter2',
          label: (context) => 'Filter 2',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: false,
        );

        final repository = createRepository(
          filters: {filter1, filter2},
        );

        final params = repository.queryParameters;
        expect(params.containsKey('filter1'), isTrue);
        expect(params.containsKey('filter2'), isFalse);
      });

      test('queryParameters includes active sort options', () {
        final sort1 = _MockSortOption<_TestItem, int>(
          name: 'sort1',
          label: (context) => 'Sort 1',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );
        final sort2 = _MockSortOption<_TestItem, int>(
          name: 'sort2',
          label: (context) => 'Sort 2',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );

        final repository = createRepository(
          sortOptions: [sort1, sort2],
        );

        final params = repository.queryParameters;
        expect(params.containsKey('sort'), isTrue);
        expect(params['sort'], contains('sort1'));
        expect(params['sort'], contains('sort2'));
      });

      test('queryParameters includes both filters and sorts', () {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'filter',
          label: (context) => 'Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );
        final sort = _MockSortOption<_TestItem, int>(
          name: 'sort',
          label: (context) => 'Sort',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );

        final repository = createRepository(
          filters: {filter},
          sortOptions: [sort],
        );

        final params = repository.queryParameters;
        expect(params.containsKey('filter'), isTrue);
        expect(params.containsKey('sort'), isTrue);
      });

      test('queryParameters is empty when no active filters or sorts', () {
        final repository = createRepository();

        final params = repository.queryParameters;
        expect(params.isEmpty, isTrue);
      });
    });

    group('Stream Behavior', () {
      test('filterStream emits when filter is updated', () async {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'testFilter',
          label: (context) => 'Test Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
        );

        final repository = createRepository(
          filters: {filter},
        );

        final streamEvents = <Set<LdFilterOption<_TestItem, int>>>[];
        repository.filterStream.listen((filters) {
          streamEvents.add(filters);
        });

        await repository.updateFilter('testFilter', (f) => f!.copyWith(isOn: true));

        expect(streamEvents.length, greaterThan(0));
      });

      test('sortStream emits when sort option is updated', () async {
        final sort = _MockSortOption<_TestItem, int>(
          name: 'testSort',
          label: (context) => 'Test Sort',
          icon: (context) => const Icon(Icons.sort),
        );

        final repository = createRepository(
          sortOptions: [sort],
        );

        final streamEvents = <List<LdSortOption<_TestItem, int>>>[];
        repository.sortStream.listen((sorts) {
          streamEvents.add(sorts);
        });

        await repository.updateSortOption(sort.copyWith(isOn: true));

        expect(streamEvents.length, greaterThan(0));
      });

      test('multiple subscribers receive stream events', () async {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'testFilter',
          label: (context) => 'Test Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
        );

        final repository = createRepository(
          filters: {filter},
        );

        var subscriber1Count = 0;
        var subscriber2Count = 0;

        repository.filterStream.listen((_) => subscriber1Count++);
        repository.filterStream.listen((_) => subscriber2Count++);

        await repository.updateFilter('testFilter', (f) => f!.copyWith(isOn: true));

        expect(subscriber1Count, greaterThan(0));
        expect(subscriber2Count, greaterThan(0));
      });
    });

    group('Integration with LdPaginator', () {
      test('fetchListWithParameters is called with correct parameters', () async {
        var calledWithFilters = <Set<LdFilterOption<_TestItem, int>>>[];
        var calledWithSortOptions = <List<LdSortOption<_TestItem, int>>>[];

        final filter = _MockFilterOption<_TestItem, int>(
          name: 'testFilter',
          label: (context) => 'Test Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: true,
        );
        final sort = _MockSortOption<_TestItem, int>(
          name: 'testSort',
          label: (context) => 'Test Sort',
          icon: (context) => const Icon(Icons.sort),
          isOn: true,
        );

        final repository = createRepository(
          fetchListWithParameters: ({
            required offset,
            required pageSize,
            pageToken,
            filters,
            sortOptions,
          }) async {
            calledWithFilters.add(filters ?? {});
            calledWithSortOptions.add(sortOptions ?? []);
            return LdListPage<_TestItem>(
              newItems: [],
              hasMore: false,
              total: 0,
            );
          },
          filters: {filter},
          sortOptions: [sort],
        );

        await repository.refreshList();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(calledWithFilters.length, greaterThan(0));
        expect(calledWithFilters.last.contains(filter), isTrue);
        expect(calledWithSortOptions.length, greaterThan(0));
        expect(calledWithSortOptions.last.contains(sort), isTrue);
      });

      test('active filters and sort options are passed to fetch function', () async {
        final filter = _MockFilterOption<_TestItem, int>(
          name: 'activeFilter',
          label: (context) => 'Active Filter',
          icon: (context) => const Icon(Icons.filter_list),
          optimisticFilterFunc: (item) => true,
          isOn: false, // Initially off
        );
        final sort = _MockSortOption<_TestItem, int>(
          name: 'activeSort',
          label: (context) => 'Active Sort',
          icon: (context) => const Icon(Icons.sort),
          isOn: false, // Initially off
        );

        var lastFilters = <LdFilterOption<_TestItem, int>>[];
        var lastSortOptions = <LdSortOption<_TestItem, int>>[];

        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({
            required offset,
            required pageSize,
            pageToken,
            filters,
            sortOptions,
          }) async {
            lastFilters = (filters ?? {}).toList();
            lastSortOptions = sortOptions ?? [];
            return LdListPage<_TestItem>(
              newItems: [],
              hasMore: false,
              total: 0,
            );
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          filters: {filter},
          sortOptions: [sort],
        );

        // Activate filter and sort
        await repository.updateFilter(
          'activeFilter',
          (f) => (f as _MockFilterOption<_TestItem, int>).copyWith(isOn: true),
        );
        await repository.setActiveSortOption('activeSort');

        // Trigger fetch
        await repository.refreshList();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(lastFilters.any((f) => f.name == 'activeFilter' && f.isOn), isTrue);
        expect(lastSortOptions.any((s) => s.name == 'activeSort' && s.isOn), isTrue);
      });
    });
  });
}
