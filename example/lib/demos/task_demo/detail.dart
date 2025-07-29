import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class TaskDetail extends StatefulWidget {
  final LdPaginatorItem<Task> task;

  const TaskDetail({super.key, required this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
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
                    final newTask = Task(
                      widget.task.value!.id,
                      _taskController.text,
                      _dueDate ?? DateTime.now(),
                      widget.task.value!.done,
                      widget.task.value!.lastUpdate,
                    );
                    final repo =
                        LdMonkey.of<Task, int, bool>(context).repository;
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
