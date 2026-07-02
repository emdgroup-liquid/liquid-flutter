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
      demo: LdAutoSpace(
        children: [
          LdText.h("Sorting & Filtering"),
          LdText.p(
            "The monkey pattern provides powerful sorting and filtering capabilities. "
            "Filters and sort options are provided as async builders to buildMonkeyRoutes "
            "and live in LdMonkeySortAndFilterState in the widget tree. The LdMonkeyListFilterAdapter "
            "automatically refreshes the list controller whenever they change.",
          ),
          ComponentsAccordion(
            components: {"LdSortOption", "LdFilterOption", "LdFilterBool", "LdFilterSearch", "LdFilterOneOf", "LdFilterAnyOf"},
          ),
          LdText.hs("1. Sort Options"),
          LdText.p(
            "Sort options allow users to order items by different criteria. Pass them via the async "
            "sortOptionsBuilder. Set supportsReorder: true on a sort option to enable drag-to-reorder "
            "when that sort is active (requires reorderHandler on buildMonkeyRoutes).",
          ),
          CodeBlock(
            language: "dart",
            code: '''sortOptionsBuilder: (_) async => [
  LdSortOption<Task, int>(
    name: "due",
    label: (context) => "Due Date",
    isOn: true, // active by default
    icon: (context) => const Icon(LucideIcons.calendar),
    optimisticSort: (a, b) => a.due.compareTo(b.due),
  ),
  LdSortOption<Task, int>(
    name: "order",
    label: (context) => "Custom order",
    icon: (context) => const Icon(LucideIcons.gripVertical),
    supportsReorder: true, // enables drag handles when active
    optimisticSort: (a, b) => a.order.compareTo(b.order),
  ),
],''',
          ),

          LdText.hs("2. Filter Options"),
          LdText.p(
            "Filters are provided via the async filtersBuilder. The monkey pattern includes "
            "several filter types for common use cases:",
          ),

          LdText.hs("Boolean Filters"),
          LdText.p("Simple on/off filters for boolean properties (e.g. done/to-do):"),
          CodeBlock(
            language: "dart",
            code: '''LdFilterBool<Task, int>(
  name: "done",
  label: (context) => "Completed",
  icon: (context) => const Icon(LucideIcons.check),
),''',
          ),

          LdText.hs("Search Filters"),
          LdText.p(
            "Text-based search with optional autocomplete suggestions. "
            "Automatically adds a search bar to the master app bar.",
          ),
          CodeBlock(
            language: "dart",
            code: '''LdFilterSearch<Task, int, String>(
  name: "search",
  label: (context) => "Search",
  icon: (context) => const Icon(LucideIcons.search),
  getSuggestions: (searchText) async {
    return testData
        .where((e) => e.task.toLowerCase().startsWith(searchText.toLowerCase()))
        .map((e) => e.task)
        .toList();
  },
),''',
          ),

          LdText.hs("One-of Filters"),
          LdText.p("Let the user pick exactly one value from a fixed set:"),
          CodeBlock(
            language: "dart",
            code: '''LdFilterOneOf<Task, int, String>(
  name: "priority",
  label: (context) => "Priority",
  icon: (context) => const Icon(LucideIcons.flag),
  allValues: {
    "high": (context) => Text("High"),
    "medium": (context) => Text("Medium"),
    "low": (context) => Text("Low"),
  },
),''',
          ),

          LdText.hs("Any-of Filters"),
          LdText.p("Let the user pick one or more values (checkboxes):"),
          CodeBlock(
            language: "dart",
            code: '''LdFilterAnyOf<Task, int, String>(
  name: "categories",
  label: (context) => "Categories",
  icon: (context) => const Icon(LucideIcons.tag),
  allValues: {
    "work": (context) => Text("Work"),
    "personal": (context) => Text("Personal"),
    "shopping": (context) => Text("Shopping"),
  },
),''',
          ),

          LdText.hs("3. Passing Filters and Sort Options"),
          LdText.p(
            "Pass async builders to buildMonkeyRoutes. Dynamic option catalogs (e.g. from an API) "
            "are loaded inside the builder. Call LdMonkeySortAndFilterState.refreshFilterDefinitions(context) "
            "to re-fetch definitions at runtime.",
          ),
          CodeBlock(
            language: "dart",
            code: '''buildMonkeyRoutes<Task, int>(
  filtersBuilder: (context) async {
    final categories = await api.fetchCategories();
    return [
      LdFilterSearch<Task, int, String>(
        name: "search",
        label: (context) => "Search",
        icon: (context) => const Icon(LucideIcons.search),
      ),
      LdFilterBool<Task, int>(
        name: "done",
        label: (context) => "Completed",
        icon: (context) => const Icon(LucideIcons.check),
      ),
      LdFilterOneOf<Task, int, String>(
        name: "category",
        label: (context) => "Category",
        icon: (context) => const Icon(LucideIcons.tag),
        allValues: {
          for (final cat in categories) cat: (context) => Text(cat),
        },
      ),
    ];
  },
  sortOptionsBuilder: (_) async => taskSortOptions,
  ...
)''',
          ),

          LdText.hs("4. Data Model Integration"),
          LdText.p(
            "Active filters and sort options are passed to fetchListWithParameters "
            "as a FetchPageParameters object. Apply them to your data fetching logic:",
          ),
          CodeBlock(
            language: "dart",
            code: '''final taskModel = LdCallbackModel<Task, int>(
  fetchListWithParameters: (params) async {
    // Apply filters
    var filtered = testData.where((item) {
      return params.filters?.every((f) => f.optimisticFilter(item)) ?? true;
    }).toList();
    
    // Apply sorting
    for (final sort in params.sortOptions ?? []) {
      filtered.sort((a, b) => sort.optimisticSort(a, b));
    }
    
    // Apply pagination
    final end = (params.offset + params.pageSize).clamp(0, filtered.length);
    return LdListPage<Task>(
      newItems: filtered.sublist(params.offset, end),
      hasMore: end < filtered.length,
      total: filtered.length,
    );
  },
  getById: (context, id) async => testData.firstWhere((e) => e.id == id),
);''',
          ),

          LdText.hs("5. URL State Management"),
          LdText.p(
            "Filter and sort states are automatically serialized into the URL, allowing users to bookmark "
            "and share filtered views. The monkey restores state on navigation.",
          ),
          CodeBlock(
            language: "dart",
            code: '''// URL will look like:
// /task-demo?filters=done&sort=due&search=important

// The monkey automatically:
// 1. Parses filter and sort parameters from the URL on load
// 2. Updates the URL when filters/sorts change
// 3. Restores state when navigating back''',
          ),

          LdText.hs("6. Accessing Active Filters"),
          LdText.p("Read the current filter and sort state from anywhere in the tree:"),
          CodeBlock(
            language: "dart",
            code: '''final state = LdMonkeySortAndFilterState.of<Task, int>(context); // listen: true by default
final activeFilters = state.activeFilters;
final activeSorts = state.activeSortOptions;
final canReorder = state.canReorder; // true when one active sort has supportsReorder: true

// Search filter value:
final search = state.filters.whereType<LdFilterSearch>().firstOrNull;
final searchText = search?.searchText ?? "";''',
          ),

          LdText.hs("7. Filter UI Components"),
          LdText.p(
            "The monkey provides built-in action factories for showing filter UI. "
            "Add them to the actions list:",
          ),
          ComponentsAccordion(components: {"LdFilterModal", "showFilterContextMenu", "showFilterModal"}),
          CodeBlock(
            language: "dart",
            code: '''actions: [
  showFilterContextMenu<Task, int>(), // dropdown popover in the master app bar
  showFilterModal<Task, int>(),       // full modal filter sheet
]''',
          ),

          LdText.hs("8. Filter Chips Bar"),
          LdText.p(
            "Pass filterBarConfig to LdMonkeyMasterPage to render active filter chips "
            "below the primary app bar. Chips allow users to deactivate individual filters inline.",
          ),
          CodeBlock(
            language: "dart",
            code: '''LdMonkeyMasterPage<Task, int>(
  filterBarConfig: [
    LdFilterChipConfig<Task, int>(filterName: "done"),
    LdFilterChipConfig<Task, int>(filterName: "priority"),
  ],
  buildItem: (context, item) => LdListItem(title: Text(item.value!.task)),
)''',
          ),

          LdText.hs("9. Drag-to-Reorder"),
          LdText.p(
            "Enable drag-to-reorder by setting supportsReorder: true on a sort option and "
            "providing a reorderHandler on buildMonkeyRoutes. Reorder mode activates automatically "
            "when that sort option is the sole active sort.",
          ),
          CodeBlock(
            language: "dart",
            code: '''buildMonkeyRoutes<Task, int>(
  reorderHandler: (context, item, fromIndex, toIndex) async {
    return await api.reorderTask(item.id, toIndex);
  },
  sortOptionsBuilder: (_) async => [
    LdSortOption<Task, int>(
      name: "order",
      label: (context) => "Custom order",
      icon: (context) => const Icon(LucideIcons.gripVertical),
      supportsReorder: true,
      optimisticSort: (a, b) => a.order.compareTo(b.order),
    ),
  ],
  ...
)''',
          ),
        ],
      ),
    );
  }
}
