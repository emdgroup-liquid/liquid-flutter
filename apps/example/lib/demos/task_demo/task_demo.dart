import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/detail.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

List<LdMonkeyAction<Task, int>> taskActions = [
  refreshAction<Task, int>(),
  LdMonkeySubmitAction(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterAppBar,
        visibleWhenShowingSelectionControls: false,
      ),
    },
    tooltip: (context) => "Create new task",
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyN, meta: true)},
    config: (context) => LdSubmitConfig(
      loadingText: "Creating new task",
      action: (_) async {
        final newTaskText = await ldEnterTextModal(
          context: context,
          initialValue: "New tasks",
          inputHint: "New Task",
          inputLabel: "Task",
          useRootNavigator: true,
        );

        if (newTaskText == null) {
          return;
        }

        final newTask = Task(
          testData.length + 1,
          newTaskText,
          DateTime.now().add(const Duration(days: 1)),
          false,
          DateTime.now(),
        );
        if (context.mounted) {
          final repository = LdRepository.of<Task, int>(context);
          await repository.create(newTask);
        } else {
          return;
        }

        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          LdMonkeySelection.updateViewing<Task, int>(context, {newTask.id});
        }
      },
    ),
    child: Text("New Task"),
    icon: Icon(LucideIcons.plus),
  ),
  LdMonkeySubmitAction(
    tooltip: (context) => "Mark as done",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: null,
        isVisible: (context) {
          final selection = LdMonkeySelection.adaptive<Task, int>(context);
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
          final selection = LdMonkeySelection.adaptive<Task, int>(context);
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
    config: (context) => LdSubmitConfig(
      loadingText: "Marking as done",
      allowResubmit: true,
      action: (_) async {
        final updatedItems = <Task>{};
        final selection = LdMonkeySelection.adaptive<Task, int>(context);
        final repository = LdRepository.of<Task, int>(context);
        for (final id in selection) {
          final item = await repository.getById(id);
          updatedItems.add(item.copyWith(done: true));
        }
        await repository.updateBatch(updatedItems);
      },
    ),
    child: Text("Done"),
    icon: Icon(LucideIcons.check),
  ),
  LdMonkeySubmitAction(
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
    config: (context) => LdSubmitConfig(
      loadingText: "Marking as undone",
      allowResubmit: true,
      action: (_) async {
        final updatedItems = <Task>{};
        final selection = LdMonkeySelection.adaptive<Task, int>(context);
        final repository = LdRepository.of<Task, int>(context);

        for (final id in selection) {
          final item = await repository.getById(id);
          updatedItems.add(item.copyWith(done: false));
        }
        await repository.updateBatch(updatedItems);
      },
    ),
    child: Text("To do"),

    icon: Icon(LucideIcons.hourglass),
  ),
  LdMonkeySubmitAction(
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
    config: (context) => LdSubmitConfig(
      loadingText: "Duplicating",
      action: (_) async {
        final selection = LdMonkeySelection.adaptive<Task, int>(context);
        final repository = LdRepository.of<Task, int>(context);
        final item = await repository.getById(selection.first);

        final newItem = item.copyWith(id: testData.length + 1, task: "${item.task} (copy)");

        await repository.create(newItem);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          LdMonkeySelection.updateViewing<Task, int>(context, {newItem.id});
        }
      },
    ),
    child: Text("Duplicate"),
    icon: Icon(LucideIcons.copy),
  ),
  LdMonkeySubmitAction(
    tooltip: (context) => "Delete selection",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        maxSelectionCount: null,
      ),
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, minSelectionCount: 1, maxSelectionCount: null),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterSecondary,
        minSelectionCount: 1,
        maxSelectionCount: null,
        layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
      ),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.delete), SingleActivator(LogicalKeyboardKey.backspace)},
    config: (context) => LdSubmitConfig(
      loadingText: "Deleting",
      action: (_) async {
        final selection = LdMonkeySelection.adaptive<Task, int>(context);
        final repository = LdRepository.of<Task, int>(context);
        await repository.deleteBatch(context: context, ids: selection);
      },
    ),
    child: Builder(
      builder: (context) {
        return Text(
          LiquidLocalizations.of(
            context,
          ).deleteNItems(LdMonkeySelection.adaptive<Task, int>(context, listen: true).length),
        );
      },
    ),
    icon: Icon(LucideIcons.trash2),
  ),
  toggleSelectionControls<Task, int>(),
  showFilterModal<Task, int>(),
  showSelection<Task, int>(),
];

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBarConfig: LdAppBarConfig(debugName: "Detail App Bar Task", title: Text("Task")),
      buildDetail: (context, item) => TaskDetail(task: item),
    );
  }
}

class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Task, int>(
      appBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Tasks"),
        debugName: "Master App Bar Tasks",
      ),
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
        leading: Icon(item.value!.done ? LucideIcons.squareCheck : LucideIcons.square),
      ),
    );
  }
}

List<LdSortOption<Task, int>> taskSortOptions = [
  LdSortOption<Task, int>(name: "due", label: (context) => "Due date", icon: (context) => Icon(LucideIcons.calendar)),

  LdSortOption<Task, int>(
    name: "task",
    label: (context) => "Task name",
    icon: (context) => Icon(LucideIcons.arrowUpZA),
  ),
];

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
      final filters = context.watch<LdMonkeySortAndFilterState<Task, int>>();
      return !filters.filters.any((e) => e.name == "todo" && e.isOn);
    },
    name: "done",
    label: (context) => "Done",
    icon: (context) => Icon(LucideIcons.check),
  ),
  LdFilterBool<Task, int>(
    isEnabled: (context) {
      final filters = context.watch<LdMonkeySortAndFilterState<Task, int>>();

      return !filters.filters.any((e) => e.name == "done" && e.isOn);
    },
    name: "todo",
    label: (context) => "To do",
    icon: (context) => Icon(LucideIcons.hourglass),
  ),
];
