import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart'
    hide LdForm;
import 'package:provider/provider.dart';

/// A reactive range-slider field that binds to a [FormControl<(double, double)>]
/// by [formKey].
///
/// The control value is a Dart record `(double low, double high)`. Use
/// [LdReactiveFormItem] with an initial value like `(0.2, 0.8)`.
///
/// For a single-handle slider see [LdFormSlider].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormRangeSlider extends StatelessWidget {
  final String formKey;
  final String? label;
  final double min;
  final double max;
  final double step;
  final bool allowRangeDrag;
  final bool? disabled;
  final LdSize size;
  final LdColor? color;
  final LdHint? Function(
    ReactiveFormFieldState<(double, double), (double, double)>,
  )? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final String Function(double value)? valueFormatter;

  const LdFormRangeSlider({
    super.key,
    required this.formKey,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 0.0,
    this.allowRangeDrag = false,
    this.disabled,
    this.size = LdSize.m,
    this.color,
    this.hintBuilder,
    this.validationMessages,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<(double, double), (double, double)>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) {
        final value = state.control.value ?? (min, max);
        return ldBuildFormFieldChrome(
          state: state,
          formKey: formKey,
          hintBuilder: hintBuilder,
          context: context,
          field: LdSlider.range(
            label: label,
            lowValue: value.$1.clamp(min, max),
            highValue: value.$2.clamp(min, max),
            min: min,
            max: max,
            step: step,
            valueFormatter: valueFormatter,
            allowRangeDrag: allowRangeDrag,
            size: size,
            color: color,
            disabled: disabled ?? state.control.disabled,
            onRangeChanged: (low, high) {
              state.didChange((low, high));
              state.control.markAsTouched();
            },
            onRangeChangeEnd: () {
              scope?.onFieldCommitted(formKey);
            },
          ),
        );
      },
    );
  }
}
