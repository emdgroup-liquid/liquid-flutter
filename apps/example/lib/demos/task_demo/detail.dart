import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/task.dart';
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
          LdReveal(
            revealed: taskValue.done,
            initialRevealed: taskValue.done,
            child: LdBadge.success(child: Text('Done')),
          ),
          LdMonkeyReactiveDetailForm<Task, int, Task>(
            item: task,
            saveMode: LdMonkeyDetailSaveMode.adaptive,
            detailToFormValues: (detail) => {
              'task': detail.task,
              'due': detail.due,
            },
            mapToEntity: (form, detail) => detail.copyWith(
              task: form.control('task').value as String,
              due: form.control('due').value as DateTime,
            ),
            submitConfig: LdFormSubmitConfig(submitText: 'Save'),
            itemsBuilder: (context, hooks) => [
              LdReactiveFormItem.input(
                key: 'task',
                label: 'Task',
                inputFieldHint: 'What do you want to do?',
                maxLines: null,
                size: LdSize.l,
                validators: [LdFormValidators.required],
                onBlurred: hooks.onBlurred('task'),
              ),
              LdReactiveFormItem.datePicker(
                key: 'due',
                label: 'Due date',
                useRootNavigator: true,
                validators: [LdFormValidators.required],
                onCommitted: hooks.onCommitted('due'),
              ),
            ],
          ),
          LdText('Last updated: ${Jiffy.parseFromDateTime(taskValue.lastUpdate).fromNow()}'),
        ],
      ),
    );
  }
}
