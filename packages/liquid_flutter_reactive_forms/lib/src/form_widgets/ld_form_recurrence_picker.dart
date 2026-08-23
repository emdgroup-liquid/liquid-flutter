import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';

/// A reactive recurrence-picker field that binds to a [FormControl<RecurrenceRule>] by [formKey].
class LdFormRecurrencePicker extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final LdSize size;
  final bool useRootNavigator;
  final DateTime? start;
  final LdRecurrenceConfig config;

  final LdHint? Function(
    ReactiveFormFieldState<RecurrenceRule, RecurrenceRule>,
  )? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormRecurrencePicker({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.useRootNavigator = false,
    this.start,
    this.config = const LdRecurrenceConfig(),
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<RecurrenceRule, RecurrenceRule>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdRecurrencePicker(
          label: label,
          value: state.control.value,
          start: start,
          size: size,
          config: config,
          useRootNavigator: useRootNavigator,
          disabled: disabled ?? state.control.disabled,
          onChanged: (value) {
            state.didChange(value);
            state.control.markAsTouched();
            scope?.onFieldCommitted(formKey);
          },
        ),
      ),
    );
  }
}
