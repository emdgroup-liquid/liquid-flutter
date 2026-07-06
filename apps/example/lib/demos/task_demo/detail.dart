import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_form.dart';
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

class LdTaskDetailForm extends StatelessWidget {
  final LdFormMode mode;
  final LdPaginatorItem<Task>? task;

  const LdTaskDetailForm({super.key, required this.mode, this.task});

  Task _initialTask() {
    final now = DateTime.now();
    return Task(0, '', now.add(const Duration(days: 1)), false, now);
  }

  @override
  Widget build(BuildContext context) {
    return LdForm<Task, int, Task, Task, Task>(
      mode: mode,
      item: task,
      itemToDetail: (context, task) => switch (mode) {
        LdFormMode.edit => Future.value(task),
        LdFormMode.create => Future.value(_initialTask()),
      },
      formItems: [
        LdReactiveFormItem<String>(key: 'task', validators: [Validators.required]),
        LdReactiveFormItem<DateTime>(key: 'due', validators: [Validators.required]),
        LdReactiveFormItem<String>(key: 'emoji'),
      ],
      saveMode: LdReactiveFormSaveMode.adaptive,
      conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      detailToFormValues: taskDetailToFormValues,
      formToUpdatePayload: taskFormToUpdatePayload,
      formToCreatePayload: taskFormToCreatePayload,

      child: LdAutoSpace(
        children: [
          Center(
            child: LdFormEmojiPicker(formKey: 'emoji', label: 'Emoji', size: LdSize.l),
          ),
          Center(
            child: LdReveal(
              revealed: task?.value?.done ?? false,
              initialRevealed: task?.value?.done ?? false,
              child: LdBadge.success(child: Text('Done')),
            ),
          ),
          LdFormInput<String>(
            formKey: 'task',
            label: 'Task',
            hint: 'What do you want to do?',
            maxLines: null,
            size: LdSize.l,
          ),

          LdFormDatePicker(formKey: 'due', label: 'Due date', useRootNavigator: true),

          Wrap(children: [LdFormSubmitButton(), LdFormResetButton()]).spaceM(),
        ],
      ),
    );
  }
}
