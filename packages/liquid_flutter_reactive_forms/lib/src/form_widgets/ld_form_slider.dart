import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_slider_value_input.dart';
import 'package:provider/provider.dart';

/// A reactive slider field that binds to a [FormControl<double>] by [formKey].
///
/// When [showValueInput] is true (the default), a compact number field is shown
/// trailing the slider so the value can be typed as well as dragged.
class LdFormSlider extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final double min;
  final double max;
  final double step;
  final bool isInteger;
  final bool showValueInput;
  final LdSize size;

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
    this.showValueInput = true,
    this.size = LdSize.m,
    this.hintBuilder,
    this.validationMessages,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();

    Widget builder(ReactiveFormFieldState<num, num> state) {
      final isDisabled = disabled ?? state.control.disabled;
      final value = switch (isInteger) {
        true => (state.control.value as int?)?.toDouble() ?? min,
        false => ((state.control.value as double?) ?? min).clamp(min, max),
      };

      void didChange(double next) {
        if (isInteger) {
          state.didChange(next.toInt());
        } else {
          state.didChange(next);
        }
      }

      void onCommitted() {
        scope?.onFieldCommitted(formKey);
      }

      final slider = LdSlider(
        label: showValueInput ? null : label,
        value: value,
        min: min,
        max: max,
        valueFormatter: valueFormatter,
        step: step,
        size: size,
        disabled: isDisabled,
        onChanged: didChange,
        onChangeEnd: onCommitted,
      );

      final field = switch (showValueInput) {
        false => slider,
        true => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                LdText.l(
                  label!,
                  size: size,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: slider),
                  LdFormSliderValueInput(
                    value: value,
                    min: min,
                    max: max,
                    step: step,
                    isInteger: isInteger,
                    disabled: isDisabled,
                    size: size,
                    onChanged: didChange,
                    onCommitted: onCommitted,
                  ),
                ],
              ).spaceS(),
            ],
          ).spaceS(),
      };

      return ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: field,
      );
    }

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
