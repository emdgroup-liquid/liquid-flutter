import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_field_base.dart';

/// A reactive checkbox field that binds to a [FormControl<bool>] by [formKey].
class LdFormCheckbox extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final LdHint? Function(ReactiveFormFieldState<bool, bool>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormCheckbox({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<bool, bool>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdCheckbox(
          label: label,
          color: state.control.valid || state.control.pristine ? null : shadRed,
          checked: state.control.value ?? false,
          onChanged: (value) => state.didChange(value),
          disabled: disabled ?? state.control.disabled,
        ),
      ),
    );
  }
}
