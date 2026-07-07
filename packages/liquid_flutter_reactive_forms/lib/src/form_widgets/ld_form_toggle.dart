import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_field_base.dart';
import 'package:provider/provider.dart';

/// A reactive on/off toggle that binds to a [FormControl<bool>] by [formKey].
///
/// Wraps [LdToggle] — an iOS-style switch. For a checkbox alternative see
/// [LdFormCheckbox].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormToggle extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final LdSize size;
  final LdColor? color;
  final LdHint? Function(ReactiveFormFieldState<bool, bool>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormToggle({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.color,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<bool, bool>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdToggle(
          label: label,
          checked: state.control.value ?? false,
          size: size,
          color: color,
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
