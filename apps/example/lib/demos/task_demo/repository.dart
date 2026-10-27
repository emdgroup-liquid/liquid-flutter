import 'package:flutter/widgets.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Flip this to simulate network latency in the task demo repository.
const kTaskDemoSimulateNetworkDelay = true;

const _listDelay = Duration(milliseconds: 400);
const _readDelay = Duration(milliseconds: 400);
const _writeDelay = Duration(milliseconds: 1000);

Future<void> _maybeDelay(Duration duration) async {
  if (kTaskDemoSimulateNetworkDelay) {
    await Future.delayed(duration);
  }
}

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

LdCallbackModel<Task, int, Task, Task> taskModel(BuildContext context) => LdCallbackModel<Task, int, Task, Task>(
  pageSize: 5,
  getOffsetByIdFn: (params) async {
    await _maybeDelay(_readDelay);
    return applyFiltersAndSorting(
      testData,
      params.filters,
      params.sortOptions,
    ).indexWhere((element) => element.id == params.id);
  },
  getById: (context, id) async {
    await _maybeDelay(_readDelay);
    return testData.firstWhere((element) => element.id == id);
  },
  fetchListWithParameters: (parameters) async {
    await _maybeDelay(_listDelay);

    if (!context.mounted) {
      return LdListPage<Task>(newItems: [], hasMore: false, total: 0);
    }

    final filtered = applyFiltersAndSorting(testData, parameters.filters, parameters.sortOptions);
    final result = filtered.skip(parameters.offset).take(parameters.pageSize).toList();
    return LdListPage<Task>(
      newItems: result,
      hasMore: parameters.offset + parameters.pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (context, id) async {
    await _maybeDelay(_writeDelay);
    testData.removeWhere((element) => element.id == id);
  },
  updateItem: (context, id, newItem) async {
    await _maybeDelay(_writeDelay);
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

    return newItem;
  },
  createItem: (context, item) async {
    await _maybeDelay(_writeDelay);
    testData.add(item);

    return item;
  },
  reorderItem: (context, item, fromIndex, toIndex, activeSortOption) async {
    await _maybeDelay(_writeDelay);
    return item.copyWith(order: toIndex, lastUpdate: DateTime.now());
  },
);
