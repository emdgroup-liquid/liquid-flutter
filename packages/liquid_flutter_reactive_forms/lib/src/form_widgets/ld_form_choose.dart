import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/form_widgets/ld_form_field_base.dart';

/// A reactive choose field backed by a static list of [LdSelectItem]s.
///
/// Binds to a [FormControl<Set<T>>] by [formKey]. Use [multiple] for
/// multi-select behaviour.
class LdFormChoose<T> extends StatelessWidget {
  final String formKey;
  final String? label;
  final List<LdSelectItem<T>> items;
  final bool multiple;
  final bool allowEmpty;
  final bool? disabled;
  final LdChooseMode mode;
  final Text? placeholder;
  final void Function(Set<T> value)? onCommitted;
  final LdHint? Function(ReactiveFormFieldState<Set<T>, Set<T>>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormChoose({
    super.key,
    required this.formKey,
    required this.items,
    this.label,
    this.multiple = false,
    this.allowEmpty = false,
    this.disabled,
    this.mode = LdChooseMode.auto,
    this.placeholder,
    this.onCommitted,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<Set<T>, Set<T>>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdChoose.fromSelectItems<T>(
          label: label,
          items: items,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          placeholder: placeholder ?? const Text('Select...'),
          value: state.control.value,
          disabled: disabled ?? state.control.disabled,
          onChanged: (value) {
            state.didChange(value);
            onCommitted?.call(value);
          },
        ),
      ),
    );
  }
}

/// A reactive choose field backed by a list of [Identifiable] entities.
class LdFormChooseFromList<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final String formKey;
  final String? label;
  final List<T> items;
  final Widget Function(BuildContext context, T item) selectedItemBuilder;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index)? itemBuilder;
  final bool multiple;
  final bool allowEmpty;
  final bool? disabled;
  final LdChooseMode mode;
  final LdSearchTextExtractor<T>? searchText;
  final LdHint? Function(
    ReactiveFormFieldState<Set<IdType>, Set<IdType>>,
  )? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormChooseFromList({
    super.key,
    required this.formKey,
    required this.items,
    required this.selectedItemBuilder,
    this.itemBuilder,
    this.label,
    this.multiple = false,
    this.allowEmpty = false,
    this.disabled,
    this.mode = LdChooseMode.auto,
    this.searchText,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<Set<IdType>, Set<IdType>>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdChoose.fromList<T, IdType>(
          label: label,
          items: items,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          searchText: searchText,
          value: state.control.value,
          disabled: disabled ?? state.control.disabled,
          onChanged: state.didChange,
          itemBuilder: itemBuilder ??
              (context, item, index) => LdListItem(
                    title: Text(item.value?.toString() ?? ''),
                  ),
          selectedItemBuilder: selectedItemBuilder,
        ),
      ),
    );
  }
}

/// A reactive choose field backed by a monkey [LdListController].
class LdFormChooseRepository<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final String formKey;
  final String? label;
  final LdListController<T, IdType> repository;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Widget Function(BuildContext context, T item) selectedItemBuilder;
  final bool multiple;
  final bool allowEmpty;
  final bool? disabled;
  final LdChooseMode mode;
  final LdMonkeyFiltersBuilder<T, IdType>? filtersBuilder;
  final LdMonkeySortOptionsBuilder<T, IdType>? sortOptionsBuilder;
  final List<LdFilterChipConfig<T, IdType>>? filterChipConfigs;
  final LdHint? Function(
    ReactiveFormFieldState<Set<IdType>, Set<IdType>>,
  )? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormChooseRepository({
    super.key,
    required this.formKey,
    required this.repository,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.label,
    this.multiple = false,
    this.allowEmpty = false,
    this.disabled,
    this.mode = LdChooseMode.auto,
    this.filtersBuilder,
    this.sortOptionsBuilder,
    this.filterChipConfigs,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<Set<IdType>, Set<IdType>>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: LdChoose<T, IdType>(
          repository: repository,
          label: label,
          multiple: multiple,
          allowEmpty: allowEmpty,
          mode: mode,
          filtersBuilder: filtersBuilder,
          sortOptionsBuilder: sortOptionsBuilder,
          filterChipConfigs: filterChipConfigs,
          value: state.control.value,
          disabled: disabled ?? state.control.disabled,
          onChanged: state.didChange,
          itemBuilder: itemBuilder,
          selectedItemBuilder: selectedItemBuilder,
        ),
      ),
    );
  }
}
