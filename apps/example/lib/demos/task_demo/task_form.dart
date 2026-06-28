import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

Map<String, Object?> taskDetailToFormValues(Task detail) => {
      'task': detail.task,
      'due': detail.due,
    };

List<LdReactiveFormItem<dynamic, dynamic>> buildTaskFormItems(
  LdMonkeyDetailFormFieldHooks hooks,
) =>
    [
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
    ];

Task taskFormToUpdatePayload(LdFormGroup form, Task detail) => detail.copyWith(
      task: form.control('task').value as String,
      due: form.control('due').value as DateTime,
    );

Task taskFormToCreatePayload(LdFormGroup form, Task detail, int id) => detail.copyWith(
      id: id,
      task: form.control('task').value as String,
      due: form.control('due').value as DateTime,
      lastUpdate: DateTime.now(),
    );

Task taskCreateDraft() {
  final now = DateTime.now();
  return Task(
    0,
    '',
    now.add(const Duration(days: 1)),
    false,
    now,
  );
}
