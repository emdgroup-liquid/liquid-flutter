import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Task {
  final String task;
  final String due;
  final bool done;
  _Task(this.task, this.due, this.done);
}

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
