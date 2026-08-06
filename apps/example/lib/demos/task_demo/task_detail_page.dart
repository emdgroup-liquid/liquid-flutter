import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_detail.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: LdMonkeyDetailAppbarConfig(
        appbarConfig: LdAppBarConfig(debugName: 'Detail App Bar Task', title: Text('Task')),
      ),
      child: LdMonkeyScrollableDetailPage<Task, int>(
        builder: (context, items) => items.map((item) => TaskDetail(task: item)).toList(),
      ),
    );
  }
}
