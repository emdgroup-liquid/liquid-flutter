import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:provider/provider.dart';

/// A reactive inline dropdown that binds to a [FormControl<T?>] by [formKey].
///
/// Wraps [LdSelect] — an inline context-menu dropdown. For a full-page or modal
/// picker with search and pagination support, see [LdFormChoose].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormSelect<T> extends StatelessWidget {
  final String formKey;
  final List<LdSelectItem<T>> items;
  final String? label;
  final String? placeholder;
  final bool? disabled;
  final LdSize size;
  final bool onSurface;
  final LdHint? Function(ReactiveFormFieldState<T?, T?>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormSelect({
    super.key,
    required this.formKey,
    required this.items,
    this.label,
    this.placeholder,
    this.disabled,
    this.size = LdSize.m,
    this.onSurface = false,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<T?, T?>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdSelect<T>(
          items: items,
          label: label,
          placeholder: placeholder,
          size: size,
          onSurface: onSurface,
          value: state.control.value,
          valid: state.control.valid || state.control.pristine,
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
