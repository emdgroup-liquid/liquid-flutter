import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Pure model descriptor for a single form control inside [LdReactiveForm] or
/// [LdMonkeyReactiveDetailForm].
///
/// [LdReactiveFormItem] only carries the information needed to construct a
/// [FormControl]: key, validators, initial value, value accessor, and disabled
/// flag. Widget-level concerns (label, hint, callbacks) live on the
/// corresponding form-field widgets ([LdFormInput], [LdFormSelect], etc.).
@immutable
class LdReactiveFormItem<TModel> {
  /// The key used to identify this control in the [FormGroup].
  final String key;

  /// Whether the control starts disabled.
  final bool disabled;

  /// Validators applied to this control.
  final List<Validator<dynamic>> validators;

  /// Initial value for the control.
  final TModel? initialValue;

  /// Optional value accessor. Defaults to [DefaultValueAccessor] when null.
  final ControlValueAccessor<TModel, dynamic>? valueAccessor;

  const LdReactiveFormItem({
    required this.key,
    this.disabled = false,
    this.validators = const [],
    this.initialValue,
    this.valueAccessor,
  });

  /// Convenience constructor for [int] controls — wires [IntValueAccessor].
  static LdReactiveFormItem<int> forInt({
    required String key,
    bool disabled = false,
    List<Validator<dynamic>> validators = const [],
    int? initialValue,
  }) {
    return LdReactiveFormItem<int>(
      key: key,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      valueAccessor: IntValueAccessor(),
    );
  }

  /// Convenience constructor for [double] controls — wires [DoubleValueAccessor].
  static LdReactiveFormItem<double> forDouble({
    required String key,
    bool disabled = false,
    List<Validator<dynamic>> validators = const [],
    double? initialValue,
  }) {
    return LdReactiveFormItem<double>(
      key: key,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      valueAccessor: DoubleValueAccessor(),
    );
  }

  /// Convenience constructor for [DateTime] controls — wires [DateTimeValueAccessor].
  static LdReactiveFormItem<DateTime> forDateTime({
    required String key,
    bool disabled = false,
    List<Validator<dynamic>> validators = const [],
    DateTime? initialValue,
  }) {
    return LdReactiveFormItem<DateTime>(
      key: key,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      valueAccessor: DateTimeValueAccessor(),
    );
  }

  /// Creates the [FormControl] for this item.
  FormControl<TModel> createFormControl() {
    return FormControl<TModel>(
      disabled: disabled,
      validators: validators,
      value: initialValue,
    );
  }
}
