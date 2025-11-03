import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/detail.dart';
import 'package:liquid/demos/task_demo/repository.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

final taskDemo = LdMonkey<Task, int>(
  path: "/task-demo",
  allowMultipleSelection: true,
  presentationMode: MonkeyDetailVariant.page,
  layoutMode: MonkeyLayoutMode.auto,
  showMultiSelectItems: true,
  parseId: (id) => int.parse(id),
  detailPath: (items) => "/task-demo/${items.join(",")}",
  buildRepository: (context) => taskRepository,
  buildDetail: (context, item) => TaskDetail(task: item),
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<Task, int>(
      showSelectionControls: route.state.showSelectionControls,
      listBuilder: (context, scrollController, itemBuilder) {
        return LdList(
          paginator: route.repository,
          itemBuilder: itemBuilder,
          scrollController: scrollController,
          assumedItemHeight: 50,
        );
      },
      paginator: route.repository,
      initialSelectedItems: route.state.selectedItems,
      multiSelect: true,
      onSelectionChange: (selected) => onSelectionChange(selected),
      itemBuilder: (context, item, index) => LdMonkeySingleShortcuts(
        item: item.value!.id,
        actions: route.actions,
        child: LdMonkeyContextMenu<Task, int>(
          item: item,
          child: LdListItemAnimation(
            state: item.state,
            child: LdListItem(
              title: Text(
                item.value!.task,
                style: TextStyle(
                  decoration: item.value!.done ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                "${Jiffy.parseFromDateTime(item.value!.due).fromNow()} #${item.value!.id}",
              ),
            ),
          ),
        ),
      ),
    );
  },
  actions: [
    LdMonkeySubmitAction(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.keyN, meta: true),
      },
      config: (context) => LdSubmitConfig(
        loadingText: "Creating new task",
        action: (_) async {
          final route = LdMonkey.of<Task, int>(context);

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

          route.setSelectedItems({newTask.id});
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
          final selection = LdMonkeySelection.of<Task, int>(context);
          for (final id in selection.items) {
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
          final selection = LdMonkeySelection.of<Task, int>(context);

          for (final id in selection.items) {
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
          final route = LdMonkey.of<Task, int>(context);
          final selection = LdMonkeySelection.of<Task, int>(context);
          final item = await taskRepository.getById(selection.items.first);

          final newItem = item.copyWith(
            id: testData.length + 1,
            task: "${item.task} (copy)",
          );

          await taskRepository.create(newItem);

          await Future.delayed(const Duration(milliseconds: 1500));

          route.setSelectedItems({newItem.id});
        },
      ),
      child: Text("Duplicate"),
      icon: Icon(LucideIcons.copy),
    ),
    LdMonkeySubmitAction(
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
          visibleInSplitView: false,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.delete),
        SingleActivator(LogicalKeyboardKey.backspace),
      },
      config: (context) => LdSubmitConfig(
        loadingText: "Deleting",
        action: (_) async {
          final selection = LdMonkeySelection.of<Task, int>(context);
          await taskRepository.deleteBatch(selection.items);
        },
      ),
      child: Text("Delete"),
      icon: Icon(LucideIcons.trash2),
    ),
    toggleSelectionControls<Task, int>(),
    toggleFilters<Task, int>(),
  ],
);
