import 'package:liquid_flutter/liquid_flutter.dart';

class Task with Identifiable<int> {
  @override
  final int id;

  final String task;
  final DateTime due;
  final bool done;
  final DateTime lastUpdate;
  Task(this.id, this.task, this.due, this.done, this.lastUpdate);

  Task copyWith({
    int? id,
    String? task,
    DateTime? due,
    bool? done,
    DateTime? lastUpdate,
  }) =>
      Task(
        id ?? this.id,
        task ?? this.task,
        due ?? this.due,
        done ?? this.done,
        lastUpdate ?? this.lastUpdate,
      );
}
