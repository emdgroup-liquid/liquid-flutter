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
  final bool isInteger;

  final LdHint? Function(ReactiveFormFieldState<num, num>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final String Function(double value)? valueFormatter;

  const LdFormSlider({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.isInteger = false,
    this.hintBuilder,
    this.validationMessages,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();

    Widget builder(ReactiveFormFieldState<num, num> state) =>
        ldBuildFormFieldChrome(
          state: state,
          formKey: formKey,
          hintBuilder: hintBuilder,
          context: context,
          field: LdSlider(
            label: label,
            value: switch (isInteger) {
              true => (state.control.value as int?)?.toDouble() ?? min,
              false =>
                ((state.control.value as double?) ?? min).clamp(min, max),
            },
            min: min,
            max: max,
            valueFormatter: valueFormatter,
            step: step,
            onChanged: (value) {
              if (isInteger) {
                state.didChange(value.toInt());
              } else {
                state.didChange(value);
              }
            },
            onChangeEnd: () {
              scope?.onFieldCommitted(formKey);
            },
          ),
        );
    if (isInteger) {
      return ReactiveFormField<int, int>(
        formControlName: formKey,
        validationMessages: validationMessages ?? {},
        showErrors: ldReactiveFormShowErrors,
        builder: builder,
      );
    }
    return ReactiveFormField<double, double>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: builder,
    );
  }
}
