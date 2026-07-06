import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart' hide LdForm;
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// A reactive text-input field that binds to a [FormControl] by [formKey].
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormInput<T> extends StatefulWidget {
  final String formKey;
  final String hint;
  final String? label;
  final bool? disabled;
  final int? maxLines;
  final LdSize size;

  final LdHint? Function(ReactiveFormFieldState<T, String>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormInput({
    super.key,
    required this.formKey,
    required this.hint,
    this.label,
    this.disabled,
    this.maxLines = 1,
    this.size = LdSize.m,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  State<LdFormInput<T>> createState() => _LdFormInputState<T>();
}

class _LdFormInputState<T> extends State<LdFormInput<T>> {
  late final ControlValueAccessor<T, String> _valueAccessor;

  @override
  void initState() {
    super.initState();
    _valueAccessor = switch (T) {
      const (int) => IntValueAccessor() as ControlValueAccessor<T, String>,
      const (double) => DoubleValueAccessor() as ControlValueAccessor<T, String>,
      const (DateTime) => DateTimeValueAccessor() as ControlValueAccessor<T, String>,
      const (TimeOfDay) => TimeOfDayValueAccessor() as ControlValueAccessor<T, String>,
      _ => DefaultValueAccessor<T, String>() as ControlValueAccessor<T, String>,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<T, String>(
      formControlName: widget.formKey,
      valueAccessor: _valueAccessor,
      validationMessages: widget.validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: widget.formKey,
        hintBuilder: widget.hintBuilder,
        context: context,
        field: _LdFormInputField<T>(
          state: state,
          hint: widget.hint,
          label: widget.label,
          maxLines: widget.maxLines,
          size: widget.size,
          disabled: widget.disabled,
          onBlurred: (value) => scope?.onFieldBlurred(widget.formKey),
          onCommitted: (value) => scope?.onFieldCommitted(widget.formKey),
        ),
      ),
    );
  }
}

class _LdFormInputField<T> extends StatefulWidget {
  final ReactiveFormFieldState<T, String> state;
  final String hint;
  final String? label;
  final bool? disabled;
  final int? maxLines;
  final LdSize size;
  final void Function(String value)? onBlurred;
  final void Function(String value)? onCommitted;

  const _LdFormInputField({
    required this.state,
    required this.hint,
    required this.label,
    required this.disabled,
    required this.maxLines,
    required this.size,
    required this.onBlurred,
    required this.onCommitted,
  });

  @override
  State<_LdFormInputField<T>> createState() => _LdFormInputFieldState<T>();
}

class _LdFormInputFieldState<T> extends State<_LdFormInputField<T>> {
  late final TextEditingController _controller;
  bool _suppressChange = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.control.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _LdFormInputField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.state.control.value?.toString() ?? '';
    if (_controller.text != text) {
      _suppressChange = true;
      _controller.text = text;
      _suppressChange = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.state.control;
    return LdInput(
      hint: widget.hint,
      label: widget.label,
      keyboardType: TextInputType.text,
      maxLines: widget.maxLines,
      size: widget.size,
      valid: control.valid || widget.state.errorText == null,
      controller: _controller,
      onChanged: (value) {
        if (_suppressChange) return;
        // Only propagate if the value actually changed to avoid marking the
        // control dirty on spurious controller notifications.
        final modelValue = widget.state.control.value?.toString() ?? '';
        if (value != modelValue) {
          widget.state.didChange(value);
        }
      },
      onSubmitted: (value) {
        widget.onCommitted?.call(value);
      },
      onBlurred: (value) {
        if (control.dirty) control.markAsTouched();
        widget.onBlurred?.call(value);
      },
      disabled: widget.disabled ?? control.disabled,
    );
  }
}
