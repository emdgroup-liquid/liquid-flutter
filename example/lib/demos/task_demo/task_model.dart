import 'package:liquid_flutter/liquid_flutter.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

class Task with CrudItemMixin<Task> {
  @override
  final int id;
  final String task;
  final String? description;
  final String due;
  final bool done;
  final TaskPriority priority;

  Task(
    this.id,
    this.task,
    this.due,
    this.done, {
    this.description,
    this.priority = TaskPriority.medium,
  });

  Task copyWith({
    int? id,
    String? task,
    String? description,
    String? due,
    bool? done,
    TaskPriority? priority,
  }) {
    return Task(
      id ?? this.id,
      task ?? this.task,
      due ?? this.due,
      done ?? this.done,
      description: description ?? this.description,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'description': description,
      'due': due,
      'done': done,
      'priority': priority.index,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['id'] as int,
      json['task'] as String,
      json['due'] as String,
      json['done'] as bool,
      description: json['description'] as String?,
      priority: TaskPriority.values[json['priority'] as int],
    );
  }

  @override
  String toString() {
    return "Task(id: $id, task: $task, due: $due, done: $done, description: $description, priority: $priority)";
  }

  @override
  bool get isNew => id == -1;
}
