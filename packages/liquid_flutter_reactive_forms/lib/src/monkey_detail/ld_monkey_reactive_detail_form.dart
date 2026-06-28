import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_detail_form_field_hooks.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_detail_form_merge.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_detail_form_scope.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_detail_pre_save_check.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_detail_save_mode.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_field_conflict.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_reactive_detail_form_mode.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_version_conflict_exception.dart';
import 'package:liquid_flutter_reactive_forms/src/reactive_form.dart';
import 'package:liquid_flutter_reactive_forms/src/reactive_form_item.dart';
import 'package:liquid_flutter_reactive_forms/src/reactive_form_scope.dart';
import 'package:liquid_flutter_reactive_forms/src/reactive_form_submit_inline.dart';
import 'package:liquid_flutter_reactive_forms/src/typedefs.dart';
import 'package:liquid_flutter_reactive_forms/src/validation_messages.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef LdMonkeyDetailFormValues<TDetail> = Map<String, Object?> Function(TDetail detail);

typedef LdMonkeyDetailFormToUpdatePayload<TUpdate, TDetail> = TUpdate Function(
  LdFormGroup form,
  TDetail detail,
);

typedef LdMonkeyDetailFormToCreatePayload<TCreate, TDetail> = TCreate Function(
  LdFormGroup form,
  TDetail detail,
);

typedef LdMonkeyDetailLoadDetail<TDetail, IdType> = Future<TDetail> Function(
  BuildContext context,
  IdType id,
);

typedef LdMonkeyDetailFromEntity<T, TDetail> = TDetail Function(T entity);

typedef LdMonkeyDetailOnCreated<T extends Identifiable<IdType>, IdType> = void Function(
  BuildContext context,
  T created,
);

/// Reactive detail editor for monkey master-detail pages.
class LdMonkeyReactiveDetailForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>
    extends StatefulWidget {
  final LdMonkeyReactiveDetailFormMode mode;
  final LdPaginatorItem<T>? item;
  final TDetail? initialDetail;
  final LdMonkeyDetailFormItemsBuilder itemsBuilder;
  final LdMonkeyDetailFormValues<TDetail> detailToFormValues;
  final LdMonkeyDetailFormToUpdatePayload<TUpdate, TDetail>? formToUpdatePayload;
  final LdMonkeyDetailFormToCreatePayload<TCreate, TDetail>? formToCreatePayload;
  final LdMonkeyDetailLoadDetail<TDetail, IdType>? loadDetail;
  final LdMonkeyDetailFromEntity<T, TDetail>? detailFromEntity;
  final LdMonkeyDetailSaveMode saveMode;
  final LdMonkeyFieldConflictPolicy conflictPolicy;
  final LdMonkeyFieldConflictResolver? onFieldConflict;
  final LdMonkeyDetailPreSaveCheck preSaveCheck;
  final LdMonkeyDetailOnCreated<T, IdType>? onCreated;
  final List<LdFormValidator<dynamic>> validators;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final LdFormSubmitConfig? submitConfig;

  const LdMonkeyReactiveDetailForm.edit({
    super.key,
    required this.item,
    required this.itemsBuilder,
    required this.detailToFormValues,
    required this.formToUpdatePayload,
    this.loadDetail,
    this.detailFromEntity,
    this.saveMode = LdMonkeyDetailSaveMode.adaptive,
    this.conflictPolicy = LdMonkeyFieldConflictPolicy.keepLocal,
    this.onFieldConflict,
    this.preSaveCheck = LdMonkeyDetailPreSaveCheck.none,
    this.validators = const [],
    this.validationMessages,
    this.submitConfig,
  })  : mode = LdMonkeyReactiveDetailFormMode.edit,
        initialDetail = null,
        formToCreatePayload = null,
        onCreated = null;

  const LdMonkeyReactiveDetailForm.create({
    super.key,
    required this.initialDetail,
    required this.itemsBuilder,
    required this.detailToFormValues,
    required this.formToCreatePayload,
    this.onCreated,
    this.conflictPolicy = LdMonkeyFieldConflictPolicy.keepLocal,
    this.onFieldConflict,
    this.validators = const [],
    this.validationMessages,
    this.submitConfig,
  })  : mode = LdMonkeyReactiveDetailFormMode.create,
        item = null,
        formToUpdatePayload = null,
        loadDetail = null,
        detailFromEntity = null,
        saveMode = LdMonkeyDetailSaveMode.manualSubmit,
        preSaveCheck = LdMonkeyDetailPreSaveCheck.none;

  @override
  State<LdMonkeyReactiveDetailForm<T, IdType, TDetail, TCreate, TUpdate>> createState() =>
      _LdMonkeyReactiveDetailFormState<T, IdType, TDetail, TCreate, TUpdate>();
}

class _LdMonkeyReactiveDetailFormState<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>
    extends State<LdMonkeyReactiveDetailForm<T, IdType, TDetail, TCreate, TUpdate>> {
  late final FormGroup _form;
  late final LdSubmitController<void, void> _saveController;
  late final List<LdReactiveFormItem<dynamic, dynamic>> _formItems;
  late final Map<String, String?> _fieldLabels = {
    for (final item in _formItems) item.key: item.label,
  };

  TDetail? _detail;
  IdType? _currentId;
  final Map<String, Object?> _lastServerFormValues = {};
  TDetail? _pendingMergeDetail;
  bool _mergeInProgress = false;
  StreamSubscription<LdPaginatorItem<T>>? _itemSubscription;
  StreamSubscription<dynamic>? _formSubscription;
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
    _saveController.addListener(_onEditStateChanged);
    _formSubscription = _form.valueChanges.listen((_) => _onEditStateChanged());
    _bootstrapDetail();
  }

  bool get _editsAtRisk => _form.dirty || _isSaving;

  void _onEditStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<bool> _onLeaveLockedLocation(BuildContext _) async {
    if (_isSaving) {
      return false;
    }
    return ldMonkeyConfirmDiscardEdits(context);
  }

  Future<void> _confirmDiscardAndPop(Object? result) async {
    if (_isSaving) {
      return;
    }
    final navigator = Navigator.of(context);
    final shouldKeepEditing = await ldMonkeyConfirmDiscardEdits(context);
    if (shouldKeepEditing || !mounted) {
      return;
    }
    _form.markAsPristine();
    navigator.pop(result);
  }

  @override
  void didUpdateWidget(covariant LdMonkeyReactiveDetailForm<T, IdType, TDetail, TCreate, TUpdate> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != LdMonkeyReactiveDetailFormMode.edit) {
      return;
    }
    final newId = widget.item?.value?.id;
    if (newId != null && newId != _currentId) {
      _bootstrapDetail();
    }
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _formSubscription?.cancel();
    _form.dispose();
    _saveController.dispose();
    super.dispose();
  }

  bool get _blurSaveEnabled {
    if (widget.mode == LdMonkeyReactiveDetailFormMode.create) {
      return false;
    }
    return switch (widget.saveMode) {
      LdMonkeyDetailSaveMode.onBlur => true,
      LdMonkeyDetailSaveMode.manualSubmit => false,
      LdMonkeyDetailSaveMode.adaptive => LdTheme.of(context).platform.isMobile,
    };
  }

  bool get _showSubmitButton => !_blurSaveEnabled;

  bool get _isSaving => _saveController.state.type == LdSubmitStateType.loading;

  Future<void> _bootstrapDetail() async {
    if (widget.mode == LdMonkeyReactiveDetailFormMode.create) {
      _detail = widget.initialDetail;
      _patchFormFromDetail(markPristine: true);
      return;
    }

    final id = widget.item?.value?.id;
    if (id == null) {
      return;
    }

    _currentId = id;
    _loadingDetail = true;
    final listController = LdListController.of<T, IdType>(context);
    await _itemSubscription?.cancel();
    if (!mounted) return;
    _itemSubscription = listController.watchItem(id).listen(_onItemUpdated);

    try {
      final detail = widget.loadDetail != null ? await widget.loadDetail!(context, id) : widget.item!.value! as TDetail;
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
    unawaited(_enqueueMerge(detail));
  }

  Future<void> _enqueueMerge(TDetail detail) async {
    _pendingMergeDetail = detail;
    if (_mergeInProgress) {
      return;
    }
    _mergeInProgress = true;
    try {
      while (_pendingMergeDetail != null && mounted) {
        final next = _pendingMergeDetail as TDetail;
        _pendingMergeDetail = null;
        await _mergeFromServer(next);
      }
    } finally {
      _mergeInProgress = false;
    }
  }

  void _patchFormFromDetail({required bool markPristine}) {
    final detail = _detail;
    if (detail == null || !mounted) {
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
      fieldLabels: _fieldLabels,
      onFieldConflict: widget.onFieldConflict,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _applyVersionConflict(LdMonkeyVersionConflictException<TDetail> exception) async {
    final serverValues = exception.serverFieldValues ??
        (exception.serverDetail != null ? widget.detailToFormValues(exception.serverDetail as TDetail) : null);
    if (serverValues == null) {
      return;
    }
    await ldMonkeyMergeFormFromServer(
      form: _form,
      serverValues: serverValues,
      lastServerValues: _lastServerFormValues,
      conflictPolicy: widget.conflictPolicy,
      fieldLabels: _fieldLabels,
      onFieldConflict: widget.onFieldConflict,
    );
  }

  Future<void> _runPreSaveCheck() async {
    if (widget.mode != LdMonkeyReactiveDetailFormMode.edit ||
        widget.preSaveCheck != LdMonkeyDetailPreSaveCheck.repositoryGetById) {
      return;
    }
    final id = _currentId;
    if (id == null) {
      return;
    }
    final serverEntity = await LdListController.of<T, IdType>(context).getById(context, id, skipCache: true);
    if (!mounted) {
      return;
    }
    final detail = widget.detailFromEntity?.call(serverEntity) ?? serverEntity as TDetail;
    final serverValues = widget.detailToFormValues(detail);
    final hasConflict = serverValues.entries.any((entry) {
      if (!_form.contains(entry.key)) {
        return false;
      }
      final control = _form.control(entry.key);
      final previous = _lastServerFormValues[entry.key];
      return control.dirty && entry.value != previous;
    });
    if (hasConflict) {
      final exception = LdMonkeyVersionConflictException<TDetail>.fields(serverValues);
      await _applyVersionConflict(exception);
      throw exception;
    }
  }

  Future<void> _triggerSave() async {
    if (_form.invalid || _isSaving) {
      return;
    }
    if (widget.mode == LdMonkeyReactiveDetailFormMode.edit && !_form.dirty) {
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

    try {
      final model = context.read<LdModel<T, IdType, Object?, Object?>>();
      await _runPreSaveCheck();
      if (!mounted) return;

      if (widget.mode == LdMonkeyReactiveDetailFormMode.create) {
        final payload = widget.formToCreatePayload!(_form, _detail!);
        // ignore: use_build_context_synchronously
        final created = await model.create(context, payload);
        _form.markAsPristine();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onCreated?.call(context, created);
        });
        return;
      }

      final payload = widget.formToUpdatePayload!(_form, _detail!);
      final entityId = widget.item!.value!.id;
      // ignore: use_build_context_synchronously
      await model.update(context, entityId, payload);
      _form.markAsPristine();
    } on LdMonkeyVersionConflictException<TDetail> catch (exception) {
      await _applyVersionConflict(exception);
      rethrow;
    }
  }

  void reset() {
    _patchFormFromDetail(markPristine: true);
  }

  void _resolveConflict(LdMonkeyFieldConflict conflict, LdMonkeyFieldConflictResolution resolution) {
    ldMonkeyResolveFieldConflict(
      form: _form,
      conflict: conflict,
      resolution: resolution,
      lastServerValues: _lastServerFormValues,
    );
    setState(() {});
  }

  Widget _buildFormField(LdReactiveFormItem<dynamic, dynamic> item) {
    return (item as dynamic).buildMonkeyDetailField(
      onResolveConflict: _resolveConflict,
    ) as Widget;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDetail || _detail == null) {
      return const Center(child: LdLoader());
    }
    if (widget.mode == LdMonkeyReactiveDetailFormMode.edit && widget.item?.value == null) {
      return const Center(child: LdLoader());
    }

    return LdLocationLockGuard(
      locked: _editsAtRisk,
      pathPrefix: GoRouter.of(context).state.uri.path,
      onLeave: _onLeaveLockedLocation,
      onBlockedPop: _confirmDiscardAndPop,
      child: LdMonkeyDetailFormScope<TDetail>(
        mode: widget.mode,
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
                  ..._formItems.map(_buildFormField),
                  if (_showSubmitButton) ...[
                    LdDivider(),
                    LdReactiveFormSubmitInline(
                      mode: widget.mode,
                      saveController: _saveController,
                      form: _form,
                      isSaving: _isSaving,
                      submitText: (widget.submitConfig ?? LdFormSubmitConfig()).submitText,
                    ),
                  ],
                  ListenableBuilder(
                    listenable: _saveController,
                    builder: (context, _) {
                      final error = _saveController.state.error;
                      if (_saveController.state.type != LdSubmitStateType.error ||
                          error is LdMonkeyVersionConflictException) {
                        return const SizedBox.shrink();
                      }
                      return LdExceptionView(
                        exception: error!.localize(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
