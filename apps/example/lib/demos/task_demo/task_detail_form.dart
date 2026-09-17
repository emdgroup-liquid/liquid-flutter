import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_actions.dart';
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

  void _onCreated(BuildContext context, Task? task) {
    taskRouteConfig.pushDetailRoute(context, {task!.id});
  }

  @override
  Widget build(BuildContext context) {
    return LdForm<Task, int, Task, Task, Task>(
      mode: mode,
      item: task,
      layoutMode: switch (mode) {
        LdFormMode.edit => LdFormLayoutMode.inline,
        LdFormMode.create => LdFormLayoutMode.page,
      },
      itemToDetail: (context, task) => switch (mode) {
        LdFormMode.edit => Future.value(task),
        LdFormMode.create => Future.value(_initialTask()),
      },
      onSubmitted: (context, created) {
        if (mode == LdFormMode.create && created != null) {
          _onCreated(context, created);
        }
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
            child: LdReveal(
              revealed: task?.value?.done ?? false,
              initialRevealed: task?.value?.done ?? false,
              child: LdBadge.success(child: Text('Done')),
            ),
          ),
          LdInputGroup(
            children: [
              LdFormEmojiPicker(formKey: 'emoji', label: 'Emoji'),
              Expanded(
                child: LdFormInput<String>(
                  formKey: 'task',
                  label: 'Task',
                  hint: 'What do you want to do?',
                  maxLines: null,
                ),
              ),
            ],
          ),
          LdFormDatePicker(formKey: 'due', label: 'Due date', useRootNavigator: true),
        ],
      ),
    );
  }
}
