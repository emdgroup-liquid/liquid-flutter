import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:provider/provider.dart';

/// A reactive time-picker field that binds to a [FormControl<TimeOfDay>] by [formKey].
///
/// Wraps [LdTimePicker] — a button that opens a wheel + text-field modal.
/// For a date picker see [LdFormDatePicker].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormTimePicker extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final int minutePrecision;
  final bool useRootNavigator;
  final LdHint? Function(ReactiveFormFieldState<TimeOfDay, TimeOfDay>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormTimePicker({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.minutePrecision = 15,
    this.useRootNavigator = false,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<TimeOfDay, TimeOfDay>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdTimePicker(
          label: label,
          value: state.control.value,
          minutePrecision: minutePrecision,
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
