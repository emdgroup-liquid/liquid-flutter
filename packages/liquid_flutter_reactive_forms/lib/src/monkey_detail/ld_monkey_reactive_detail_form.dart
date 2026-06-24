import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../reactive_form.dart';
import '../reactive_form_item.dart';
import '../reactive_form_scope.dart';
import '../typedefs.dart';
import '../validation_messages.dart';
import 'ld_monkey_detail_form_field_hooks.dart';
import 'ld_monkey_detail_form_merge.dart';
import 'ld_monkey_detail_form_scope.dart';
import 'ld_monkey_detail_save_mode.dart';
import 'ld_monkey_field_conflict.dart';

typedef LdMonkeyDetailFormValues<TDetail> = Map<String, Object?> Function(TDetail detail);

typedef LdMonkeyDetailMapToEntity<T, TDetail> = T Function(LdFormGroup form, TDetail detail);

typedef LdMonkeyDetailLoadDetail<TDetail, IdType> = Future<TDetail> Function(
  BuildContext context,
  IdType id,
);

typedef LdMonkeyDetailFromEntity<T, TDetail> = TDetail Function(T entity);

/// Reactive detail editor for monkey master-detail pages.
///
/// Wires [LdRepository.update], adaptive blur/manual save, repository stream
/// merge, and [LdMonkeyUnsavedGuard] / [LdMonkeyViewingGuard].
class LdMonkeyReactiveDetailForm<T extends Identifiable<IdType>, IdType, TDetail extends Object>
    extends StatefulWidget {
  final LdPaginatorItem<T> item;
  final LdMonkeyDetailFormItemsBuilder itemsBuilder;
  final LdMonkeyDetailFormValues<TDetail> detailToFormValues;
  final LdMonkeyDetailMapToEntity<T, TDetail> mapToEntity;
  final LdMonkeyDetailLoadDetail<TDetail, IdType>? loadDetail;
  final LdMonkeyDetailFromEntity<T, TDetail>? detailFromEntity;
  final LdMonkeyDetailSaveMode saveMode;
  final LdMonkeyFieldConflictPolicy conflictPolicy;
  final LdMonkeyFieldConflictResolver? onFieldConflict;
  final List<LdFormValidator<dynamic>> validators;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final LdFormSubmitConfig? submitConfig;

  const LdMonkeyReactiveDetailForm({
    super.key,
    required this.item,
    required this.itemsBuilder,
    required this.detailToFormValues,
    required this.mapToEntity,
    this.loadDetail,
    this.detailFromEntity,
    this.saveMode = LdMonkeyDetailSaveMode.adaptive,
    this.conflictPolicy = LdMonkeyFieldConflictPolicy.keepLocal,
    this.onFieldConflict,
    this.validators = const [],
    this.validationMessages,
    this.submitConfig,
  });

  @override
  State<LdMonkeyReactiveDetailForm<T, IdType, TDetail>> createState() =>
      _LdMonkeyReactiveDetailFormState<T, IdType, TDetail>();
}

class _LdMonkeyReactiveDetailFormState<T extends Identifiable<IdType>, IdType, TDetail extends Object>
    extends State<LdMonkeyReactiveDetailForm<T, IdType, TDetail>> {
  late final FormGroup _form;
  late final LdSubmitController<void, void> _saveController;
  late final List<LdReactiveFormItem<dynamic, dynamic>> _formItems;

  TDetail? _detail;
  IdType? _currentId;
  final Map<String, Object?> _lastServerFormValues = {};
  StreamSubscription<LdPaginatorItem<T>>? _itemSubscription;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _formItems = widget.itemsBuilder(
      context,
      LdMonkeyDetailFormFieldHooks(onSave: _blurSaveEnabled ? _triggerSave : null),
    );
    _form = FormGroup(
      {for (final item in _formItems) item.key: item.createFormControl()},
      validators: widget.validators,
    );
    _saveController = LdSubmitController<void, void>(
      config: (widget.submitConfig ?? LdFormSubmitConfig()).copyWithAction((_) => _performSave()),
    );
    _bootstrapDetail();
  }

  @override
  void didUpdateWidget(covariant LdMonkeyReactiveDetailForm<T, IdType, TDetail> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newId = widget.item.value?.id;
    if (newId != null && newId != _currentId) {
      _bootstrapDetail();
    }
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _form.dispose();
    _saveController.dispose();
    super.dispose();
  }

  bool get _blurSaveEnabled {
    return switch (widget.saveMode) {
      LdMonkeyDetailSaveMode.onBlur => true,
      LdMonkeyDetailSaveMode.manualSubmit => false,
      LdMonkeyDetailSaveMode.adaptive => LdTheme.of(context).platform.isMobile,
    };
  }

  bool get _showSubmitButton => !_blurSaveEnabled;

  bool get _isSaving => _saveController.state.type == LdSubmitStateType.loading;

  Future<void> _bootstrapDetail() async {
    final id = widget.item.value?.id;
    if (id == null) {
      return;
    }

    _currentId = id;
    await _itemSubscription?.cancel();
    _itemSubscription = LdRepository.of<T, IdType>(context).watchItem(id).listen(_onItemUpdated);

    setState(() => _loadingDetail = true);
    try {
      final detail = widget.loadDetail != null
          ? await widget.loadDetail!(context, id)
          : widget.item.value! as TDetail;
      if (!mounted || id != _currentId) {
        return;
      }
      _detail = detail;
      _patchFormFromDetail(markPristine: true);
    } finally {
      if (mounted) {
        setState(() => _loadingDetail = false);
      }
    }
  }

  void _onItemUpdated(LdPaginatorItem<T> update) {
    final entity = update.value;
    if (entity == null || entity.id != _currentId) {
      return;
    }

    final detail = widget.detailFromEntity?.call(entity) ?? entity as TDetail;
    _detail = detail;
    unawaited(_mergeFromServer(detail));
  }

  void _patchFormFromDetail({required bool markPristine}) {
    final detail = _detail;
    if (detail == null) {
      return;
    }

    final values = widget.detailToFormValues(detail);
    for (final entry in values.entries) {
      if (!_form.contains(entry.key)) {
        continue;
      }
      _form.control(entry.key).value = entry.value;
      if (markPristine) {
        _form.control(entry.key).markAsPristine();
      }
      _lastServerFormValues[entry.key] = entry.value;
    }
    if (markPristine) {
      _form.markAsPristine();
    }
    setState(() {});
  }

  Future<void> _mergeFromServer(TDetail detail) async {
    final serverValues = widget.detailToFormValues(detail);
    await ldMonkeyMergeFormFromServer(
      form: _form,
      serverValues: serverValues,
      lastServerValues: _lastServerFormValues,
      conflictPolicy: widget.conflictPolicy,
      onFieldConflict: widget.onFieldConflict,
      promptConflict: _promptFieldConflict,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<LdMonkeyFieldConflictResolution> _promptFieldConflict(
    String fieldKey,
    Object? localValue,
    Object? serverValue,
  ) async {
    final useServer = await ldMonkeyConfirmDiscardEdits(
      context,
      title: const Text('Field changed elsewhere'),
      description: 'Keep your edit for "$fieldKey" or use the server value?',
      discardLabel: const Text('Use server'),
      keepEditingLabel: const Text('Keep mine'),
    );
    return useServer
        ? LdMonkeyFieldConflictResolution.preferServer
        : LdMonkeyFieldConflictResolution.keepLocal;
  }

  Future<void> _triggerSave() async {
    if (!_form.dirty || _form.invalid || _isSaving) {
      return;
    }
    await _saveController.trigger();
  }

  Future<void> _performSave() async {
    if (_detail == null) {
      return;
    }
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }

    final entity = widget.mapToEntity(_form, _detail!);
    await LdRepository.of<T, IdType>(context).update(context, entity.id, entity);
    _form.markAsPristine();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await ldMonkeyConfirmDiscardEdits(context);
    if (discard) {
      reset();
    }
    return discard;
  }

  void reset() {
    _patchFormFromDetail(markPristine: true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.value == null || _loadingDetail) {
      return const Center(child: LdLoader());
    }

    return LdMonkeyUnsavedGuard(
      isDirty: _form.dirty,
      isSaving: _isSaving,
      onConfirmDiscard: _confirmDiscard,
      child: LdMonkeyViewingGuard<T, IdType>(
        isDirty: _form.dirty,
        isSaving: _isSaving,
        onConfirmDiscard: _confirmDiscard,
        child: LdMonkeyDetailFormScope<TDetail>(
          isDirty: _form.dirty,
          isSaving: _isSaving,
          detail: _detail,
          save: _saveController.trigger,
          reset: reset,
          child: ReactiveFormConfig(
            validationMessages: ldMergeReactiveFormValidationMessages(widget.validationMessages),
            child: LdReactiveFormScope(
              formGroup: _form,
              child: ReactiveForm(
                formGroup: _form,
                child: LdAutoSpace(
                  children: [
                    ..._formItems.map((item) => item.createFormField()),
                    if (_showSubmitButton) _buildSubmitButton(),
                    ListenableBuilder(
                      listenable: _saveController,
                      builder: (context, _) {
                        if (_saveController.state.type != LdSubmitStateType.error) {
                          return const SizedBox.shrink();
                        }
                        return LdExceptionView(
                          exception: _saveController.state.error!.localize(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        return LdReveal(
          revealed: form.dirty && form.valid,
          child: LdSubmit<void, void>(
            controller: _saveController,
            child: LdButton.filled(
              disabled: _isSaving || !form.valid,
              child: Text((widget.submitConfig ?? LdFormSubmitConfig()).submitText ?? 'Save'),
              onPressed: () async {
                await _saveController.trigger();
              },
            ),
          ),
        );
      },
    );
  }
}
