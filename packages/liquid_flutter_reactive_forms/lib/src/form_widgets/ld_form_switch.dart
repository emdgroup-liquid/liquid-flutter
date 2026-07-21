import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart'
    hide LdForm;
import 'package:provider/provider.dart';

/// A reactive segmented-control field that binds to a [FormControl<T>] by [formKey].
///
/// Wraps [LdSwitch] — a tab-bar-style selector where the user picks one value
/// from a fixed [Map<T, Widget>] of options.
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormSwitch<T> extends StatelessWidget {
  final String formKey;
  final String? label;
  final Map<T, Widget> children;
  final bool? disabled;
  final LdSize size;
  final LdColor? color;
  final bool expand;
  final LdHint? Function(ReactiveFormFieldState<T, T>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormSwitch({
    super.key,
    required this.formKey,
    required this.children,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.color,
    this.expand = false,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<T, T>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdSwitch<T>(
          label: label,
          children: children,
          value: state.control.value as T,
          size: size,
          color: color,
          expand: expand,
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
