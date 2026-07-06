import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';

/// A reactive slider field that binds to a [FormControl<double>] by [formKey].
class LdFormSlider extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final double min;
  final double max;
  final double step;

  final LdHint? Function(ReactiveFormFieldState<double, double>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormSlider({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<double, double>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdSlider(
          label: label,
          value: (state.control.value ?? min).clamp(min, max),
          min: min,
          max: max,
          step: step,
          onChanged: (value) {
            state.didChange(value);
            scope?.onFieldCommitted(formKey);
          },
        ),
      ),
    );
  }
}
