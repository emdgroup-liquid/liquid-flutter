import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

Map<String, Object?> _taskDetailToFormValues(Task detail) => {
  'task': detail.task,
  'due': detail.due,
  'emoji': detail.emoji,
};

Task _taskFormToUpdatePayload(FormGroup form, Task detail) => detail.copyWith(
  task: form.control('task').value as String,
  due: form.control('due').value as DateTime,
  emoji: form.control('emoji').value as String? ?? detail.emoji,
);

Task _taskFormToCreatePayload(FormGroup form, Task detail) => detail.copyWith(
  task: form.control('task').value as String,
  due: form.control('due').value as DateTime,
  emoji: form.control('emoji').value as String? ?? detail.emoji,
  lastUpdate: DateTime.now(),
);

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
      formGroup: (context) => FormGroup({
        'task': FormControl<String>(validators: [Validators.required]),
        'due': FormControl<DateTime>(validators: [Validators.required]),
        'emoji': FormControl<String>(),
      }),
      saveMode: LdReactiveFormSaveMode.adaptive,
      conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      detailToFormValues: _taskDetailToFormValues,
      formToUpdatePayload: _taskFormToUpdatePayload,
      formToCreatePayload: _taskFormToCreatePayload,
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
