import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

// Test item class
class TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;
  final String category;

  TestItem(this.id, this.name, this.value, [this.active = true, this.category = 'A']);

  TestItem copyWith({
    int? id,
    String? name,
    int? value,
    bool? active,
    String? category,
  }) {
    return TestItem(
      id ?? this.id,
      name ?? this.name,
      value ?? this.value,
      active ?? this.active,
      category ?? this.category,
    );
  }

  @override
  String toString() => 'TestItem(id: $id, name: $name, value: $value, active: $active, category: $category)';
}

// Mock BuildContext for testing
class MockBuildContext extends BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) => null;

  @override
  bool get mounted => true;

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  void dispatchNotification(Notification notification) {}

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() => null;

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() => null;

  @override
  RenderObject? findRenderObject() => null;

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

  @override
  BuildOwner? get owner => null;

  @override
  Size? get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => throw UnimplementedError();
}

/// Creates a test repository with default implementations
LdRepository<TestItem, int> createTestRepository({
  List<TestItem>? initialItems,
  Set<LdFilterOption<TestItem, int>>? filters,
  List<LdSortOption<TestItem, int>>? sortOptions,
  Future<int?> Function(int id, {Set<LdFilterOption<TestItem, int>>? filters, List<LdSortOption<TestItem, int>>? sortOptions})? getOffsetById,
  Future<void> Function(int id)? deleteItem,
  Future<TestItem?> Function(int id, TestItem newItem)? updateItem,
  Future<TestItem?> Function(TestItem? newItem)? createItem,
  Future<void> Function(Set<int> ids)? deleteBatch,
  Future<void> Function(Set<TestItem> items)? updateBatch,
}) {
  final items = initialItems ?? [
    TestItem(1, 'Item 1', 10),
    TestItem(2, 'Item 2', 20),
    TestItem(3, 'Item 3', 30),
  ];

  return LdRepository<TestItem, int>(
    fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
      var filtered = items.where((item) => filters?.every((filter) => filter.optimisticFilter(item)) ?? true).toList();

      for (final sortOption in sortOptions ?? []) {
        filtered.sort((a, b) => sortOption.optimisticSort(a, b));
      }

      final paginated = filtered.skip(offset).take(pageSize).toList();
      return LdListPage<TestItem>(
        newItems: paginated,
        hasMore: offset + pageSize < filtered.length,
        total: filtered.length,
      );
    },
    getById: (id) async => items.firstWhere((item) => item.id == id),
    filters: filters,
    sortOptions: sortOptions,
    getOffsetById: getOffsetById,
    deleteItem: deleteItem,
    updateItem: updateItem,
    createItem: createItem,
    deleteBatch: deleteBatch,
    updateBatch: updateBatch,
  );
}

/// Creates a test item
TestItem createTestItem(int id, {String? name, int? value, bool? active, String? category}) {
  return TestItem(
    id,
    name ?? 'Item $id',
    value ?? id * 10,
    active ?? true,
    category ?? 'A',
  );
}

// Note: GoRouterState is not easily mockable, so tests should use real GoRouter instances
// This helper is kept for reference but tests should create GoRouter directly

