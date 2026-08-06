import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/task_detail_form.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

class TaskCreatePage extends StatelessWidget {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar.top(
        title: LdText.h('New task'),
        child: LdScaffoldBody(addContainer: true, children: [LdTaskDetailForm(mode: LdFormMode.create)]),
      ),
    );
  }
}
