import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/sort/ld_sort_option.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Task with Identifiable<int> {
  @override
  final int id;

  final String task;
  final DateTime due;
  final bool done;
  final DateTime lastUpdate;
  _Task(this.id, this.task, this.due, this.done, this.lastUpdate);

  _Task copyWith({
    int? id,
    String? task,
    DateTime? due,
    bool? done,
    DateTime? lastUpdate,
  }) =>
      _Task(
        id ?? this.id,
        task ?? this.task,
        due ?? this.due,
        done ?? this.done,
        lastUpdate ?? this.lastUpdate,
      );
}

var testData = [
  _Task(1, "Build spaceship 🚀 ", DateTime.now().add(const Duration(days: 30)),
      false, DateTime.now()),
  _Task(2, "Build cool Flutter app",
      DateTime.now().add(const Duration(days: 30)), false, DateTime.now()),
  _Task(3, "Prepare for team meeting",
      DateTime.now().add(const Duration(days: 1)), false, DateTime.now()),
  _Task(4, "Buy groceries", DateTime.now(), true, DateTime.now()),
  _Task(5, "Learn quantum computing",
      DateTime.now().add(const Duration(days: 365)), false, DateTime.now()),
  _Task(6, "Fix critical bug in production",
      DateTime.now().subtract(const Duration(days: 1)), false, DateTime.now()),
  _Task(7, "Schedule dentist appointment",
      DateTime.now().add(const Duration(days: 7)), false, DateTime.now()),
  _Task(8, "Write documentation", DateTime.now().add(const Duration(days: 3)),
      true, DateTime.now()),
  _Task(9, "Review pull requests", DateTime.now(), false, DateTime.now()),
  _Task(10, "Update dependencies", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(
      11,
      "Plan team offsite",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(12, "Backup database", DateTime.now(), true, DateTime.now()),
  _Task(13, "Read a new Flutter article",
      DateTime.now().add(const Duration(days: 3)), false, DateTime.now()),
  _Task(
      14,
      "Refactor old codebase",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(15, "Organize workspace", DateTime.now(), false, DateTime.now()),
  _Task(16, "Update project roadmap",
      DateTime.now().add(const Duration(days: 1)), false, DateTime.now()),
  _Task(17, "Test new features", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(18, "Clean up email inbox", DateTime.now(), false, DateTime.now()),
  _Task(
      19,
      "Prepare sprint demo",
      DateTime.now().add(Duration(days: (5 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(20, "Sync with design team",
      DateTime.now().add(const Duration(days: 7)), false, DateTime.now()),
  _Task(
      21,
      "Walk the dog",
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
          23, 59),
      false,
      DateTime.now()),
  _Task(
      22,
      "Call mom",
      DateTime.now().add(Duration(days: (7 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      23,
      "Finish reading book",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(24, "Practice piano", DateTime.now().add(const Duration(days: 1)),
      false, DateTime.now()),
  _Task(25, "Water the plants", DateTime.now(), false, DateTime.now()),
  _Task(26, "Update LinkedIn profile",
      DateTime.now().add(const Duration(days: 3)), false, DateTime.now()),
  _Task(
      27,
      "Book flight tickets",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(28, "Renew gym membership", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(
      29,
      "Submit expense report",
      DateTime.now().add(Duration(days: (5 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      30,
      "Brainstorm blog ideas",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      31,
      "Organize digital photos",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(32, "Update resume", DateTime.now().add(const Duration(days: 7)), false,
      DateTime.now()),
  _Task(
      33,
      "Research new technologies",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(
      34,
      "Plan birthday party",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(35, "Fix broken chair", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(36, "Learn Spanish basics",
      DateTime.now().add(const Duration(days: 365)), false, DateTime.now()),
  _Task(37, "Create workout routine",
      DateTime.now().add(const Duration(days: 1)), false, DateTime.now()),
  _Task(38, "Backup important files", DateTime.now(), true, DateTime.now()),
  _Task(39, "Schedule car maintenance",
      DateTime.now().add(const Duration(days: 7)), false, DateTime.now()),
  _Task(
      40,
      "Write thank you notes",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(41, "Update phone apps", DateTime.now(), false, DateTime.now()),
  _Task(
      42,
      "Plan summer vacation",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(43, "Fix leaky faucet", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(44, "Learn to cook pasta", DateTime.now().add(const Duration(days: 7)),
      false, DateTime.now()),
  _Task(
      45,
      "Organize closet",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      46,
      "Update insurance policy",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(47, "Practice meditation", DateTime.now(), true, DateTime.now()),
  _Task(
      48,
      "Fix garden fence",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7 + 7)),
      false,
      DateTime.now()),
  _Task(
      49,
      "Learn guitar chords",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(50, "Update emergency contacts",
      DateTime.now().add(const Duration(days: 3)), false, DateTime.now()),
  _Task(51, "Plan family dinner", DateTime.now().add(const Duration(days: 7)),
      false, DateTime.now()),
  _Task(52, "Fix computer issues",
      DateTime.now().subtract(const Duration(days: 1)), false, DateTime.now()),
  _Task(53, "Learn to swim", DateTime.now().add(const Duration(days: 365)),
      false, DateTime.now()),
  _Task(
      54,
      "Organize garage",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(55, "Update will", DateTime.now().add(const Duration(days: 365)), false,
      DateTime.now()),
  _Task(
      56,
      "Fix bicycle tire",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      57,
      "Learn calligraphy",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(58, "Update pet vaccinations",
      DateTime.now().add(const Duration(days: 7)), false, DateTime.now()),
  _Task(59, "Plan retirement", DateTime.now().add(const Duration(days: 365)),
      false, DateTime.now()),
  _Task(60, "Fix kitchen cabinet", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(
      61,
      "Learn to dance",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(
      62,
      "Organize bookshelf",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(63, "Update passport", DateTime.now().add(const Duration(days: 365)),
      false, DateTime.now()),
  _Task(64, "Fix door lock", DateTime.now().subtract(const Duration(days: 1)),
      false, DateTime.now()),
  _Task(
      65,
      "Learn to paint",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(66, "Update home security", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(67, "Plan home renovation",
      DateTime.now().add(const Duration(days: 365)), false, DateTime.now()),
  _Task(
      68,
      "Fix window blinds",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      69,
      "Learn to sew",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(
      70,
      "Update family photos",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(71, "Plan camping trip", DateTime.now().add(const Duration(days: 365)),
      false, DateTime.now()),
  _Task(72, "Fix lawn mower", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
  _Task(
      73,
      "Learn to fish",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(
      74,
      "Organize tool shed",
      DateTime.now().add(Duration(days: (6 - DateTime.now().weekday) % 7)),
      false,
      DateTime.now()),
  _Task(
      75,
      "Update medical records",
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 15),
      false,
      DateTime.now()),
  _Task(76, "Fix porch steps", DateTime.now().subtract(const Duration(days: 1)),
      false, DateTime.now()),
  _Task(
      77,
      "Learn to knit",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(
      78,
      "Update car registration",
      DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
      false,
      DateTime.now()),
  _Task(79, "Plan road trip", DateTime.now().add(const Duration(days: 365)),
      false, DateTime.now()),
  _Task(80, "Fix shower head", DateTime.now().add(const Duration(days: 3)),
      false, DateTime.now()),
];

final taskRepository = LdRepository<_Task, int>(
  singularItemTitle: "Task",
  pluralItemTitle: "Tasks",
  pageSize: 10,
  getOffsetById: (id) async {
    await Future.delayed(const Duration(seconds: 1));

    return testData.indexWhere((element) => element.id == id);
  },
  getById: (id) async {
    return testData.firstWhere((element) => element.id == id);
  },
  sortOptions: [
    LdSortOption<_Task, int>(
      name: "due",
      label: (context) => "Due",
      isOn: true,
      icon: (context) => const Icon(LucideIcons.calendar),
      optimisticSort: (a, b) {
        return a.due.compareTo(b.due);
      },
    ),
    LdSortOption<_Task, int>(
      name: "task",
      label: (context) => "Task",
      icon: (context) => const Icon(LucideIcons.list),
      optimisticSort: (a, b) {
        return a.task.compareTo(b.task);
      },
    ),
  ],
  filters: {
    LdFilterBoolOption<_Task, int>(
      name: "done",
      label: (context) => "Done",
      icon: (context) => const Icon(LucideIcons.check),
      optimisticFilter: (item) {
        return item.done;
      },
    ),
    LdFilterBoolOption<_Task, int>(
      name: "todo",
      label: (context) => "To do",
      icon: (context) => const Icon(LucideIcons.hourglass),
      optimisticFilter: (item) {
        return !item.done;
      },
    ),
  },
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<_Task, int>>? filters,
    List<LdSortOption<_Task, int>>? sortOptions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final filtered = testData
        .where((element) =>
            filters?.every((filter) => filter.optimisticFilter(element)) ??
            true)
        .toList();

    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }

    return LdListPage<_Task>(
      newItems: filtered.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (int id) async {
    testData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  deleteBatch: (ids) async {
    for (final id in ids) {
      testData.removeWhere((element) => element.id == id);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  },
  updateItem: (id, newItem) async {
    final index = testData.indexWhere((element) => element.id == id);
    newItem = newItem.copyWith(lastUpdate: DateTime.now());
    testData[index] = newItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return newItem;
  },
  createItem: (id, item) async {
    testData.add(item!);

    return item;
  },
);

final taskDemo = LdMasterDetailRoute<_Task, int, bool>(
  path: "/task-demo",
  allowMultipleSelection: true,
  presentationMode: MasterDetailPresentationMode.page,
  layoutMode: MasterDetailLayoutMode.auto,
  showMultiSelectItems: true,
  parseId: (id) => int.parse(id),
  detailPath: (items) => "/task-demo/${items.join(",")}",
  buildRepository: (context) => taskRepository,
  buildDetail: (context, item) => _TaskDetail(task: item),
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<_Task, int, bool>(
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
      itemBuilder: (context, item, index, config) =>
          LdMasterDetailSingleShortcuts(
        item: item.value!.id,
        actions: route.actions,
        child: LdMasterDetailContextMenu<_Task, int, bool>(
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
                    LdMasterContext.of<_Task, int, bool>(context).isSplit,
              ),
            ),
          ),
        ),
      ),
    );
  },
  actions: [
    LdMasterDetailAction(
      visibility: {
        LdMasterDetailActionVisibility(
            location: LdMasterDetailActionLocation.detailAppBar,
            minSelectionCount: 1,
            maxSelectionCount: null,
            applyFilters: {"todo"}),
        LdMasterDetailActionVisibility(
            location: LdMasterDetailActionLocation.context,
            minSelectionCount: 1,
            maxSelectionCount: null,
            applyFilters: {"todo"}),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.keyD),
      },
      buildLoadingText: (context, selection) => "Marking as done",
      buildLabel: (context, selection) => "Done",
      buildIcon: (context, selection) => const Icon(LucideIcons.check),
      action: (context, selection) async {
        final updatedItems = <_Task>{};

        for (final id in selection) {
          final item = await taskRepository.getById(id);
          updatedItems.add(item.copyWith(done: true));
        }

        await taskRepository.updateBatch(updatedItems);
      },
    ),
    LdMasterDetailAction(
      visibility: {
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.detailAppBar,
          minSelectionCount: 1,
          maxSelectionCount: null,
          applyFilters: {"done"},
        ),
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.context,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.keyU),
      },
      buildLoadingText: (context, selection) => "Marking as undone",
      buildLabel: (context, selection) => "To do",
      buildIcon: (context, selection) => const Icon(LucideIcons.hourglass),
      action: (context, selection) async {
        final updatedItems = <_Task>{};

        for (final id in selection) {
          final item = await taskRepository.getById(id);
          updatedItems.add(item.copyWith(done: false));
        }

        await taskRepository.updateBatch(updatedItems);
      },
    ),
    LdMasterDetailAction(
      visibility: {
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.detailAppBar,
          minSelectionCount: 1,
          maxSelectionCount: 1,
        ),
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.context,
          minSelectionCount: 1,
          maxSelectionCount: 1,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.keyD, meta: true),
      },
      buildLoadingText: (context, selection) => "Duplicating",
      buildLabel: (context, selection) => "Duplicate",
      buildIcon: (context, selection) => const Icon(LucideIcons.copy),
      multiSelect: false,
      action: (context, selection) async {
        final item = await taskRepository.getById(selection.first);

        final newItem = item.copyWith(
          id: testData.length + 1,
          task: "${item.task} (copy)",
        );

        await taskRepository.create(newItem.id, newItem);

        await Future.delayed(const Duration(milliseconds: 1500));

        final route = LdMasterDetailRoute.of<_Task, int, bool>(context);

        route.setSelectedItems({newItem.id});
      },
    ),
    LdMasterDetailAction(
      visibility: {
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.detailAppBar,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.context,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
        LdMasterDetailActionVisibility(
          location: LdMasterDetailActionLocation.masterSecondary,
          minSelectionCount: 1,
          maxSelectionCount: null,
          visibleInSplitView: false,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.delete),
        SingleActivator(LogicalKeyboardKey.backspace),
      },
      buildLoadingText: (context, selection) =>
          "Deleting ${selection.length} ${selection.length == 1 ? "item" : "items"}",
      buildLabel: (context, selection) =>
          "Delete ${selection.length} ${selection.length == 1 ? "item" : "items"}",
      buildIcon: (context, selection) => Icon(
        LucideIcons.trash2,
      ),
      color: shadRed,
      action: (context, selection) async {
        await taskRepository.deleteBatch(selection);
      },
    ),
    toggleSelectionControls<_Task, int, bool>(),
    toggleFilters<_Task, int, bool>(),
  ],
);

class _TaskDetail extends StatefulWidget {
  final LdPaginatorItem<_Task> task;

  const _TaskDetail({required this.task});

  @override
  State<_TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<_TaskDetail> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _dueController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _taskController.text = widget.task.value?.task ?? "";
    _dueController.text = widget.task.value?.due != null
        ? Jiffy.parseFromDateTime(widget.task.value!.due).yMMMd
        : "";
    _dueDate = widget.task.value?.due;
  }

  @override
  void dispose() {
    _taskController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          LdReveal(
            revealed: widget.task.value?.done ?? false,
            child: LdBadge(
              size: LdSize.l,
              color: shadGreen,
              child: const Text("Done"),
            ),
          ),
          LdInput(
            label: "Task",
            hint: "What do you want to do?",
            controller: _taskController,
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _dueDate = picked;
                  _dueController.text = Jiffy.parseFromDateTime(picked).yMMMd;
                });
              }
            },
            child: AbsorbPointer(
              child: LdInput(
                label: "Due date",
                hint: "When do you want to do it?",
                controller: _dueController,
                disabled: true,
              ),
            ),
          ),
          LdText(
            "Last updated: ${Jiffy.parseFromDateTime(widget.task.value!.lastUpdate).fromNow()}",
          ),
          Row(
            children: [
              LdSubmit<void, void>(
                config: LdSubmitConfig<void, void>(
                  submitText: "Save",
                  action: (_) async {
                    final newTask = _Task(
                      widget.task.value!.id,
                      _taskController.text,
                      _dueDate ?? DateTime.now(),
                      widget.task.value!.done,
                      widget.task.value!.lastUpdate,
                    );
                    final repo =
                        LdMasterDetailRoute.of<_Task, int, bool>(context)
                            .repository;
                    await repo.update(
                      widget.task.value!.id,
                      newTask,
                    );
                  },
                ),
              ),
            ],
          ).spaceM(),
        ],
      ),
    ).padL();
  }
}

/*
class TaskDemo extends StatefulWidget {
  const TaskDemo({super.key});

  @override
  State<TaskDemo> createState() => _TaskDemoState();
}

class _TaskDemoState extends State<TaskDemo> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  late TextEditingController _controller;
  bool _hideDone = false;

  final List<_Task> _tasks = [
    _Task("Build spaceship 🚀 ", "any time", false),
    _Task("Build cool Flutter app", "any time", false),
  ];

  void _addTask(String task) {
    if (task.trim().isEmpty) {
      return;
    }
    if (_tasks.where((element) => element.task == task).isNotEmpty) {
      return;
    }

    setState(() {
      _tasks.insert(0, _Task(task.trim(), "any time", false));
    });

    _animatedListKey.currentState?.insertItem(0);
    _controller.clear();
  }

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  void _setComplete(int index, bool completed) {
    setState(() {
      _tasks[index] = _Task(_tasks[index].task, _tasks[index].due, completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    var done = _tasks.where((element) => element.done).length;
    return LdWindowFrame(
      title: const Text("Liquid Flutter"),
      frameBuilder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          appWindow.startDragging();
        },
        onDoubleTap: () => appWindow.maximizeOrRestore(),
        child: child,
      ),
      child: Scaffold(
        appBar: LdAppBar(
          title: const Text("Task Demo"),
          trailing: LdContextMenu(
            blurMode: LdContextMenuBlurMode.never,
            builder: (context, isOpen, open) => LdButtonGhost(
              onPressed: open,
              child: const Icon(LucideIcons.ellipsisVertical),
            ),
            menuBuilder: (context, dismiss) {
              return SizedBox(
                width: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdListItem(
                      leading: const Icon(LucideIcons.plus),
                      title: const Text("Add task"),
                      onTap: dismiss,
                    ),
                    LdListItem(
                      leading: const Icon(LucideIcons.trash),
                      title: const Text("Clear all"),
                      onTap: dismiss,
                    ),
                    LdDivider(),
                    LdListItem(
                      leading: const Icon(LucideIcons.settings),
                      title: const Text("Settings"),
                      onTap: dismiss,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: LdContainer(
          padding: EdgeInsets.zero,
          child: ListView(
              padding: LdTheme.of(context).pad(size: LdSize.l),
              children: [
                const LdTextH(
                  "Your tasks",
                ),
                ldSpacerM,
                Wrap(
                  children: [
                    LdHint(
                      type: LdHintType.success,
                      child: Text("$done done"),
                    ),
                    ldSpacerM,
                    LdHint(
                      type: LdHintType.info,
                      child: Text("${_tasks.length - done} pending"),
                    )
                  ],
                ),
                ldSpacerM,
                Row(
                  children: [
                    Expanded(
                        child: LdInput(
                      controller: _controller,
                      hint: "Add a task",
                      onSubmitted: (p0) {
                        _addTask(_controller.text);
                      },
                    )),
                    ldSpacerS,
                    LdButton(
                        child: const Text("Add"),
                        onPressed: () {
                          _addTask(_controller.text);
                        })
                  ],
                ),
                ldSpacerL,
                LdToggle(
                  label: "Hide done",
                  size: LdSize.m,
                  checked: _hideDone,
                  onChanged: (p0) {
                    setState(() {
                      _hideDone = p0;
                    });
                  },
                ),
                ldSpacerL,
                LdCard(
                  padding: EdgeInsets.zero,
                  child: ImplicitlyAnimatedList<_Task>(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemData: _hideDone
                          ? _tasks
                              .where(
                                (element) => !element.done,
                              )
                              .toList()
                          : _tasks,
                      itemEquality: (a, b) => a.task == b.task,
                      key: _animatedListKey,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: ((context, task) {
                        return LdListItem(
                          showSelectionControls: true,
                          subtitle: Text("Due ${task.due}"),
                          width: double.infinity,
                          isSelected: task.done,
                          title: Text(task.task),
                          onSelectionChange: (selected) {
                            _setComplete(_tasks.indexOf(task), selected);
                          },
                        );
                      })),
                )
              ]),
        ),
      ),
    );
  }
}
*/
