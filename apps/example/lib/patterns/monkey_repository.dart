import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyRepositoryDemo extends StatelessWidget {
  const MonkeyRepositoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_repository.dart",
      category: "Patterns",
      title: "LdMonkey - Repository",
      apiComponents: ["LdRepository"],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            "The LdRepository is a class that is responsible for fetching and caching data using the provided data source. It supports pagination, filtering, sorting, and CRUD operations.",
          ),

          LdText.hs("1. Define your data model"),
          LdText.p(
            "First, create a data model that implements the Identifiable interface. This interface requires an id property that uniquely identifies each item.",
          ),
          CodeBlock(
            language: "dart",
            code: '''class Task with Identifiable<int> {
  @override
  final int id;
  ...
}''',
          ),
          LdText.hs("2. Create the repository"),
          LdText.p(
            "Create an LdRepository instance that handles all data operations. The repository manages pagination, filtering, sorting, and CRUD operations.",
          ),
          CodeBlock(
            language: "dart",
            code: '''final taskRepository = LdRepository<Task, int>(
  singularItemTitle: "Task",
  pluralItemTitle: "Tasks",
  pageSize: 10,
  
  // Required: Fetch a single item by ID
  getById: (id) async {
    return testData.firstWhere((element) => element.id == id);
  },
  
  
  // Required: Fetch paginated list with filters and sorting
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<Task, int>>? filters,
    List<LdSortOption<Task, int>>? sortOptions,
  }) async {
    // Apply filters
    var filtered = testData.where((item) {
      return filters?.every((filter) => filter.optimisticFilter(item)) ?? true;
    }).toList();
    
    // Apply sorting
    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }
    
    // Apply pagination
    final startIndex = offset;
    final endIndex = (offset + pageSize).clamp(0, filtered.length);
    final pageItems = filtered.sublist(startIndex, endIndex);
    
    return LdListPage<Task>(
      newItems: pageItems,
      hasMore: endIndex < filtered.length,
      total: filtered.length,
    );
  },


  // Optional: Get the offset of an item for deep linking this 
  // is used to move the list to the selected item when restoring a deep link.
  // This is basicually the position of the item when fetched from the backend.
  getOffsetById: (id, {filters, sortOptions}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Apply the same filtering and sorting logic as fetchListWithParameters
    final filtered = testData
        .where((element) =>
            filters?.every((filter) => filter.optimisticFilter(element)) ??
            true)
        .toList();

    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }

    return filtered.indexWhere((element) => element.id == id);
  },
  
);''',
          ),
          LdAccordion.single(
            header: LdText.hs("Additional CRUD operations"),
            child: CodeBlock(
              code: '''
  // Optional: Delete a single item
  deleteItem: (int id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  
  // Optional: Delete multiple items
  deleteBatch: (Set<int> ids) async {
    testData.removeWhere((element) => ids.contains(element.id));
    await Future.delayed(const Duration(milliseconds: 500));
  },
  
  // Optional: Update a single item
  updateItem: (int id, Task newItem) async {
    final index = testData.indexWhere((element) => element.id == id);
    final updatedItem = newItem.copyWith(lastUpdate: DateTime.now());
    testData[index] = updatedItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return updatedItem;
  },
  
  // Optional: Create a new item (no id parameter - id is part of the item)
  createItem: (Task? item) async {
    testData.add(item!);
    await Future.delayed(const Duration(milliseconds: 500));
    return item;
  },''',
            ),
          ),
          LdText.hs("3. Sort and filter the data"),

          LdCard(
            padding: EdgeInsets.zero,
            child: LdListItem.trailingForward(
              title: Text("View Sorting & Filtering Documentation"),
              onPressed: () {
                context.push("/patterns/monkey/sorting-filtering");
              },
            ),
          ),
        ],
      ),
    );
  }
}
