import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
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
      final updatedItems = <int, Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems[id] = item.copyWith(done: true);
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
      final updatedItems = <int, Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems[id] = item.copyWith(done: false);
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
      final updatedItems = <int, Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems[id] = item.copyWith(due: _dueDateToday());
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
      final updatedItems = <int, Task>{};
      for (final id in ctx.selectedIds) {
        final item = await ctx.listController.getById(ctx.appContext, id);
        updatedItems[id] = item.copyWith(task: '${item.task} [edited elsewhere]', due: _dueDateToday());
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
