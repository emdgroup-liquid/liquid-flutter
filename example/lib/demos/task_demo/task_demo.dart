import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/detail.dart';
import 'package:liquid/demos/task_demo/repository.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class TaskShell extends StatelessWidget {
  final Widget child;
  final GoRouterState routeState;
  final String pathParameterName;
  final Widget masterPage;
  final String basePath;

  const TaskShell({
    super.key,
    required this.child,
    required this.routeState,
    required this.pathParameterName,
    required this.masterPage,
    required this.basePath,
  });
  @override
  Widget build(BuildContext context) {
    return LdMonkeyShell<Task, int>(
      basePath: basePath,
      layoutMode: LdMonkeyLayoutMode.auto,
      masterPage: masterPage,
      parseSelected: (selected) => selected.split("_").map(int.parse).toSet(),
      routeState: routeState,
      repositoryBuilder: (context) async => taskRepository,
      pathParameterName: pathParameterName,
      actions: [
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterAppBar,
              visibleWhenShowingSelectionControls: false,
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.keyN, meta: true),
          },
          config: (context) => LdSubmitConfig(
            loadingText: "Creating new task",
            action: (_) async {
              final shellState = LdMonkeyShellState.of<Task, int>(context);
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

              await taskRepository.create(newTask);

              await Future.delayed(const Duration(milliseconds: 1500));

              shellState.setSelectedItems({newTask.id});
            },
          ),
          child: Text("New Task"),
          icon: Icon(LucideIcons.plus),
        ),
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
                location: LdMonkeyActionLocation.detailAppBar,
                minSelectionCount: 1,
                maxSelectionCount: null,
                applyFilters: {"todo"}),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: null,
              applyFilters: {"todo"},
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.keyD),
          },
          config: (context) => LdSubmitConfig(
            loadingText: "Marking as done",
            allowResubmit: true,
            action: (_) async {
              final updatedItems = <Task>{};
              final selection = LdMonkeySelection.adaptive<Task, int>(context);
              for (final id in selection) {
                final item = await taskRepository.getById(id);
                updatedItems.add(item.copyWith(done: true));
              }
              await taskRepository.updateBatch(updatedItems);
            },
          ),
          child: Text("Done"),
          icon: Icon(LucideIcons.check),
        ),
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.detailAppBar,
              minSelectionCount: 1,
              maxSelectionCount: null,
              applyFilters: {"done"},
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: null,
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.keyU),
          },
          config: (context) => LdSubmitConfig(
            loadingText: "Marking as undone",
            allowResubmit: true,
            action: (_) async {
              final updatedItems = <Task>{};
              final selection = LdMonkeySelection.adaptive<Task, int>(context);

              for (final id in selection) {
                final item = await taskRepository.getById(id);
                updatedItems.add(item.copyWith(done: false));
              }
              await taskRepository.updateBatch(updatedItems);
            },
          ),
          child: Text("To do"),
          icon: Icon(LucideIcons.hourglass),
        ),
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.detailAppBar,
              minSelectionCount: 1,
              maxSelectionCount: 1,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: 1,
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          config: (context) => LdSubmitConfig(
            loadingText: "Duplicating",
            action: (_) async {
              final shellState = LdMonkeyShellState.of<Task, int>(context);
              final selection = LdMonkeySelection.adaptive<Task, int>(context);
              final item = await taskRepository.getById(selection.first);

              final newItem = item.copyWith(
                id: testData.length + 1,
                task: "${item.task} (copy)",
              );

              await taskRepository.create(newItem);

              await Future.delayed(const Duration(milliseconds: 1500));

              shellState.setSelectedItems({newItem.id});
            },
          ),
          child: Text("Duplicate"),
          icon: Icon(LucideIcons.copy),
        ),
        LdMonkeySubmitAction(
          color: LdTheme.of(context).error,
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.detailAppBar,
              minSelectionCount: 1,
              maxSelectionCount: null,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: null,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterSecondary,
              minSelectionCount: 1,
              maxSelectionCount: null,
              layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.delete),
            SingleActivator(LogicalKeyboardKey.backspace),
          },
          config: (context) => LdSubmitConfig(
            loadingText: "Deleting",
            action: (_) async {
              final selection = LdMonkeySelection.adaptive<Task, int>(context);
              await taskRepository.deleteBatch(selection);
            },
          ),
          child: Builder(builder: (context) {
            return Text(
              LiquidLocalizations.of(context).deleteNItems(
                LdMonkeySelection.adaptive<Task, int>(context).length,
              ),
            );
          }),
          icon: Icon(LucideIcons.trash2),
        ),
        toggleSelectionControls<Task, int>(),
        toggleFilters<Task, int>(),
        showSelection<Task, int>(),
        LdMonkeyBareChildAction(
          builder: (context) => LdAppBarAction(
              leading: Icon(LucideIcons.eye),
              child: Text("Show ${LdMonkeySelection.of<Task, int>(context).selection.length} items"),
              onPressed: () async {
                final shellState = LdMonkeyShellState.of<Task, int>(context);
                shellState.setViewingItems(LdMonkeySelection.of<Task, int>(context).selection);
              }),
          onShortcutTrigger: (context) async {
            final shellState = LdMonkeyShellState.of<Task, int>(context);
            shellState.setViewingItems(LdMonkeySelection.of<Task, int>(context).selection);
          },
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterSecondary,
              minSelectionCount: 2,
              maxSelectionCount: null,
              layoutModes: {
                LdMonkeyEffectiveLayoutMode.master,
              },
              visibleWhenShowingSelectionControls: true,
            ),
          },
        ),
      ],
      child: child,
    );
  }
}

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBar: LdMonkeyAppBar<Task, int>(
        debugName: "Detail App Bar Task",
        location: LdMonkeyActionLocation.detailAppBar,
        title: Text("Task"),
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
      appBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Tasks"),
        debugName: "Master App Bar Tasks",
      ),
      buildItem: (context, item) => LdListItem(
        title: Text(
          item.value!.task,
          style: TextStyle(
            decoration: item.value!.done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text("Due ${Jiffy.parseFromDateTime(item.value!.due).fromNow()}"),
        leading: LdAvatar(
          color: switch (item.value!.done) {
            true => LdTheme.of(context).success,
            false => switch (item.value!.due.isBefore(DateTime.now())) {
                true => LdTheme.of(context).error,
                false => LdTheme.of(context).primary,
              },
          },
          child: Icon(
            item.value!.done ? LucideIcons.squareCheck : LucideIcons.square,
          ),
        ),
      ),
    );
  }
}
