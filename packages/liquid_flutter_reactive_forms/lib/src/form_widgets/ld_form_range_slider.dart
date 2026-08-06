import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart'
    hide LdForm;
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_slider_value_input.dart';
import 'package:provider/provider.dart';

/// A reactive range-slider field that binds to a [FormControl<(double, double)>]
/// by [formKey].
///
/// The control value is a Dart record `(double low, double high)`. Use
/// [LdReactiveFormItem] with an initial value like `(0.2, 0.8)`.
///
/// When [showValueInput] is true (the default), compact number fields are shown
/// leading (low) and trailing (high) the slider so values can be typed.
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
  final bool showValueInput;
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
    this.showValueInput = true,
    this.size = LdSize.m,
    this.color,
    this.hintBuilder,
    this.validationMessages,
    this.valueFormatter,
  });

  double get _minSeparation => step > 0 ? step : 0.001 * (max - min);

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<(double, double), (double, double)>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) {
        final isDisabled = disabled ?? state.control.disabled;
        final value = state.control.value ?? (min, max);
        final low = value.$1.clamp(min, max);
        final high = value.$2.clamp(min, max);

        void didChangeRange(double nextLow, double nextHigh) {
          state.didChange((nextLow, nextHigh));
          state.control.markAsTouched();
        }

        void onCommitted() {
          scope?.onFieldCommitted(formKey);
        }

        final slider = LdSlider.range(
          label: showValueInput ? null : label,
          lowValue: low,
          highValue: high,
          min: min,
          max: max,
          step: step,
          valueFormatter: valueFormatter,
          allowRangeDrag: allowRangeDrag,
          size: size,
          color: color,
          disabled: isDisabled,
          onRangeChanged: didChangeRange,
          onRangeChangeEnd: onCommitted,
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
                    LdFormSliderValueInput(
                      value: low,
                      min: min,
                      max: high - _minSeparation,
                      step: step,
                      disabled: isDisabled,
                      size: size,
                      onChanged: (nextLow) {
                        didChangeRange(nextLow, high);
                      },
                      onCommitted: onCommitted,
                    ),
                    Expanded(child: slider),
                    LdFormSliderValueInput(
                      value: high,
                      min: low + _minSeparation,
                      max: max,
                      step: step,
                      disabled: isDisabled,
                      size: size,
                      onChanged: (nextHigh) {
                        didChangeRange(low, nextHigh);
                      },
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
      },
    );
  }
}
