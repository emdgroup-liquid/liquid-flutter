import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../liquid_flutter_reactive_forms.dart';

/// A [LdReactiveFormItem] is basically an elaborated wrapper around
/// [FormControl] and [ReactiveFormField]. It contains all the necessary
/// information to create a form field widget and manage its state.
///
/// It offers convenience constructors for common form field types like input,
/// select, checkbox, date picker, and slider. It also allows you to create
/// custom form fields by providing a [LdFormFieldBuilder].
@immutable
class LdReactiveFormItem<TModel, TView> {
  /// The key of the form field.
  final String key;

  /// The builder function that creates the form field widget.
  final LdFormFieldBuilder<TModel, TView> formFieldBuilder;

  /// An optional hint that will be displayed below the form field (if no error
  /// is present.)
  final LdHint? Function(LdReactiveFormFieldState<TModel, TView>)? hintBuilder;
  final ControlValueAccessor<TModel, TView>? _valueAccessor;
  ControlValueAccessor<TModel, TView> get valueAccessor =>
      _valueAccessor ?? DefaultValueAccessor<TModel, TView>() as ControlValueAccessor<TModel, TView>;
  final bool disabled;
  final List<LdFormValidator<dynamic>> validators;
  final TModel? initialValue;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdReactiveFormItem({
    required this.key,
    required this.formFieldBuilder,
    this.hintBuilder,
    this.disabled = false,
    this.validators = const [],
    this.initialValue,
    this.validationMessages,
    ControlValueAccessor<TModel, TView>? valueAccessor,
  }) : _valueAccessor = valueAccessor;

  /// Input Field Constructor
  static LdReactiveFormItem<T, String> input<T>({
    required String key,
    required String inputFieldHint,
    LdHint? Function(LdReactiveFormFieldState<T, String>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    String? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(String value)? onBlurred,
    int? maxLines = 1,
    LdSize size = LdSize.m,
  }) {
    final valueAccessor = switch (T) {
      const (int) => IntValueAccessor() as ControlValueAccessor<T, String>,
      const (double) => DoubleValueAccessor() as ControlValueAccessor<T, String>,
      const (DateTime) => DateTimeValueAccessor() as ControlValueAccessor<T, String>,
      const (TimeOfDay) => TimeOfDayValueAccessor() as ControlValueAccessor<T, String>,
      _ => DefaultValueAccessor<T, String>() as ControlValueAccessor<T, String>,
    };
    return LdReactiveFormItem<T, String>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      validationMessages: validationMessages,
      initialValue: valueAccessor.viewToModelValue(
        initialValue ?? switch (T) {
          const (String) => '',
          _ => null,
        },
      ),
      valueAccessor: valueAccessor,
      formFieldBuilder: (state) {
        return _ReactiveLdInput<T>(
          state: state,
          inputFieldHint: inputFieldHint,
          label: label,
          onBlurred: onBlurred,
          maxLines: maxLines,
          size: size,
        );
      },
    );
  }

  /// Select Field Constructor
  static LdReactiveFormItem<T, T> select<T>({
    required String key,
    required List<LdSelectItem<T>> items,
    LdHint? Function(LdReactiveFormFieldState<T, T>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    T? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
  }) {
    return LdReactiveFormItem<T, T>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdSelect<T>(
          label: label,
          items: items,
          value: state.control.value,
          disabled: state.control.disabled,
          onChanged: (value) => state.didChange(value),
        );
      },
    );
  }

  /// Choose field backed by [LdChoose.fromSelectItems].
  static LdReactiveFormItem<Set<T>, Set<T>> chooseFromItems<T>({
    required String key,
    required List<LdSelectItem<T>> items,
    LdHint? Function(LdReactiveFormFieldState<Set<T>, Set<T>>)? hintBuilder,
    String? label,
    bool disabled = false,
    bool multiple = false,
    bool allowEmpty = false,
    List<LdFormValidator<dynamic>> validators = const [],
    Set<T>? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
    LdChooseMode mode = LdChooseMode.auto,
    Text? placeholder,
    void Function(Set<T> value)? onCommitted,
  }) {
    return LdReactiveFormItem<Set<T>, Set<T>>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdChoose.fromSelectItems<T>(
          label: label,
          items: items,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          placeholder: placeholder ?? const Text('Select...'),
          value: state.control.value,
          disabled: state.control.disabled,
          onChanged: (value) {
            state.didChange(value);
            onCommitted?.call(value);
          },
        );
      },
    );
  }

  /// Multi Select Field Constructor
  ///
  /// Prefer [chooseFromItems] with `multiple: true`.
  static LdReactiveFormItem<Set<T>, Set<T>> multiSelect<T>({
    required String key,
    required List<LdSelectItem<T>> items,
    LdHint? Function(LdReactiveFormFieldState<Set<T>, Set<T>>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    Set<T>? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
  }) {
    return chooseFromItems<T>(
      key: key,
      items: items,
      hintBuilder: hintBuilder,
      label: label,
      disabled: disabled,
      multiple: true,
      allowEmpty: true,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
    );
  }

  /// Choose field backed by [LdChoose.fromList] for identifiable entities.
  static LdReactiveFormItem<Set<IdType>, Set<IdType>> chooseFromList<T extends Identifiable<IdType>, IdType>({
    required String key,
    required List<T> items,
    required Widget Function(BuildContext context, T item) selectedItemBuilder,
    Widget Function(BuildContext context, LdPaginatorItem<T> item, int index)? itemBuilder,
    LdHint? Function(LdReactiveFormFieldState<Set<IdType>, Set<IdType>>)? hintBuilder,
    String? label,
    bool disabled = false,
    bool multiple = false,
    bool allowEmpty = false,
    List<LdFormValidator<dynamic>> validators = const [],
    Set<IdType>? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
    LdChooseMode mode = LdChooseMode.auto,
    LdSearchTextExtractor<T>? searchText,
  }) {
    return LdReactiveFormItem<Set<IdType>, Set<IdType>>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdChoose.fromList<T, IdType>(
          label: label,
          items: items,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          searchText: searchText,
          value: state.control.value,
          disabled: state.control.disabled,
          onChanged: state.didChange,
          itemBuilder: itemBuilder ??
              (context, item, index) {
                return LdListItem(
                  title: Text(item.value?.toString() ?? ''),
                );
              },
          selectedItemBuilder: selectedItemBuilder,
        );
      },
    );
  }

  /// Choose field backed by a monkey [LdRepository].
  static LdReactiveFormItem<Set<IdType>, Set<IdType>> chooseRepository<T extends Identifiable<IdType>, IdType>({
    required String key,
    required LdRepository<T, IdType> repository,
    required Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder,
    required Widget Function(BuildContext context, T item) selectedItemBuilder,
    LdHint? Function(LdReactiveFormFieldState<Set<IdType>, Set<IdType>>)? hintBuilder,
    String? label,
    bool disabled = false,
    bool multiple = false,
    bool allowEmpty = false,
    List<LdFormValidator<dynamic>> validators = const [],
    Set<IdType>? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
    LdChooseMode mode = LdChooseMode.auto,
    LdMonkeyFiltersBuilder<T, IdType>? filtersBuilder,
    LdMonkeySortOptionsBuilder<T, IdType>? sortOptionsBuilder,
    List<LdFilterChipConfig<T, IdType>>? filterChipConfigs,
  }) {
    return LdReactiveFormItem<Set<IdType>, Set<IdType>>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdChoose<T, IdType>(
          repository: repository,
          label: label,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          filtersBuilder: filtersBuilder,
          sortOptionsBuilder: sortOptionsBuilder,
          filterChipConfigs: filterChipConfigs,
          value: state.control.value,
          disabled: state.control.disabled,
          onChanged: state.didChange,
          itemBuilder: itemBuilder,
          selectedItemBuilder: selectedItemBuilder,
        );
      },
    );
  }

  /// Checkbox Field Constructor
  static LdReactiveFormItem<bool, bool> checkbox({
    required String key,
    LdHint? Function(LdReactiveFormFieldState<bool, bool>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    bool initialValue = false,
    Map<String, ValidationMessageFunction>? validationMessages,
  }) {
    return LdReactiveFormItem<bool, bool>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdCheckbox(
          label: label,
          color: state.control.valid || state.control.pristine ? null : shadRed,
          checked: state.control.value ?? false,
          onChanged: (value) => state.didChange(value),
          disabled: state.control.disabled,
        );
      },
    );
  }

  /// Date Picker Field Constructor
  static LdReactiveFormItem<DateTime, DateTime> datePicker({
    required String key,
    LdHint? Function(LdReactiveFormFieldState<DateTime, DateTime>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    DateTime? initialValue,
    Map<String, ValidationMessageFunction>? validationMessages,
    bool useRootNavigator = false,
    void Function(DateTime value)? onCommitted,
  }) {
    return LdReactiveFormItem<DateTime, DateTime>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return LdDatePicker(
          label: label,
          value: state.control.value,
          useRootNavigator: useRootNavigator,
          onChanged: (value) {
            state.didChange(value);
            onCommitted?.call(value);
          },
        );
      },
    );
  }

  /// Slider Field Constructor
  static LdReactiveFormItem<double, double> slider({
    required String key,
    LdHint? Function(LdReactiveFormFieldState<double, double>)? hintBuilder,
    String? label,
    bool disabled = false,
    List<LdFormValidator<dynamic>> validators = const [],
    double? initialValue,
    double min = 0,
    double max = 100,
    Map<String, ValidationMessageFunction>? validationMessages,
    String Function(double? value)? valueFormatter,
    void Function(double value)? onCommitted,
  }) {
    final defaultPrecision = max - min < 1 ? 2 : 0;
    valueFormatter ??= (value) => value?.toStringAsFixed(defaultPrecision) ?? '';
    return LdReactiveFormItem<double, double>(
      key: key,
      hintBuilder: hintBuilder,
      disabled: disabled,
      validators: validators,
      initialValue: initialValue,
      validationMessages: validationMessages,
      formFieldBuilder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (label != null) LdText.l(label, textAlign: TextAlign.start),
                const Spacer(),
                LdText.ls(valueFormatter!(state.control.value)),
              ],
            ),
            Slider(
              value: (state.control.value ?? min).clamp(min, max),
              onChanged: (value) => state.didChange(value),
              onChangeEnd: onCommitted,
              min: min,
              max: max,
            ),
          ],
        );
      },
    );
  }

  /// Creates the [FormControl] model for the form item.
  FormControl<TModel> createFormControl() {
    return FormControl<TModel>(
      disabled: disabled,
      validators: validators,
      value: initialValue,
    );
  }

  /// Creates the [ReactiveFormField] widget for the form item.
  ReactiveFormField<TModel, TView> createFormField() {
    return ReactiveFormField<TModel, TView>(
      formControlName: key,
      valueAccessor: valueAccessor,
      validationMessages: validationMessages,
      showErrors: ldReactiveFormShowErrors,
      builder: (state) {
        return LdAutoSpace(
          children: [
            formFieldBuilder(state),
            if (state.errorText != null)
              LdHint(type: LdHintType.error, child: Text(state.errorText!))
            else if (hintBuilder != null)
              hintBuilder!.call(state) ?? const SizedBox.shrink(),
            const LdSpacer(size: LdSize.l),
          ],
        );
      },
    );
  }
}

class _ReactiveLdInput<T> extends StatefulWidget {
  final LdReactiveFormFieldState<T, String> state;
  final String inputFieldHint;
  final String? label;
  final void Function(String value)? onBlurred;
  final int? maxLines;
  final LdSize size;

  const _ReactiveLdInput({
    required this.state,
    required this.inputFieldHint,
    required this.label,
    this.onBlurred,
    this.maxLines = 1,
    this.size = LdSize.m,
  });

  @override
  State<_ReactiveLdInput<T>> createState() => _ReactiveLdInputState<T>();
}

class _ReactiveLdInputState<T> extends State<_ReactiveLdInput<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.control.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ReactiveLdInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.state.control.value?.toString() ?? '';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdInput(
      hint: widget.inputFieldHint,
      label: widget.label,
      keyboardType: TextInputType.text,
      maxLines: widget.maxLines,
      size: widget.size,
      valid: widget.state.control.valid || widget.state.errorText == null,
      controller: _controller,
      onChanged: widget.state.didChange,
      onBlurred: (value) {
        if (widget.state.control.dirty) {
          widget.state.control.markAsTouched();
        }
        widget.onBlurred?.call(value);
      },
      disabled: widget.state.control.disabled,
    );
  }
}
