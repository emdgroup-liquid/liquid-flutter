import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'task_model.dart';
import 'task_demo.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final bool isEditing;

  const TaskDetailPage({
    super.key,
    required this.task,
    this.isEditing = false,
  });

  @override
  State<TaskDetailPage> createState() => TaskDetailPageState();
}

class TaskDetailPageState extends State<TaskDetailPage> {
  Task? _editingTask;
  Task? get editingTask => _editingTask;
  Task get currentTask => editingTask ?? widget.task;
  bool get isDirty =>
      widget.task.task != editingTask?.task ||
      widget.task.description != editingTask?.description ||
      widget.task.due != editingTask?.due ||
      widget.task.priority != editingTask?.priority ||
      widget.task.done != editingTask?.done;

  late final TextEditingController _taskController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dueController;

  @override
  void initState() {
    super.initState();
    _editingTask = widget.isEditing ? widget.task : null;
    _taskController = TextEditingController(text: currentTask.task);
    _descriptionController =
        TextEditingController(text: currentTask.description);
    _dueController = TextEditingController(text: currentTask.due);
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TaskDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditing != widget.isEditing) {
      _editingTask = widget.isEditing ? widget.task : null;
      _taskController.text = currentTask.task;
      _descriptionController.text = currentTask.description ?? '';
      _dueController.text = currentTask.due;
    }
  }

  void updateTask(
      {String? task,
      String? description,
      String? due,
      TaskPriority? priority,
      bool? done}) {
    setState(() {
      _editingTask = _editingTask?.copyWith(
          task: task,
          description: description,
          due: due,
          priority: priority,
          done: done);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LdAutoSpace(
        children: [
          if (widget.isEditing)
            LdInput(
              controller: _taskController,
              onChanged: (value) => updateTask(task: value),
              hint: 'Task Name',
            )
          else
            Row(
              children: [
                LdTextH(currentTask.task),
                if (currentTask.done) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check),
                ]
              ],
            ),
          ldSpacerL,
          if (widget.isEditing)
            LdInput(
              controller: _descriptionController,
              onChanged: (value) => updateTask(description: value),
              maxLines: 3,
              hint: 'Description',
            )
          else if (currentTask.description != null) ...[
            Row(
              children: [
                const Icon(Icons.description),
                const SizedBox(width: 8),
                Expanded(
                  child: LdTextL(currentTask.description!),
                ),
              ],
            ),
            ldSpacerM,
          ],
          if (widget.isEditing)
            LdInput(
              controller: _dueController,
              onChanged: (value) => updateTask(due: value),
              hint: 'Due Date',
            )
          else
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                LdTextL(currentTask.due),
              ],
            ),
          ldSpacerM,
          if (widget.isEditing)
            LdSelect(
              value: currentTask.priority,
              onChange: (value) => updateTask(priority: value),
              items: TaskPriority.values.map((priority) {
                return LdSelectItem(
                  value: priority,
                  child: Text(TaskPriorityUIX(priority).text),
                );
              }).toList(),
            )
          else
            Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: TaskPriorityUIX(currentTask.priority).color,
                ),
                const SizedBox(width: 8),
                LdTextL(
                  TaskPriorityUIX(currentTask.priority).text,
                  color: TaskPriorityUIX(currentTask.priority).color,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          if (widget.isEditing && !widget.task.isNew) ...[
            ldSpacerL,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context
                      .findAncestorStateOfType<TaskDemoState>()
                      ?.setIsEditingDetail(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
