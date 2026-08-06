import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

List<LdSortOption<Task, int>> taskSortOptions = [
  LdSortOption<Task, int>(
    name: "order",
    label: (context) => "Manual order",
    icon: (context) => const Icon(LucideIcons.gripVertical),
    supportsReorder: true,
    affectedByUpdate: (before, after) => before?.order != after?.order,
  ),
  LdSortOption<Task, int>(
    name: "due",
    label: (context) => "Due date",
    icon: (context) => Icon(LucideIcons.calendar),
    affectedByUpdate: (before, after) => before?.due != after?.due,
  ),
  LdSortOption<Task, int>(
    name: "task",
    label: (context) => "Task name",
    icon: (context) => Icon(LucideIcons.arrowUpZA),
    affectedByUpdate: (before, after) => before?.task != after?.task,
  ),
];
