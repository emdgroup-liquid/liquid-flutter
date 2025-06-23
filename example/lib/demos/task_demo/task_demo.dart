/*class TaskDemo extends StatefulWidget {
  const TaskDemo({super.key});

  @override
  State<TaskDemo> createState() => TaskDemoState();
}

class TaskDemoState extends State<TaskDemo> {
  var _layoutMode = ResponsiveMode.split;
  var _presentationMode = PresentationMode.dialog;
  var _loadingIndicatorStyle = MasterDetailLoaderStyle.actionBar;

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
    return LdWindowFrame(
      title: const Text("Tasks"),
      frameBuilder: (context, child) => child,
      child: LdCrudMasterDetail<Task>(
        repo: _repository,
        defaultActionSettings: const LdCrudActionSettings(
          showLoadingDialog: false,
          errorNotificationMessage:
              "An error occurred while performing the action.",
        ),
        masterDetailBuilder: (context, builders) {
          return LdMasterDetail.builders(
            builders: builders,
            masterDetailFlex: 2,
            onOpenItemChange: (item) async {
              setState(() => isEditingDetail = false);
            },
            layoutMode: _layoutMode,
            detailPresentationMode: _presentationMode,
          );
        },
        buildMasterTitle: (
          context,
          openTask,
          optimisticOpenTask,
          isSeparatePage,
          controller,
          listState,
        ) =>
            LdAutoSpace(
          defaultSpacing: LdSize.xs,
          children: [
            LdTextHxs("Tasks"),
            LdTextL(_filterStatusText),
          ],
        ),
        buildMaster: (
          context,
          openTask,
          optimisticOpenTask,
          isSeparatePage,
          controller,
          listState,
        ) {
          return LdCrudMasterList<Task>(
            isSeparatePage: isSeparatePage,
            listState: listState,
            openItem: openTask,
            footer: LdMute(
              child: LdTextLs(
                "${listState.items.length} tasks",
                textAlign: TextAlign.center,
              ),
            ),
            controller: controller,
            titleBuilder: (context, item, optimisticItem) => Text(
              optimisticItem.task,
            ),
            subtitleBuilder: (context, item, optimisticItem) => Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 12,
                  color: TaskPriorityUIX(optimisticItem.priority).color,
                ),
                const SizedBox(width: 2),
                Text(item.due),
              ],
            ),
            trailingBuilder: (context, item, optimisticItem) {
              return LdCrudUpdateAction<Task>(
                actionButtonBuilder: (context, triggerAction) => LdCheckbox(
                  size: LdSize.l,
                  checked: item.done,
                  onChanged: (value) => triggerAction(),
                ),
                getUpdatedItem: () => item.copyWith(done: !item.done),
              );
            },
            contextActionsBuilder: (context, item, selectedItems) => [
              if (selectedItems.length <= 1) ...[
                LdCrudUpdateAction<Task>(
                  actionButtonBuilder: (context, triggerAction) => LdListItem(
                    title: Text("Mark as ${item.done ? 'Pending' : 'Done'}"),
                    leading: Icon(
                      item.done ? Icons.check : Icons.check_box_outline_blank,
                      color: item.done ? Colors.green : Colors.grey,
                    ),
                    onTap: triggerAction,
                  ),
                  getUpdatedItem: () => item.copyWith(done: !item.done),
                ),
                LdCrudDeleteAction<Task>(item: item),
              ],
              LdCrudDeleteSelectedAction<Task>(),
            ],
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
                _applyFilter(value, listState);
              },
            ),
            LdCrudCreateAction<Task>(getNewItem: () async {
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
                          Navigator.of(context).pop(
                            newTask?.task.isNotEmpty == true ? newTask : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ).show(context, useRootNavigator: true);

              return newTask;
            }),
            LdCrudDeleteSelectedAction<Task>(),
            LdButtonGhost(
              onPressed: () => _showTaskDemoDisplaySettingsModal(),
              child: const Icon(LucideIcons.settings),
            ),
          ];
        },
        buildDetailActions: (context, item, optimisticItem, isSeparatePage,
            controller, listState) {
          return [
            if (!isEditingDetail)
              LdButtonGhost(
                onPressed: () => setIsEditingDetail(true),
                child: const Icon(Icons.edit),
              ),
            if (isEditingDetail) ...[LdCrudDeleteAction<Task>()]
          ];
        },
      ),
    );
  }

  void _showTaskDemoDisplaySettingsModal() {
    LdModal(
      mode: LdModalTypeMode.sheet,
      modalContent: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.only(
              left: 64.0, right: 64.0, top: 32.0, bottom: 64.0),
          child: LdAutoSpace(children: [
            LdSelect(
              label: "Layout mode",
              items: [
                ...ResponsiveMode.values.map(
                  (e) => LdSelectItem(value: e, child: Text(e.toString())),
                ),
              ],
              value: _layoutMode,
              onChange: (value) {
                setState(() => _layoutMode = value);
                setModalState(() => _layoutMode = value);
              },
            ),
            LdSelect(
              label: "Presentation mode (only for compact layout)",
              items: [
                ...PresentationMode.values.map(
                  (e) => LdSelectItem(value: e, child: Text(e.toString())),
                ),
              ],
              value: _presentationMode,
              onChange: (value) {
                setState(() => _presentationMode = value);
                setModalState(() => _presentationMode = value);
              },
            ),
            LdSelect(
              label: "Loading indicator style",
              items: [
                ...MasterDetailLoaderStyle.values.map(
                  (e) => LdSelectItem(value: e, child: Text(e.toString())),
                ),
              ],
              value: _loadingIndicatorStyle,
              onChange: (value) {
                setState(() => _loadingIndicatorStyle = value);
                setModalState(() => _loadingIndicatorStyle = value);
              },
            ),
          ]),
        ),
      ),
      title: const Text("LdCrudMasterDetail Settings"),
    ).show(context);
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
*/
