import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:provider/provider.dart';

/// A reactive duration-picker field that binds to a [FormControl<LdDuration>] by [formKey].
///
/// Wraps [LdDurationPicker] — a button that opens a wheel + text-field modal.
/// For a time picker see [LdFormTimePicker].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormDurationPicker extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final LdSize size;
  final bool useRootNavigator;
  final LdDurationConfig config;
  final LdHint? Function(ReactiveFormFieldState<LdDuration, LdDuration>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormDurationPicker({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.useRootNavigator = false,
    this.config = const LdDurationConfig(),
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<LdDuration, LdDuration>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdDurationPicker(
          label: label,
          value: state.control.value,
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
