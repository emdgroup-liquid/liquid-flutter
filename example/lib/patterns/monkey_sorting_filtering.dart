import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeySortingFilteringDemo extends StatelessWidget {
  const MonkeySortingFilteringDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_sorting_filtering.dart",
      category: "Patterns",
      title: "LdMonkey - Sorting & Filtering",
      demo: LdAutoSpace(children: [
        LdText.h("Sorting & Filtering"),
        LdText.p(
            "The monkey pattern provides powerful sorting and filtering capabilities through the LdRepository. These features work together to help users find and organize their data efficiently."),
        ComponentsAccordion(components: {
          "LdSortOption",
          "LdFilterOption",
          "LdFilterBoolOption",
          "LdFilterSearchOption"
        }),
        LdText.hs("1. Sort Options"),
        LdText.p(
            "Sort options allow users to order items by different criteria. Each sort option includes a name, label, icon, and sorting function."),
        CodeBlock(
          language: "dart",
          code: '''sortOptions: [
  LdSortOption<Task, int>(
    name: "due",
    label: (context) => "Due Date",
    isOn: true, // Default active sort
    icon: (context) => const Icon(LucideIcons.calendar),
    optimisticSort: (a, b) {
      return a.due.compareTo(b.due);
    },
  ),
  LdSortOption<Task, int>(
    name: "task",
    label: (context) => "Task Name",
    icon: (context) => const Icon(LucideIcons.list),
    optimisticSort: (a, b) {
      return a.task.compareTo(b.task);
    },
  ),
  LdSortOption<Task, int>(
    name: "created",
    label: (context) => "Created Date",
    icon: (context) => const Icon(LucideIcons.clock),
    optimisticSort: (a, b) {
      return a.created.compareTo(b.created);
    },
  ),
],''',
        ),
        LdText.hs("2. Optimistic Sorting"),
        LdText.p(
            "Optimistic sorting provides instant feedback by sorting items on the client side before the server responds. This makes the UI feel faster and more responsive."),
        CodeBlock(
          language: "dart",
          code: '''LdSortOption<Task, int>(
  name: "priority",
  label: (context) => "Priority",
  icon: (context) => const Icon(LucideIcons.flag),
  optimisticSort: (a, b) {
    // Custom sorting logic
    final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
    final aPriority = priorityOrder[a.priority] ?? 0;
    final bPriority = priorityOrder[b.priority] ?? 0;
    return bPriority.compareTo(aPriority); // High priority first
  },
),''',
        ),
        LdText.hs("3. Filter Options"),
        LdText.p(
            "Filter options allow users to filter items based on different criteria. The monkey pattern supports several types of filters:"),
        LdText.hs("Boolean Filters"),
        LdText.p("Simple on/off filters for boolean properties:"),
        CodeBlock(
          language: "dart",
          code: '''filters: {
  LdFilterBoolOption<Task, int>(
    name: "done",
    label: (context) => "Completed",
    icon: (context) => const Icon(LucideIcons.check),
    optimisticFilter: (item) {
      return item.done;
    },
  ),
  LdFilterBoolOption<Task, int>(
    name: "todo",
    label: (context) => "To Do",
    icon: (context) => const Icon(LucideIcons.hourglass),
    optimisticFilter: (item) {
      return !item.done;
    },
  ),
},''',
        ),
        LdText.hs("Search Filters"),
        LdText.p("Text-based search filters with suggestions:"),
        CodeBlock(
          language: "dart",
          code: '''LdFilterSearchOption<Task, int, String>(
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
),''',
        ),
        LdText.hs("Custom Filters"),
        LdText.p("Advanced filters with custom logic and UI:"),
        CodeBlock(
          language: "dart",
          code: '''LdFilterOption<Task, int>(
  name: "priority",
  label: (context) => "Priority",
  icon: (context) => const Icon(LucideIcons.flag),
  optimisticFilter: (item) {
    // This will be called with the current filter state
    // You can access the filter's current value through the repository
    return true; // Implement your filtering logic
  },
  buildFilterWidget: (context, currentValue, onChanged) {
    return LdSelect<String>(
      value: currentValue,
      onChanged: onChanged,
      options: [
        LdSelectOption(value: "high", label: "High"),
        LdSelectOption(value: "medium", label: "Medium"),
        LdSelectOption(value: "low", label: "Low"),
      ],
    );
  },
),''',
        ),
        LdText.hs("4. Filter Combinations"),
        LdText.p(
            "Multiple filters can be combined using AND logic. Users can activate multiple filters simultaneously:"),
        CodeBlock(
          language: "dart",
          code: '''filters: {
  // Status filters
  LdFilterBoolOption<Task, int>(
    name: "done",
    label: (context) => "Done",
    icon: (context) => const Icon(LucideIcons.check),
    optimisticFilter: (item) => item.done,
  ),
  LdFilterBoolOption<Task, int>(
    name: "todo",
    label: (context) => "To Do",
    icon: (context) => const Icon(LucideIcons.hourglass),
    optimisticFilter: (item) => !item.done,
  ),
  
  // Search filter
  LdFilterSearchOption<Task, int, String>(
    name: "search",
    label: (context) => "Search",
    icon: (context) => const Icon(LucideIcons.search),
    optimisticFilter: (item, searchText) {
      return item.task.toLowerCase().contains(searchText.toLowerCase());
    },
  ),
  
  // Priority filter
  LdFilterOption<Task, int>(
    name: "priority",
    label: (context) => "Priority",
    icon: (context) => const Icon(LucideIcons.flag),
    optimisticFilter: (item) {
      // Custom logic based on current filter state
      return true;
    },
  ),
},''',
        ),
        LdText.hs("5. Repository Integration"),
        LdText.p(
            "Filters and sorting are integrated into the repository's fetchListWithParameters method:"),
        CodeBlock(
          language: "dart",
          code: '''final taskRepository = LdRepository<Task, int>(
  // ... other configuration
  
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<Task, int>>? filters,
    List<LdSortOption<Task, int>>? sortOptions,
  }) async {
    // Apply filters
    var filteredData = testData.where((item) {
      return filters?.every((filter) => filter.optimisticFilter(item)) ?? true;
    }).toList();
    
    // Apply sorting
    for (final sortOption in sortOptions ?? []) {
      filteredData.sort((a, b) => sortOption.optimisticSort(a, b));
    }
    
    // Apply pagination
    final startIndex = offset;
    final endIndex = (offset + pageSize).clamp(0, filteredData.length);
    final pageItems = filteredData.sublist(startIndex, endIndex);
    
    return LdListPage<Task>(
      newItems: pageItems,
      hasMore: endIndex < filteredData.length,
      total: filteredData.length,
    );
  },
  
  // ... other configuration
);''',
        ),
        LdText.hs("6. URL State Management"),
        LdText.p(
            "Filter and sort states are automatically managed in the URL, allowing users to bookmark and share filtered views:"),
        CodeBlock(
          language: "dart",
          code:
              '''// URL will look like: /task-demo?filters=done,todo&sort=due&search=important

// The repository automatically:
// 1. Parses filter and sort parameters from URL
// 2. Applies them to the data fetching
// 3. Updates URL when filters/sorts change
// 4. Restores state when navigating back''',
        ),
        LdText.hs("7. Filter UI Components"),
        LdText.p(
            "The monkey pattern provides built-in UI components for managing filters:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("Filter Panel"),
            child: LdText.p("Toggleable panel showing all available filters"),
          ),
          LdCard(
            header: Text("Filter Chips"),
            child: LdText.p(
                "Visual indicators of active filters with remove buttons"),
          ),
          LdCard(
            header: Text("Search Bar"),
            child:
                LdText.p("Integrated search with suggestions and autocomplete"),
          ),
          LdCard(
            header: Text("Sort Dropdown"),
            child: LdText.p("Dropdown for selecting sort options"),
          ),
        ]),
        LdText.hs("8. Advanced Filter Examples"),
        LdText.p("More complex filter scenarios:"),
        LdText.hs("Date Range Filter"),
        CodeBlock(
          language: "dart",
          code: '''LdFilterOption<Task, int>(
  name: "due_date",
  label: (context) => "Due Date",
  icon: (context) => const Icon(LucideIcons.calendar),
  optimisticFilter: (item) {
    // Custom date range filtering logic
    final now = DateTime.now();
    final dueDate = item.due;
    return dueDate.isAfter(now) && dueDate.isBefore(now.add(Duration(days: 7)));
  },
  buildFilterWidget: (context, currentValue, onChanged) {
    return LdDatePicker(
      value: currentValue,
      onChanged: onChanged,
    );
  },
),''',
        ),
        LdText.hs("Multi-Select Filter"),
        CodeBlock(
          language: "dart",
          code: '''LdFilterOption<Task, int>(
  name: "categories",
  label: (context) => "Categories",
  icon: (context) => const Icon(LucideIcons.tag),
  optimisticFilter: (item) {
    // Check if item matches any selected categories
    return true; // Implement multi-select logic
  },
  buildFilterWidget: (context, currentValue, onChanged) {
    return LdMultiSelect<String>(
      value: currentValue ?? [],
      onChanged: onChanged,
      options: [
        LdSelectOption(value: "work", label: "Work"),
        LdSelectOption(value: "personal", label: "Personal"),
        LdSelectOption(value: "shopping", label: "Shopping"),
      ],
    );
  },
),''',
        ),
        LdText.hs("9. Performance Considerations"),
        LdText.p("Tips for optimal performance with large datasets:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("Optimistic Updates"),
            child: LdText.p(
                "Use optimistic filtering and sorting for immediate UI feedback"),
          ),
          LdCard(
            header: Text("Debounced Search"),
            child: LdText.p(
                "Implement debouncing for search filters to avoid excessive API calls"),
          ),
          LdCard(
            header: Text("Indexed Queries"),
            child:
                LdText.p("Use database indexes for commonly filtered fields"),
          ),
          LdCard(
            header: Text("Pagination"),
            child: LdText.p(
                "Always combine filtering with pagination for large datasets"),
          ),
        ]),
        LdText.hs("10. Complete Example"),
        LdText.p(
            "Here's a complete example of sorting and filtering configuration:"),
        CodeBlock(
          language: "dart",
          code: '''final taskRepository = LdRepository<Task, int>(
  singularItemTitle: "Task",
  pluralItemTitle: "Tasks",
  pageSize: 20,
  
  // Sort options
  sortOptions: [
    LdSortOption<Task, int>(
      name: "due",
      label: (context) => "Due Date",
      isOn: true,
      icon: (context) => const Icon(LucideIcons.calendar),
      optimisticSort: (a, b) => a.due.compareTo(b.due),
    ),
    LdSortOption<Task, int>(
      name: "task",
      label: (context) => "Task Name",
      icon: (context) => const Icon(LucideIcons.list),
      optimisticSort: (a, b) => a.task.compareTo(b.task),
    ),
    LdSortOption<Task, int>(
      name: "priority",
      label: (context) => "Priority",
      icon: (context) => const Icon(LucideIcons.flag),
      optimisticSort: (a, b) {
        final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
        final aPriority = priorityOrder[a.priority] ?? 0;
        final bPriority = priorityOrder[b.priority] ?? 0;
        return bPriority.compareTo(aPriority);
      },
    ),
  ],
  
  // Filter options
  filters: {
    LdFilterBoolOption<Task, int>(
      name: "done",
      label: (context) => "Completed",
      icon: (context) => const Icon(LucideIcons.check),
      optimisticFilter: (item) => item.done,
    ),
    LdFilterBoolOption<Task, int>(
      name: "todo",
      label: (context) => "To Do",
      icon: (context) => const Icon(LucideIcons.hourglass),
      optimisticFilter: (item) => !item.done,
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
  },
  
  // ... rest of repository configuration
);''',
        ),
      ]),
    );
  }
}
