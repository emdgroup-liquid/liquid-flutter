import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

Map<String, Object?> taskDetailToFormValues(Task detail) => {
  'task': detail.task,
  'due': detail.due,
  'emoji': detail.emoji,
};

List<LdReactiveFormItem<dynamic>> buildTaskFormItems() => [
  LdReactiveFormItem<String>(key: 'task', validators: [Validators.required]),
  LdReactiveFormItem<DateTime>(key: 'due', validators: [Validators.required]),
  LdReactiveFormItem<String>(key: 'emoji'),
];

Task taskFormToUpdatePayload(FormGroup form, Task detail) => detail.copyWith(
  task: form.control('task').value as String,
  due: form.control('due').value as DateTime,
  emoji: form.control('emoji').value as String? ?? detail.emoji,
);

Task taskFormToCreatePayload(FormGroup form, Task detail) => detail.copyWith(
  task: form.control('task').value as String,
  due: form.control('due').value as DateTime,
  emoji: form.control('emoji').value as String? ?? detail.emoji,
  lastUpdate: DateTime.now(),
);
