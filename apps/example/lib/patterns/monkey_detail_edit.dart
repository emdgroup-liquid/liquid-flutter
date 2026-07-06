import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyDetailEditDemo extends StatelessWidget {
  const MonkeyDetailEditDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/patterns/monkey_detail_edit.dart',
      category: 'Patterns',
      title: 'LdMonkey - Detail Editing',
      apiComponents: const [
        'LdMonkeyReactiveDetailForm',
        'LdLocationLockRegistry',
        'LdLocationLock',
        'ldLocationLockRedirect',
      ],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            'Editable monkey detail pages should use LdMonkeyReactiveDetailForm from liquid_flutter_reactive_forms. '
            'It wires reactive form fields to LdModel.update, adaptive blur/manual save, server merge, '
            'and LdLocationLockGuard for unsaved edits.',
          ),
          ComponentsAccordion(
            components: const {
              'LdMonkeyReactiveDetailForm',
              'LdReactiveFormItem',
              'LdMonkeyDetailFormScope',
            },
          ),
          LdText.hs('1. Basic detail form'),
          LdText.p(
            'Pass the paginator item from buildDetail, map entity fields to form values, and map back on save.',
          ),
          CodeBlock(
            language: 'dart',
            code: '''LdMonkeyReactiveDetailForm<Task, int, Task, Task, Task>.edit(
  item: task,
  saveMode: LdMonkeyDetailSaveMode.adaptive,
  detailToFormValues: (detail) => {
    'task': detail.task,
    'due': detail.due,
  },
  formToUpdatePayload: (form, detail) => detail.copyWith(
    task: form.control('task').value as String,
    due: form.control('due').value as DateTime,
  ),
  items: [
    LdReactiveFormItem<String>(
      key: 'task',
      validators: [LdFormValidators.required],
    ),
    LdReactiveFormItem<DateTime>(
      key: 'due',
      validators: [LdFormValidators.required],
    ),
  ],
  childrenBuilder: (context, hooks) => [
    LdFormInput<String>(
      formKey: 'task',
      hint: 'What do you want to do?',
      onBlurred: hooks.onBlurred('task'),
    ),
    // Arbitrary widgets can be placed anywhere alongside form fields.
    const LdBanner(child: Text('Fill in all fields before saving.')),
    LdFormDatePicker(
      formKey: 'due',
      label: 'Due date',
      onCommitted: hooks.onCommitted('due'),
    ),
  ],
)''',
          ),
          LdText.hs('2. Save modes'),
          LdText.p(
            'LdMonkeyDetailSaveMode.adaptive saves on blur for mobile and shows a Save button on desktop. '
            'Use onBlur for always blur-save or manualSubmit for explicit submit only.',
          ),
          LdText.hs('3. Read-only detail chrome'),
          LdText.p(
            'Keep badges, timestamps, and other read-only UI outside the form. '
            'The task demo wraps LdMonkeyReactiveDetailForm with a Done badge and last-updated label.',
          ),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem.trailingForward(
                  title: Text('Task demo source'),
                  onPressed: () => context.push('/task-demo'),
                ),
                LdListItem.trailingForward(
                  title: Text('Movie demo source'),
                  onPressed: () => context.push('/movie-demo'),
                ),
              ],
            ),
          ),
          LdText.hs('4. Navigation guards'),
          LdText.p(
            'Wire ldLocationLockRedirect on GoRouter.redirect. LdMonkeyReactiveDetailForm registers its own '
            'LdLocationLock while dirty or saving and disables predictive back via PopScope. Non-reactive '
            'editors use LdLocationLockRegistry directly.',
          ),
          CodeBlock(
            language: 'dart',
            code: '''GoRouter(
  redirect: ldLocationLockRedirect,
  routes: [...],
)''',
          ),
          LdText.hs('5. Custom layout with form scope'),
          LdText.p(
            'LdMonkeyDetailFormScope exposes isDirty, isSaving, save, reset, and detail for custom chrome '
            '(e.g. a toolbar Save button).',
          ),
          CodeBlock(
            language: 'dart',
            code: '''LdMonkeyDetailFormScope<Task>(
  child: Builder(
    builder: (context) {
      final scope = LdMonkeyDetailFormScope.of<Task>(context);
      return LdButton.filled(
        disabled: !scope.isDirty || scope.isSaving,
        child: Text('Save'),
        onPressed: scope.save,
      );
    },
  ),
)''',
          ),
          LdText.hs('6. Separate detail type'),
          LdText.p(
            'When the list entity differs from the full record, pass loadDetail and detailFromEntity '
            'as the third type parameter TDetail.',
          ),
          LdText.hs('Live example'),
          LdText.p('See TaskDetail in the task demo:'),
          CodeBlock(
            language: 'dart',
            code: 'buildDetail: (context, item) => TaskDetail(task: item),',
          ),
        ],
      ),
    );
  }
}
