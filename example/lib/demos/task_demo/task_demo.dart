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
      itemBuilder: (context, item, index, config) => LdMonkeySingleShortcuts(
        item: item.value!.id,
        actions: route.actions,
        child: LdMonkeyContextMenu<Task, int>(
          item: item,
          child: LdListItemAnimation(
            state: item.state,
            child: LdListItem.fromConfig(
              config.copyWith(
                title: Text(
                  item.value!.task,
                  style: TextStyle(
                    decoration: item.value!.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Text(
                  "${Jiffy.parseFromDateTime(item.value!.due).fromNow()} #${item.value!.id}",
                ),
                trailingForward:
                    LdMonkeyContext.of<Task, int>(context).isSideBySide,
              ),
            ),
          ),
        ),
      ),
    );
  },
  actions: [
    LdMonkeyAction(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.keyN, meta: true),
      },
      buildLoadingText: (context) => "Creating new task",
      submitType: LdLabeledActionType.none,
      buildLabel: (context) => "New Task",
      buildIcon: (context) => const Icon(LucideIcons.plus),
      action: (context) async {
        final route = LdMonkey.of<Task, int>(context);

        final newTaskNotification = LdNotificationsController.of(context)
            .enterText(
                message: "New tasks",
                inputHint: "New Task",
                inputLabel: "Task");

        final newTaskText = await newTaskNotification.inputCompleter.future;

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
    LdMonkeyAction(
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
      buildLoadingText: (context) => "Marking as done",
      buildLabel: (context) => "Done",
      buildIcon: (context) => const Icon(LucideIcons.check),
      action: (context) async {
        final updatedItems = <Task>{};

        final selection = LdMonkeySelection.of<Task, int>(context);
        for (final id in selection.items) {
          final item = await taskRepository.getById(id);
          updatedItems.add(item.copyWith(done: true));
        }

        await taskRepository.updateBatch(updatedItems);
      },
    ),
    LdMonkeyAction(
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
      buildLoadingText: (context) => "Marking as undone",
      buildLabel: (context) => "To do",
      buildIcon: (context) => const Icon(LucideIcons.hourglass),
      action: (context) async {
        final updatedItems = <Task>{};

        final selection = LdMonkeySelection.of<Task, int>(context);
        for (final id in selection.items) {
          final item = await taskRepository.getById(id);
          updatedItems.add(item.copyWith(done: false));
        }

        await taskRepository.updateBatch(updatedItems);
      },
    ),
    LdMonkeyAction(
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
      buildLoadingText: (context) => "Duplicating",
      buildLabel: (context) => "Duplicate",
      buildIcon: (context) => const Icon(LucideIcons.copy),
      multiSelect: false,
      action: (
        context,
      ) async {
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
    LdMonkeyAction(
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
      buildLoadingText: (context) {
        final selection = LdMonkeySelection.of<Task, int>(context);
        return "Deleting ${selection.items.length} ${selection.items.length == 1 ? "item" : "items"}";
      },
      buildLabel: (context) {
        final selection = LdMonkeySelection.of<Task, int>(context);
        return "Delete ${selection.items.length} ${selection.items.length == 1 ? "item" : "items"}";
      },
      buildIcon: (context) => Icon(
        LucideIcons.trash2,
      ),
      color: shadRed,
      action: (context) async {
        final selection = LdMonkeySelection.of<Task, int>(context);
        await taskRepository.deleteBatch(selection.items);
      },
    ),
    toggleSelectionControls<Task, int>(),
    toggleFilters<Task, int>(),
    LdMonkeyAction(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
        ),
      },
      buildLabel: (context) => "Leave demo",
      buildIcon: (context) => Icon(LucideIcons.arrowLeft),
      action: (context) async {
        context.go("/");
      },
    ),
  ],
);
