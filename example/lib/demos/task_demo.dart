import 'package:flutter/material.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
    return LdContainer(
      child: ListView(children: [
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
    );
  }
}
