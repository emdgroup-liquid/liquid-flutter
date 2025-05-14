import 'dart:convert';
import 'dart:math';

import 'package:js/js.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'task_model.dart';

class TaskRepository extends LdCrudOperations<Task> {
  final List<Task> _tasks;
  static const String _storageKey = 'tasks';
  bool? _filterByDone;

  TaskRepository() : _tasks = [] {
    _initStorage();
  }

  // Set the filter status
  void setFilterByDone(bool? filterByDone) {
    _filterByDone = filterByDone;
  }

  Future<void> _initStorage() async {
    final storedTasks = await WebStorage.getStringList(_storageKey);
    if (storedTasks != null) {
      _tasks.addAll(
        storedTasks
            .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
            .toList(),
      );
    } else {
      _tasks.addAll(sampleTasks);
      await _saveTasks();
    }
  }

  Future<void> _saveTasks() async {
    final taskJsonList =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await WebStorage.setStringList(_storageKey, taskJsonList);
  }

  @override
  FetchListFunction<Task> get fetchAll => ({
        required int offset,
        required int pageSize,
        String? pageToken,
      }) async {
        await _fakeDelay();

        // Apply filtering if filter is set
        List<Task> filteredTasks = _tasks;
        if (_filterByDone != null) {
          filteredTasks =
              _tasks.where((task) => task.done == _filterByDone).toList();
        }

        return LdListPage.fromList(
          filteredTasks,
          offset: offset,
          pageSize: filteredTasks.length,
        );
      };

  @override
  Future<Task> create(Task item) async {
    await _fakeDelay();
    final newId = _tasks.isEmpty ? 1 : _tasks.last.id + 1;
    final newTask = item.copyWith(id: newId);
    _tasks.add(newTask);
    await _saveTasks();
    return newTask;
  }

  @override
  Future<Task> update(Task item) async {
    await _fakeDelay();
    final index = _tasks.indexWhere((task) => task.id == item.id);
    if (index != -1) {
      _tasks[index] = item;
      await _saveTasks();
    }
    return item;
  }

  @override
  Future<void> delete(Task item) async {
    await _fakeDelay();
    _tasks.removeWhere((task) => task.id == item.id);
    await _saveTasks();
  }

  Future<void> _fakeDelay() async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(500)));
  }
}

// Sample data for the task demo
final List<Task> sampleTasks = [
  Task(
    1,
    "Build spaceship 🚀",
    "any time",
    false,
    priority: TaskPriority.low,
    description:
        "Building a spaceship will require: \n - Lots of money \n - Lots of time \n - Lots of patience",
  ),
  Task(
    2,
    "Build cool Flutter app",
    "any time",
    false,
    priority: TaskPriority.medium,
  ),
  Task(
    3,
    "Prepare for team meeting",
    "tomorrow",
    false,
    priority: TaskPriority.high,
    description: "Review Q2 metrics and prepare presentation slides",
  ),
  Task(
    4,
    "Buy groceries",
    "today",
    true,
    priority: TaskPriority.medium,
    description: "Milk, eggs, bread, and fruits",
  ),
  Task(
    5,
    "Learn quantum computing",
    "next year",
    false,
    priority: TaskPriority.low,
    description: "Start with basic quantum mechanics principles",
  ),
  Task(
    6,
    "Fix critical bug in production",
    "urgent",
    false,
    priority: TaskPriority.high,
    description: "Users reporting data loss in the payment module",
  ),
  Task(
    7,
    "Schedule dentist appointment",
    "next week",
    false,
    priority: TaskPriority.medium,
  ),
  Task(
    8,
    "Write documentation",
    "this week",
    true,
    priority: TaskPriority.medium,
    description: "API documentation and user guides completed",
  ),
];

@JS('localStorage')
external Storage get localStorage;

@JS()
@anonymous
class Storage {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

class WebStorage {
  static Future<List<String>?> getStringList(String key) async {
    final value = localStorage.getItem(key);
    if (value == null) return null;
    return value.split('|||');
  }

  static Future<void> setStringList(String key, List<String> value) async {
    localStorage.setItem(key, value.join('|||'));
  }
}
