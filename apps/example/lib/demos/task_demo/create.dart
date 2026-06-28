import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_form.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

int _nextTaskId() {
  return testData.fold<int>(0, (max, task) => task.id > max ? task.id : max) + 1;
}

class TaskCreatePage extends StatelessWidget {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar.top(
        title: LdText.h('New task'),
        child: LdScaffoldBody(
          addContainer: true,
          children: [
            LdMonkeyReactiveDetailForm<Task, int, Task, Task, Task>.create(
            initialDetail: taskCreateDraft(),
            detailToFormValues: taskDetailToFormValues,
            formToCreatePayload: (form, detail) => taskFormToCreatePayload(
              form,
              detail,
              _nextTaskId(),
            ),
            submitConfig: LdFormSubmitConfig(submitText: 'Create'),
            onCreated: (context, created) {
              LdMonkeySelection.updateViewing<Task, int>(context, {created.id});
            },
            itemsBuilder: (context, hooks) => buildTaskFormItems(hooks),
          ),
          ],
        ),
      ),
    );
  }
}
