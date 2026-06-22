import 'package:liquid_flutter/liquid_flutter.dart';

class Task with Identifiable<int> {
  @override
  final int id;

  final String task;
  final String emoji;
  final DateTime due;
  final bool done;
  final DateTime lastUpdate;
  final int order;

  Task(
    this.id,
    this.task,
    this.due,
    this.done,
    this.lastUpdate, {
    this.emoji = "📋",
    int? order,
  }) : order = order ?? id;

  Task copyWith({
    int? id,
    String? task,
    String? emoji,
    DateTime? due,
    bool? done,
    DateTime? lastUpdate,
    int? order,
  }) =>
      Task(
        id ?? this.id,
        task ?? this.task,
        due ?? this.due,
        done ?? this.done,
        lastUpdate ?? this.lastUpdate,
        emoji: emoji ?? this.emoji,
        order: order ?? this.order,
      );
}
