import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyRepositoryDemo extends StatelessWidget {
  const MonkeyRepositoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_repository.dart",
      category: "Patterns",
      title: "LdMonkey - Repository",
      demo: LdAutoSpace(children: [
        LdText.h("Data Repository"),
        LdText.p(
            "The data repository is a class that is responsible for fetching and caching data using the provided data source."),
        ComponentsAccordion(components: {"LdRepository"}),
        LdText.hs("1. Define your data model"),
        LdText.p(
            "First, create a data model that implements the Identifiable interface. This interface requires an id property that uniquely identifies each item."),
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
            "Create an LdRepository instance that handles all data operations. The repository manages pagination, filtering, sorting, and CRUD operations."),
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
  
  // Optional: Get the offset of an item for deep linking
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
  
  // Required: Fetch paginated list with filters and sorting
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<Task, int>>? filters,
    List<LdSortOption<Task, int>>? sortOptions,
  }) async {
    return LdListPage<Task>(
      newItems: // items
      hasMore: // boolean
      total: // number of items

    );
  },
  
  // Optional: Delete a single item
  deleteItem: (int id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  
  // Optional: Delete multiple items
  deleteBatch: (ids) async {

  },
  
  // Optional: Update a single item
  updateItem: (id, newItem) async {
    // returns Future<Task>
  },
  
  // Optional: Create a new item, takes a new id and the item to create 
  createItem: (id, item) async {
    // returns Future<Task>
  },
);''',
        ),
        LdText.hs("3. Define sort options"),
        LdText.p(
            "Sort options allow users to order items by different criteria. Each sort option includes a name, label, icon, and sorting function."),
        LdText.p(
            "You can also pass an optimistic sort function to the sort option. This function is used to sort the items immediately on the client side, without waiting for a server response. This provides instant feedback to the user, making the UI feel faster and more responsive."),
        CodeBlock(
          language: "dart",
          code: '''sortOptions: [
  LdSortOption<Task, int>(
    name: "due",
    label: (context) => "Due",
    isOn: true, // Default active sort
    icon: (context) => const Icon(LucideIcons.calendar),
    optimisticSort: (a, b) {
      return a.due.compareTo(b.due);
    },
  ),
  LdSortOption<Task, int>(
    name: "task",
    label: (context) => "Task",
    icon: (context) => const Icon(LucideIcons.list),
    optimisticSort: (a, b) {
      return a.task.compareTo(b.task);
    },
  ),
],''',
        ),
        LdText.hs("4. Define filter options"),
        LdText.p(
            "Filter options allow users to filter items based on different criteria. You can create boolean filters, search filters, and custom filters."),
        ComponentsAccordion(components: {
          "LdFilterBoolOption",
          "LdFilterSearchOption",
          "LdFilterOption",
        }),
        CodeBlock(
          language: "dart",
          code: '''filters: {
  LdFilterBoolOption<Task, int>(
    name: "done",
    label: (context) => "Done",
    icon: (context) => const Icon(LucideIcons.check),
    optimisticFilter: (item) {
      return item.done;
    },
  ),
  LdFilterBoolOption<Task, int>(
    name: "todo",
    label: (context) => "To do",
    icon: (context) => const Icon(LucideIcons.hourglass),
    optimisticFilter: (item) {
      return !item.done;
    },
  ),
  LdFilterSearchOption<Task, int, String>(
    name: "search",
    label: (context) => "Search",
    icon: (context) => const Icon(LucideIcons.search),
    optimisticFilter: (item, searchText) {
      return item.task.toLowerCase().contains(searchText.toLowerCase());
    },
    getSuggestions: (searchText) async {
      return testData
          .where((element) =>
              element.task.toLowerCase().startsWith(searchText.toLowerCase()))
          .map((e) => e.task)
          .toList();
    },
  ),
},''',
        ),
        LdText.hs("5. Use the repository in LdMonkey"),
        LdText.p(
            "The repository is used within the LdMonkey pattern to provide all CRUD functionality. The repository handles all data operations automatically."),
        CodeBlock(
          language: "dart",
          code: '''final taskDemo = LdMonkey<Task, int, bool>(
  path: "/task-demo",
  allowMultipleSelection: true,
  presentationMode: MonkeyDetailVariant.page,
  layoutMode: MonkeyLayoutMode.auto,
  showMultiSelectItems: true,
  parseId: (id) => int.parse(id),
  detailPath: (items) => "/task-demo/\${items.join(",")}",
  buildRepository: (context) => taskRepository, // Your repository here
  buildDetail: (context, item) => TaskDetail(task: item),
  // ... rest of configuration
);''',
        ),
      ]),
    );
  }
}
