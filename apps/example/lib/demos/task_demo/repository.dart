import 'package:flutter/widgets.dart';
import 'package:liquid/demos/movie_demo.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

List<Task> applyFiltersAndSorting(
  List<Task> data,
  Set<LdFilterOption<Task, int>>? filters,
  List<LdSortOption<Task, int>>? sortOptions,
) {
  final filtered = testData
      .where(
        (element) => (filters ?? {}).all((filter) {
          switch (filter.name) {
            case "done":
              return element.done;
            case "todo":
              return !element.done;
            case "search":
              filter as LdFilterSearch<Task, int, String>;
              return element.task.toLowerCase().contains(filter.searchText.toLowerCase());
          }
          return true;
        }),
      )
      .toList();

  for (final sortOption in sortOptions ?? []) {
    switch (sortOption.name) {
      case "due":
        filtered.sort(
          (a, b) => sortOption.direction == LdSortOptionDirection.asc ? a.due.compareTo(b.due) : b.due.compareTo(a.due),
        );
      case "task":
        filtered.sort(
          (a, b) =>
              sortOption.direction == LdSortOptionDirection.asc ? a.task.compareTo(b.task) : b.task.compareTo(a.task),
        );
    }
  }
  return filtered;
}

LdRepository<Task, int> taskRepository(BuildContext context) => LdRepository<Task, int>(
  pageSize: 5,
  getOffsetById: (id, {filters, sortOptions}) async {
    // Apply the same filtering and sorting logic as fetchListWithParameters

    return applyFiltersAndSorting(testData, filters, sortOptions).indexWhere((element) => element.id == id);
  },
  getById: (id) async {
    return testData.firstWhere((element) => element.id == id);
  },
  sortOptions: [
    LdSortOption<Task, int>(
      name: "due",
      label: (context) => "Due date",
      isOn: true,
      icon: (context) => const Icon(LucideIcons.calendar),
    ),
    LdSortOption<Task, int>(
      name: "task",
      label: (context) => "Task name",
      icon: (context) => const Icon(LucideIcons.arrowUpZA),
    ),
  ],
  filters: {
    LdFilterBool<Task, int>(name: "done", label: (context) => "Done", icon: (context) => const Icon(LucideIcons.check)),
    LdFilterBool<Task, int>(
      name: "todo",
      label: (context) => "To do",
      icon: (context) => const Icon(LucideIcons.hourglass),
    ),
    LdFilterSearch<Task, int, String>(
      name: "search",
      label: (context) => "Search",
      icon: (context) => const Icon(LucideIcons.search),

      buildSuggestion: (context, suggestion) {
        return LdListItem(
          title: Text(suggestion),
          onPressed: () {
            LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
          },
        );
      },
      getSuggestions: (searchText) async {
        return testData
            .where((element) => element.task.toLowerCase().startsWith(searchText.toLowerCase()))
            .map((e) => e.task)
            .toList();
      },
    ),
  },
  fetchListWithParameters: (parameters) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final filtered = applyFiltersAndSorting(testData, parameters.filters, parameters.sortOptions);
    return LdListPage<Task>(
      newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
      hasMore: parameters.offset + parameters.pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (int id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  updateItem: (id, newItem) async {
    final index = testData.indexWhere((element) => element.id == id);
    newItem = newItem.copyWith(lastUpdate: DateTime.now());
    testData[index] = newItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return newItem;
  },
  createItem: (item) async {
    testData.add(item!);

    return item;
  },
);
