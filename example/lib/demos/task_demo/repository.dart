import 'package:flutter/widgets.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final taskRepository = LdRepository<Task, int>(
  singularItemTitle: "Task",
  pluralItemTitle: "Tasks",
  pageSize: 5,
  getOffsetById: (id, {filters, sortOptions}) async {
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
  getById: (id) async {
    return testData.firstWhere((element) => element.id == id);
  },
  sortOptions: [
    LdSortOption<Task, int>(
      name: "due",
      label: (context) => "Due date",
      isOn: true,
      icon: (context) => const Icon(LucideIcons.calendar),
      optimisticSort: (a, b) {
        return a.due.compareTo(b.due);
      },
    ),
    LdSortOption<Task, int>(
      name: "task",
      label: (context) => "Task name",
      icon: (context) => const Icon(LucideIcons.arrowUpZA),
      optimisticSort: (a, b) {
        return a.task.compareTo(b.task);
      },
    ),
  ],
  filters: {
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
      buildSuggestion: (context, suggestion) {
        return LdListItem(
          title: Text(suggestion),
          onPressed: () {
            LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
          },
        );
      },
      getSuggestions: (searchText) async {
        print("Retrieving suggestion $searchText");
        return testData
            .where((element) =>
                element.task.toLowerCase().startsWith(searchText.toLowerCase()))
            .map((e) => e.task)
            .toList();
      },
    ),
  },
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<Task, int>>? filters,
    List<LdSortOption<Task, int>>? sortOptions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final filtered = testData
        .where((element) =>
            filters?.every((filter) => filter.optimisticFilter(element)) ??
            true)
        .toList();

    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }

    return LdListPage<Task>(
      newItems: filtered.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (int id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  deleteBatch: (ids) async {
    for (final id in ids) {
      testData.removeWhere((element) => element.id == id);
    }
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
