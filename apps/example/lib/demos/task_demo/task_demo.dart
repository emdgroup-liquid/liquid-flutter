import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/detail.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

enum TaskActionId { markDone, markUndone, duplicate, setDueToday, externalEdit }

final taskRouteConfig = LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task');

DateTime _dueDateToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

int _nextTaskId() {
  return testData.fold<int>(0, (max, task) => task.id > max ? task.id : max) + 1;
}

bool _hasTodoInSelection(LdMonkeyActionContext<Task, int> ctx) {
  for (final id in ctx.selectedIds) {
    final item = ctx.listController.getItemById(id);
    if (item?.value?.done == false) {
      return true;
    }
  }
  return false;
}

bool _hasDoneInSelection(LdMonkeyActionContext<Task, int> ctx) {
  for (final id in ctx.selectedIds) {
    final item = ctx.listController.getItemById(id);
    if (item?.value?.done == true) {
      return true;
    }
  }
  return false;
}

List<LdMonkeyAction<Task, int>> taskActions = [
  refreshAction<Task, int>(),
  reactiveCreateAction<Task, int>(routeConfig: taskRouteConfig),
  LdMonkeySubmitAction(
    id: TaskActionId.markDone,
    tooltip: (context) => "Mark as done",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: _hasTodoInSelection,
      ),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.context,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: _hasTodoInSelection,
      ),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyD)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as done", allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems.add(item.copyWith(done: true));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.appContext.read<LdModel<Task, int, Object?, Object?>>().updateBatch(ctx.appContext, updatedItems);
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
        isVisible: (ctx) => _hasDoneInSelection(ctx),
      ),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.context,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: (ctx) => _hasDoneInSelection(ctx),
      ),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyU)},
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as undone", allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems.add(item.copyWith(done: false));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.appContext.read<LdModel<Task, int, Object?, Object?>>().updateBatch(ctx.appContext, updatedItems);
    },
    child: Text("To do"),
    icon: Icon(LucideIcons.hourglass),
  ),
  LdMonkeySubmitAction(
    id: TaskActionId.setDueToday,
    tooltip: (context) => 'Set due date to today (simulates external change)',
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: 1,
      ),
    },
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: 'Setting due date to today', allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems.add(item.copyWith(due: _dueDateToday()));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.appContext.read<LdModel<Task, int, Object?, Object?>>().updateBatch(ctx.appContext, updatedItems);
    },
    child: Text('Due today'),
    icon: Icon(LucideIcons.calendarCheck),
  ),
  LdMonkeySubmitAction(
    id: TaskActionId.externalEdit,
    tooltip: (context) => 'Externally edit name + due date (simulates a multi-field conflict)',
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: 1,
      ),
    },
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: 'Applying external edit', allowResubmit: true),
    onSubmit: (ctx) async {
      final updatedItems = <Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems.add(item.copyWith(task: '${item.task} [edited elsewhere]', due: _dueDateToday()));
      }
      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.appContext.read<LdModel<Task, int, Object?, Object?>>().updateBatch(ctx.appContext, updatedItems);
    },
    child: Text('Edit elsewhere'),
    icon: Icon(LucideIcons.userPen),
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
      final item = await ctx.listController.getById(ctx.appContext, ctx.selectedIds.first);

      final newItem = item.copyWith(id: _nextTaskId(), task: "${item.task} (copy)");

      if (!ctx.appContext.mounted) {
        return;
      }
      await ctx.appContext.read<LdModel<Task, int, Object?, Object?>>().create(ctx.appContext, newItem);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (ctx.appContext.mounted) {
        ctx.updateViewing({newItem.id});
      }
    },
    child: Text("Duplicate"),
    icon: Icon(LucideIcons.copy),
  ),
  deleteAction<Task, int>(detailLocation: LdMonkeyActionLocation.detailAppBar),
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
        debugName: 'Detail Secondary App Bar Task',
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
    return LdListConfigProvider<Task, int>(
      // Match the loader to the item shape (leading avatar + subtitle) so the
      // placeholder occupies the same height and the list doesn't jump.
      config: LdListConfig<Task, int>(
        loadingBuilder: (context, position, totalItems) => const LdListItemLoading(
          hasLeading: true,
          hasSubtitle: true,
        ),
      ),
      child: LdMonkeyMasterPage<Task, int>(
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

Future<Task> taskReorderHandler(BuildContext context, Task item, int fromIndex, int toIndex) async {
  return item.copyWith(order: toIndex, lastUpdate: DateTime.now());
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
