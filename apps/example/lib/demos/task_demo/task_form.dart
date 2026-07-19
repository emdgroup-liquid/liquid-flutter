import 'package:liquid/demos/task_demo/task.dart';
import 'package:reactive_forms/reactive_forms.dart';

Map<String, Object?> taskDetailToFormValues(Task detail) => {
  'task': detail.task,
  'due': detail.due,
  'emoji': detail.emoji,
};

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
