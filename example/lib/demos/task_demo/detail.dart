import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    _dueController.text = widget.task.value?.due != null ? Jiffy.parseFromDateTime(widget.task.value!.due).yMMMd : "";
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
    if (widget.task.value == null) {
      return LdCard(child: Center(child: LdLoader()));
    }
    return LdWrapConditional(
      condition: LdMonkeyShellState.of<Task, int>(context).selectedItems.length > 1,
      builder: (context, child) {
        return LdCard(
          child: child,
        );
      },
      child: LdAutoSpace(
        children: [
          LdReveal(revealed: widget.task.value?.done == true, child: LdBadge.success(child: Text("Done"))),
          LdInput(
            hint: "What do you want to do?",
            maxLines: null,
            controller: _taskController,
            size: LdSize.l,
          ),
          LdDatePicker(
            useRootNavigator: true,
            label: "Due date",
            onChanged: (date) {
              if (date == null) return;
              setState(() {
                _dueDate = date;
                _dueController.text = Jiffy.parseFromDateTime(date).yMMMd;
              });
            },
          ),
          LdText(
            "Last updated: ${Jiffy.parseFromDateTime(widget.task.value!.lastUpdate).fromNow()}",
          ),
          Row(
            children: [
              LdReveal.quick(
                revealed: _taskController.text.isNotEmpty && _dueDate != null,
                child: LdSubmit<void, void>(
                  config: LdSubmitConfig<void, void>(
                    submitText: "Save",
                    debugLabel: "Save Task",
                    action: (_) async {
                      final newTask = Task(
                        widget.task.value!.id,
                        _taskController.text,
                        _dueDate ?? DateTime.now(),
                        widget.task.value!.done,
                        widget.task.value!.lastUpdate,
                      );
                      final repo = LdRepository.of<Task, int>(context);
                      await repo.update(
                        widget.task.value!.id,
                        newTask,
                      );
                    },
                  ),
                ),
              ),
            ],
          ).spaceM(),
        ],
      ),
    );
  }
}
