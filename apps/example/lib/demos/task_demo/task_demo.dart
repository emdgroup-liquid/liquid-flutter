import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/detail.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

enum TaskActionId { create, markDone, markUndone, duplicate }

int _nextTaskId() {
  return testData.fold<int>(0, (max, task) => task.id > max ? task.id : max) + 1;
}

List<LdMonkeyAction<Task, int>> taskActions = [
  refreshAction<Task, int>(),
  LdMonkeySubmitAction(
    id: TaskActionId.create,
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterAppBar,
        visibleWhenShowingSelectionControls: false,
      ),
    },
    tooltip: (context) => "Create new task",
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyN, meta: true)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Creating new task"),
    onSubmit: (ctx) async {
      final newTaskText = await ldEnterTextModal(
        context: ctx.appContext,
        initialValue: "New tasks",
        inputHint: "New Task",
        inputLabel: "Task",
        useRootNavigator: true,
      );

      if (newTaskText == null) {
        return;
      }

      final newTask = Task(
        _nextTaskId(),
        newTaskText,
        DateTime.now().add(const Duration(days: 1)),
        false,
        DateTime.now(),
      );
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.repository.create(ctx.appContext, newTask);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (ctx.appContext.mounted) {
        ctx.updateViewing({newTask.id});
      }
    },
    child: Text("New Task"),
    icon: Icon(LucideIcons.plus),
  ),
  LdMonkeySubmitAction(
    id: TaskActionId.markDone,
    tooltip: (context) => "Mark as done",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: (context) {
          final selection = LdMonkeySelection.adaptive<Task, int>(context, listen: true);
          bool hasTodo = false;
          for (final id in selection) {
            final item = LdRepository.of<Task, int>(context).getItemById(id);
            if (item?.value?.done == false) {
              hasTodo = true;
              break;
            }
          }
          return hasTodo;
        },
      ),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.context,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: (context) {
          final selection = LdMonkeySelection.adaptive<Task, int>(context, listen: true);
          bool hasTodo = false;
          for (final id in selection) {
            final item = LdRepository.of<Task, int>(context).getItemById(id);
            if (item?.value?.done == false) {
              hasTodo = true;
              break;
            }
          }
          return hasTodo;
        },
      ),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyD)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as done", allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.repository.getById(id);
        updatedItems.add(item.copyWith(done: true));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.repository.updateBatch(ctx.appContext, updatedItems);
    },
    child: Text("Done"),
    icon: Icon(LucideIcons.check),
  ),
  LdMonkeySubmitAction(
    id: TaskActionId.markUndone,
    tooltip: (context) => "Mark as undone",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: null,
      ),
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, minSelectionCount: 1, maxSelectionCount: null),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyU)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as undone", allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.repository.getById(id);
        updatedItems.add(item.copyWith(done: false));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.repository.updateBatch(ctx.appContext, updatedItems);
    },
    child: Text("To do"),
    icon: Icon(LucideIcons.hourglass),
  ),
  LdMonkeySubmitAction(
    id: TaskActionId.duplicate,
    tooltip: (context) => "Duplicate selection",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: 1,
      ),
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, minSelectionCount: 1, maxSelectionCount: 1),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyD, meta: true)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Duplicating"),
    onSubmit: (ctx) async {
      final item = await ctx.repository.getById(ctx.selectedIds.first);

      final newItem = item.copyWith(id: _nextTaskId(), task: "${item.task} (copy)");

      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.repository.create(ctx.appContext, newItem);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (ctx.appContext.mounted) {
        ctx.updateViewing({newItem.id});
      }
    },
    child: Text("Duplicate"),
    icon: Icon(LucideIcons.copy),
  ),
  deleteAction<Task, int>(detailLocation: LdMonkeyActionLocation.detailSecondary),
  showSelectionControlsAction<Task, int>(),
  showFilterModal<Task, int>(),
  showSelection<Task, int>(),
];

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBarConfig: LdAppBarConfig(debugName: 'Detail App Bar Task', title: Text('Task')),
      secondaryAppBarConfig: LdAppBarConfig(
        positionMode: LdAppBarPositionMode.top,
        borderMode: LdAppBarBorderMode.visible,
      ),
      buildDetail: (context, item) => TaskDetail(task: item),
    );
  }
}

class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Task, int>(
      primaryAppBarConfig: LdAppBarConfig(debugName: "Master App Bar Tasks", title: Text("Tasks")),
      buildItem: (context, item) => LdListItem(
        title: Text(
          item.value!.task,
          style: TextStyle(decoration: item.value!.done ? TextDecoration.lineThrough : TextDecoration.none),
        ),
        subtitle: Text(
          "Due ${Jiffy.parseFromDateTime(item.value!.due).fromNow()}",
          style: TextStyle(
            color: switch (item.value!.due.isBefore(DateTime.now())) {
              true => LdTheme.of(context).errorColor,
              _ => null,
            },
          ),
        ),
        leading: LdAvatar(emoji: true, child: LdText(item.value!.emoji)),
      ),
    );
  }
}

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

Future<Task> taskReorderHandler(
  BuildContext context,
  Task item,
  int fromIndex,
  int toIndex,
) async {
  return item.copyWith(
    order: toIndex,
    lastUpdate: DateTime.now(),
  );
}

List<LdFilterOption<Task, int>> taskFilters = [
  LdFilterSearch<Task, int, String>(
    name: "search",
    label: (context) => "Search",
    icon: (context) => Icon(LucideIcons.search),
    getSuggestions: (searchText) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      return testData
          .where((element) => element.task.toLowerCase().startsWith(searchText.toLowerCase()))
          .map((e) => e.task)
          .toList();
    },
    buildSuggestion: (context, suggestion) {
      return LdListItem(
        title: Text(suggestion),
        onPressed: () {
          LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
        },
      );
    },
  ),
  LdFilterBool<Task, int>(
    isEnabled: (context) {
      final filters = Provider.of<LdMonkeySortAndFilterState<Task, int>>(context);
      return !filters.filters.any((e) => e.name == "todo" && e.isOn);
    },
    name: "done",
    label: (context) => "Done",
    icon: (context) => Icon(LucideIcons.check),
    affectedByUpdate: (before, after) => before?.done != after?.done,
  ),
  LdFilterBool<Task, int>(
    isEnabled: (context) {
      final filters = Provider.of<LdMonkeySortAndFilterState<Task, int>>(context);

      return !filters.filters.any((e) => e.name == "done" && e.isOn);
    },
    name: "todo",
    label: (context) => "To do",
    icon: (context) => Icon(LucideIcons.hourglass),
    affectedByUpdate: (before, after) => before?.done != after?.done,
  ),
];
