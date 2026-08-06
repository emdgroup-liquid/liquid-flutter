import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_detail_form.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

class TaskDetail extends StatelessWidget {
  final LdPaginatorItem<Task> task;

  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.value == null) {
      return LdCard(child: Center(child: LdLoader()));
    }

    final selection = LdMonkeySelection.of<Task, int>(context, listen: true);
    final taskValue = task.value!;

    return LdWrapConditional(
      condition: selection.viewing.length > 1,
      builder: (context, child) => LdCard(child: child),
      child: LdAutoSpace(
        children: [
          LdTaskDetailForm(mode: LdFormMode.edit, task: task),
          LdMute(child: LdText.ls('Last updated: ${Jiffy.parseFromDateTime(taskValue.lastUpdate).fromNow()}')),
        ],
      ),
    );
  }
}
