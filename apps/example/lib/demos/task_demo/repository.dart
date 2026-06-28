import 'package:flutter/widgets.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

List<Task> applyFiltersAndSorting(
  List<Task> data,
  Set<LdFilterOption<Task, int>>? filters,
  List<LdSortOption<Task, int>>? sortOptions,
) {
  final filtered = testData
      .where(
        (element) => (filters ?? <LdFilterOption<Task, int>>{}).every((filter) {
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
      case "order":
        filtered.sort(
          (a, b) => sortOption.direction == LdSortOptionDirection.asc
              ? a.order.compareTo(b.order)
              : b.order.compareTo(a.order),
        );
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

LdCallbackModel<Task, int> taskModel(BuildContext context) => LdCallbackModel<Task, int>(
  pageSize: 5,
  getOffsetByIdFn: (params) async {
    return applyFiltersAndSorting(
      testData,
      params.filters,
      params.sortOptions,
    ).indexWhere((element) => element.id == params.id);
  },
  getById: (context, id) async {
    return testData.firstWhere((element) => element.id == id);
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
  deleteItem: (context, id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  updateItem: (context, id, newItem) async {
    final index = testData.indexWhere((element) => element.id == id);
    final previous = testData[index];
    newItem = newItem.copyWith(lastUpdate: DateTime.now());

    if (previous.order != newItem.order) {
      if (newItem.order < previous.order) {
        for (final task in testData) {
          if (task.id != id && task.order >= newItem.order && task.order < previous.order) {
            testData[testData.indexWhere((element) => element.id == task.id)] = task.copyWith(order: task.order + 1);
          }
        }
      } else {
        for (final task in testData) {
          if (task.id != id && task.order > previous.order && task.order <= newItem.order) {
            testData[testData.indexWhere((element) => element.id == task.id)] = task.copyWith(order: task.order - 1);
          }
        }
      }
    }

    testData[index] = newItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return newItem;
  },
  createItem: (context, item) async {
    testData.add(item!);

    return item;
  },
);

