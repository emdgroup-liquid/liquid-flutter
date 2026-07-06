import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_field_base.dart';

/// A reactive date-picker field that binds to a [FormControl<DateTime>] by [formKey].
class LdFormDatePicker extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final bool useRootNavigator;

  final LdHint? Function(ReactiveFormFieldState<DateTime, DateTime>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormDatePicker({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.useRootNavigator = false,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<DateTime, DateTime>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdDatePicker(
          label: label,
          value: state.control.value,
          useRootNavigator: useRootNavigator,
          onChanged: (value) {
            state.didChange(value);
          },
        ),
      ),
    );
  }
}
