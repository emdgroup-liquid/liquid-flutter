import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'task_detail_page.dart';
import 'task_model.dart';
import 'task_repository.dart';

class TaskDemo extends StatefulWidget {
  const TaskDemo({super.key});

  @override
  State<TaskDemo> createState() => TaskDemoState();
}

class TaskDemoState extends State<TaskDemo> {
  final GlobalKey<State<LdCrudMasterDetail<Task>>> _masterDetailKey =
      GlobalKey();
  final _repository = TaskRepository();
  final GlobalKey<State<TaskDetailPage>> taskDetailPageKey = GlobalKey();
  bool isEditingDetail = false;

  // Filter states
  bool? _filterByDone;
  String get _filterStatusText {
    if (_filterByDone == null) return 'All Tasks';
    return _filterByDone! ? 'Completed Tasks' : 'Pending Tasks';
  }

  TaskDetailPageState? get taskDetailPageState =>
      taskDetailPageKey.currentState as TaskDetailPageState?;

  void setIsEditingDetail(bool value) {
    setState(() => isEditingDetail = value);
  }

  // Apply filter and refresh list
  void _applyFilter(bool? value, LdCrudListState<Task> crudList) {
    setState(() {
      _filterByDone = value;
    });
    _repository.setFilterByDone(_filterByDone);
    crudList.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return LdCrudMasterDetail<Task>(
      key: _masterDetailKey,
      crud: _repository,
      masterDetailBuilder: (context,
              buildDetailTitle,
              buildMasterTitle,
              buildDetail,
              buildMaster,
              buildMasterActions,
              buildDetailActions) =>
          LdMasterDetail(
        buildMaster: buildMaster,
        buildDetail: buildDetail,
        buildMasterActions: buildMasterActions,
        buildDetailActions: buildDetailActions,
        buildDetailTitle: buildDetailTitle,
        buildMasterTitle: buildMasterTitle,
        masterDetailFlex: 2,
        onOpenItemChange: (item) async {
          setState(() => isEditingDetail = false);
        },
      ),
      buildMasterTitle: (context, openTask, optimisticOpenTask, isSeparatePage,
              controller, listState) =>
          LdAutoSpace(
        defaultSpacing: LdSize.xs,
        children: [
          LdTextHxs("Tasks"),
          LdTextL(_filterStatusText),
        ],
      ),
      buildMaster: (context, openTask, optimisticOpenTask, isSeparatePage,
          controller, listState) {
        return LdCrudMasterList(
          data: context.read<LdCrudListState<Task>>(),
          openItem: openTask,
          controller: controller,
          titleBuilder: (context, item, optimisticItem) => Text(item.task),
          subtitleBuilder: (context, item, optimisticItem) => Row(
            children: [
              Icon(
                Icons.fiber_manual_record,
                size: 12,
                color: TaskPriorityUIX(item.priority).color,
              ),
              const SizedBox(width: 2),
              Text(item.due),
            ],
          ),
          trailingBuilder: (context, item, optimisticItem) {
            return LdCrudAction.updateItem<Task>(
              actionButtonBuilder: (context, triggerAction) => LdButtonVague(
                size: LdSize.l,
                autoLoading: false,
                onPressed: triggerAction,
                child: Icon(
                  optimisticItem.done ? Icons.check : null,
                  color: item.done ? Colors.green : Colors.grey,
                ),
              ),
              getUpdatedItem: () => item.copyWith(done: !item.done),
            );
          },
        );
      },
      buildDetail: (context, item, optimisticItem, isSeparatePage, controller,
              listState) =>
          TaskDetailPage(
        key: taskDetailPageKey,
        task: item,
        isEditing: isEditingDetail,
      ),
      buildDetailTitle: (context, item, optimisticItem, isSeparatePage,
              controller, listState) =>
          Text("Task Details"),
      buildMasterActions: (context, openItem, optimisticOpenItem,
          isSeparatePage, controller, listState) {
        final crudList = context.read<LdCrudListState<Task>>();
        final filterByDoneValues = {
          null: Text("All"),
          true: Text("Done"),
          false: Text("Pending"),
        };
        return [
          LdSwitch(
            children: filterByDoneValues,
            value: _filterByDone,
            onChanged: (value) {
              setState(() => _filterByDone = value);
              _applyFilter(value, crudList);
            },
          ),
          LdCrudAction.createItem<Task>(getNewItem: () async {
            final createNewTaskKey = GlobalKey();
            final newTask = await LdModal(
              modalContent: (context) => TaskDetailPage(
                task: Task(-1, "", "any time", false),
                isEditing: true,
                key: createNewTaskKey,
              ),
              title: const Text("New Task"),
              actionBar: (context) => Row(
                children: [
                  Expanded(
                    child: LdButtonGhost(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  ldSpacerL,
                  Expanded(
                    child: LdButton(
                      child: const Text("Create"),
                      onPressed: () {
                        final state = (createNewTaskKey.currentState
                            as TaskDetailPageState);
                        final newTask = state.editingTask;
                        Navigator.of(context).pop(newTask);
                      },
                    ),
                  ),
                ],
              ),
            ).show(context, useRootNavigator: true);
            return newTask;
          }),
          LdCrudAction.deleteSelectedItems<Task>(),
        ];
      },
      buildDetailActions: (context, item, optimisticItem, isSeparatePage,
              controller, listState) =>
          [
        if (!isEditingDetail)
          IconButton(
            onPressed: () => setIsEditingDetail(true),
            icon: const Icon(Icons.edit),
          ),
        if (isEditingDetail) ...[
          LdCrudAction.updateItem<Task>(
            getUpdatedItem: () async => taskDetailPageState?.editingTask,
            onItemUpdated: (masterDetail, item) => setIsEditingDetail(false),
          ),
          LdCrudAction.deleteOpenItem<Task>()
        ]
      ],
    );
  }
}

extension TaskPriorityUIX on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  String get text {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}
