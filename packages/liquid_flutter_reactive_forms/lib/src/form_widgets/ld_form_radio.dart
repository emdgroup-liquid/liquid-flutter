import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:provider/provider.dart';

/// A reactive radio-button group that binds to a [FormControl<T>] by [formKey].
///
/// Each entry in [children] renders as an [LdRadio]. The radio whose key equals
/// the control's current value appears checked; selecting another radio writes
/// that key to the control.
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormRadio<T> extends StatelessWidget {
  final String formKey;

  /// Maps each selectable value to a label string shown beside its radio button.
  final Map<T, String> children;

  final String? label;
  final bool? disabled;
  final LdSize size;
  final LdColor? color;
  final LdHint? Function(ReactiveFormFieldState<T, T>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormRadio({
    super.key,
    required this.formKey,
    required this.children,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.color,
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
        field: LdAutoSpace(
          children: [
            if (label != null) LdText.l(label!, size: size),
            for (final entry in children.entries)
              LdRadio(
                label: entry.value,
                checked: state.control.value == entry.key,
                size: size,
                color: color,
                disabled: disabled ?? state.control.disabled,
                onChanged: (checked) {
                  if (checked) {
                    state.didChange(entry.key);
                    state.control.markAsTouched();
                    scope?.onFieldCommitted(formKey);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
