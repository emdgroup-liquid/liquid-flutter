import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef LdDetailToForm<TDetail> = Map<String, Object?> Function(TDetail detail);

typedef LdFormToUpdatePayload<TUpdate, TDetail> = TUpdate Function(
  FormGroup form,
  TDetail detail,
);

typedef LdFormToCreatePayload<TCreate, TDetail> = TCreate Function(
  FormGroup form,
  TDetail detail,
);

typedef LdFormLoadDetail<TDetail, T> = Future<TDetail> Function(
  BuildContext context,
  T? entity,
);

typedef LdFormOnSubmitted<T extends Identifiable<IdType>, IdType> = void
    Function(
  BuildContext context,
  T? created,
);

/// Reactive detail editor for monkey master-detail pages.
///
/// [formItems] declares the model side — one [LdReactiveFormItem] per control.
/// [childrenBuilder] returns the free widget tree rendered inside the form.
/// Use [LdFormInput], [LdFormChoose], etc. to bind controls by key, and place
/// any other widgets freely alongside them.
class LdForm<T extends Identifiable<IdType>, IdType, TDetail extends Object,
    TCreate, TUpdate> extends StatefulWidget {
  final LdFormMode mode;
  final LdPaginatorItem<T>? item;

  final FormGroup Function(BuildContext context) formGroup;
  final Widget child;
  final LdDetailToForm<TDetail> detailToFormValues;
  final LdFormToUpdatePayload<TUpdate, TDetail>? formToUpdatePayload;
  final LdFormToCreatePayload<TCreate, TDetail>? formToCreatePayload;
  final LdFormLoadDetail<TDetail, T> itemToDetail;

  final LdReactiveFormSaveMode saveMode;
  final LdMonkeyFieldConflictPolicy conflictPolicy;
  final LdMonkeyFieldConflictResolver? onFieldConflict;
  final LdFormPreSaveCheck preSaveCheck;
  final LdFormOnSubmitted<T, IdType>? onSubmitted;

  final void Function(FormGroup form)? onFormInit;

  final List<Validator<dynamic>> validators;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdForm({
    super.key,
    required this.item,
    required this.formGroup,
    required this.child,
    required this.detailToFormValues,
    required this.formToUpdatePayload,
    required this.itemToDetail,
    this.saveMode = LdReactiveFormSaveMode.adaptive,
    this.conflictPolicy = LdMonkeyFieldConflictPolicy.keepLocal,
    this.onFieldConflict,
    this.preSaveCheck = LdFormPreSaveCheck.none,
    this.onFormInit,
    this.validators = const [],
    this.validationMessages,
    required this.mode,
    this.formToCreatePayload,
    this.onSubmitted,
  });

  @override
  State<LdForm<T, IdType, TDetail, TCreate, TUpdate>> createState() =>
      _LdFormState<T, IdType, TDetail, TCreate, TUpdate>();
}

class _LdFormState<
    T extends Identifiable<IdType>,
    IdType,
    TDetail extends Object,
    TCreate,
    TUpdate> extends State<LdForm<T, IdType, TDetail, TCreate, TUpdate>> {
  TDetail? _detail;
  IdType? _currentId;
  final Map<String, Object?> _lastServerFormValues = {};

  bool _mergeInProgress = false;
  StreamSubscription<LdPaginatorItem<T>>? _itemSubscription;
  StreamSubscription<dynamic>? _formSubscription;
  bool _loadingDetail = false;

  List<LdMonkeyFieldConflict> _conflicts = [];

  bool get _hasConflicts => _conflicts.isNotEmpty;

  late FormGroup _form;

  @override
  void initState() {
    super.initState();

    // Make sure the formToUpdatePayload and formToCreatePayload are provided in the correct mode.
    switch (widget.mode) {
      case LdFormMode.edit:
        assert(
          widget.formToUpdatePayload != null,
          'formToUpdatePayload must be provided in edit mode',
        );
        break;
      case LdFormMode.create:
        assert(
          widget.formToCreatePayload != null,
          'formToCreatePayload must be provided in create mode',
        );
        break;
    }

    _form = widget.formGroup(context);

    widget.onFormInit?.call(_form);

    _formSubscription = _form.valueChanges.listen((_) => _onEditStateChanged());
    _bootstrapDetail();
  }

  bool get _editsAtRisk => _form.dirty || _isSaving;

  void _onEditStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<bool> _onLeaveLockedLocation(BuildContext _) async {
    if (_isSaving) return false;
    return ldFormConfirmDiscardEdits(context);
  }

  Future<void> _confirmDiscardAndPop(Object? result) async {
    if (_isSaving) return;
    final navigator = Navigator.of(context);
    final shouldKeepEditing = await ldFormConfirmDiscardEdits(context);
    if (shouldKeepEditing || !mounted) return;
    _form.markAsPristine();
    navigator.pop(result);
  }

  @override
  void didUpdateWidget(
    covariant LdForm<T, IdType, TDetail, TCreate, TUpdate> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != LdFormMode.edit) return;

    final newEntity = widget.item?.value;
    final oldEntity = oldWidget.item?.value;
    if (newEntity != oldEntity) {
      if (newEntity != null) _enqueueMerge(newEntity);
    }
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _formSubscription?.cancel();
    _form.dispose();

    super.dispose();
  }

  bool get _blurSaveEnabled {
    if (widget.mode == LdFormMode.create) return false;
    return switch (widget.saveMode) {
      LdReactiveFormSaveMode.onBlur => true,
      LdReactiveFormSaveMode.manualSubmit => false,
      LdReactiveFormSaveMode.adaptive => LdTheme.of(context).platform.isMobile,
      LdReactiveFormSaveMode.custom => false,
    };
  }

  Future<void> _bootstrapDetail() async {
    // We are in edit mode and there should be an item we can obtain by id.

    _loadingDetail = true;

    try {
      final entity = widget.item?.value;
      if (entity != null) _currentId = entity.id;
      _detail = await widget.itemToDetail(context, entity);

      _patchFormFromDetail(markPristine: true);
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  final List<T> _mergeQueue = [];

  Future<void> _enqueueMerge(T entity) async {
    _mergeQueue.add(entity);
    _processMergeQueue();
  }

  void _processMergeQueue() async {
    if (_mergeInProgress) return;
    if (_mergeQueue.isEmpty) return;
    _mergeInProgress = true;

    final entity = _mergeQueue.first;
    try {
      final newDetail = await widget.itemToDetail(context, entity);

      final serverValues = widget.detailToFormValues(newDetail);
      _mergeFromServer(serverValues);
      _mergeQueue.removeAt(0);
      _detail = newDetail;
    } finally {
      _mergeInProgress = false;
    }
    _processMergeQueue();
  }

  void _patchFormFromDetail({required bool markPristine}) {
    final detail = _detail;
    if (detail == null || !mounted) return;
    final values = widget.detailToFormValues(detail);
    for (final entry in values.entries) {
      print('entry: ${entry.key} ${entry.value}');
      if (!_form.contains(entry.key)) continue;
      final control = _form.control(entry.key);
      if (control is FormArray) {
        control.clear();
        control.addAll(entry.value as List<AbstractControl<dynamic>>);
      } else {
        _form.control(entry.key).value = entry.value;
      }
      if (markPristine) _form.control(entry.key).markAsPristine();
      _lastServerFormValues[entry.key] = entry.value;
    }
    if (markPristine) _form.markAsPristine();
    setState(() {});
  }

  Future<void> _mergeFromServer(Map<String, Object?> serverValues) async {
    _conflicts = _computeConflicts(_form.value, serverValues);

    for (final item in serverValues.entries) {
      // Skip applying the new values if there is a conflict.
      if (_conflicts.any((conflict) => conflict.fieldKey == item.key)) continue;

      // Safely apply the new values to the form.

      final control = _form.control(item.key);
      control.value = item.value;
      control.markAsPristine();
    }

    // Now we iterate over the conflicts and apply the conflict resolutions.

    for (final conflict in _conflicts) {
      if (widget.onFieldConflict != null) {
        LdMonkeyFieldConflictResolution? resolution;
        if (widget.onFieldConflict != null) {
          resolution = await widget.onFieldConflict!(conflict);
        } else if (widget.conflictPolicy ==
            LdMonkeyFieldConflictPolicy.keepLocal) {
          resolution = LdMonkeyFieldConflictResolution.keepLocal;
        } else if (widget.conflictPolicy ==
            LdMonkeyFieldConflictPolicy.preferServer) {
          resolution = LdMonkeyFieldConflictResolution.preferServer;
        }

        if (resolution == null) continue;

        _applyConflictResolution(conflict, resolution);
      }
    }

    if (mounted) setState(() {});
  }

  void _applyConflictResolution(
    LdMonkeyFieldConflict conflict,
    LdMonkeyFieldConflictResolution resolution,
  ) {
    if (!_form.contains(conflict.fieldKey)) return;
    final control = _form.control(conflict.fieldKey);
    control.value = switch (resolution) {
      LdMonkeyFieldConflictResolution.keepLocal => conflict.localValue,
      LdMonkeyFieldConflictResolution.preferServer => conflict.serverValue,
    };
    if (resolution == LdMonkeyFieldConflictResolution.preferServer) {
      control.markAsPristine();
    }
    _conflicts.remove(conflict);
    if (mounted) setState(() {});
  }

  // Extracts the server values from the exception and merges them into the form.
  Future<void> _applyVersionConflict(
    LdFormConflictException<TDetail> exception,
  ) async {
    final Map<String, Object?> serverValues;
    if (exception.serverDetail != null) {
      serverValues =
          widget.detailToFormValues(exception.serverDetail as TDetail);
    } else {
      serverValues = exception.serverFieldValues ?? {};
    }

    _mergeFromServer(serverValues);
  }

  bool _valuesAreEqual(Object? a, Object? b) {
    if (a is DateTime && b is DateTime) {
      return a.isAtSameMomentAs(b);
    }
    if (a is List && b is List) {
      return listEquals(a, b);
    }
    if (a is Map && b is Map) {
      return mapEquals(a, b);
    }
    if (a is Set && b is Set) {
      return setEquals(a, b);
    }
    return a == b;
  }

  // Computes the conflicts between the local and server values.
  List<LdMonkeyFieldConflict> _computeConflicts(
    Map<String, Object?> localValue,
    Map<String, Object?> serverValue,
  ) {
    final conflicts = <LdMonkeyFieldConflict>[];
    for (final entry in localValue.entries) {
      // Skip if the server value does not contain the key.
      if (!serverValue.containsKey(entry.key)) continue;
      // Skip if the field is not dirty. We only want to compare dirty fields.
      if (!_form.control(entry.key).dirty) continue;
      final ourValue = entry.value;
      final theirValue = serverValue[entry.key];

      // Check if the values are different. Handle special cases like DateTime and List/Map/Set.
      if (!_valuesAreEqual(ourValue, theirValue)) {
        conflicts.add(
          LdMonkeyFieldConflict(
            fieldKey: entry.key,
            localValue: ourValue,
            serverValue: theirValue,
          ),
        );
      }
    }
    return conflicts;
  }

  Future<void> _runPreSaveCheck() async {
    if (widget.mode != LdFormMode.edit ||
        widget.preSaveCheck != LdFormPreSaveCheck.repositoryGetById) {
      return;
    }
    final id = _currentId;
    if (id == null) return;
    final serverEntity = await LdListController.of<T, IdType>(context)
        .getById(context, id, skipCache: true);
    if (!mounted) return;
    final newDetail = await widget.itemToDetail(context, serverEntity);
    final serverValues = widget.detailToFormValues(newDetail);
    await _mergeFromServer(serverValues);
  }

  bool _isSaving = false;

  Future<void> _triggerSubmit() async {
    if (_form.invalid || _isSaving) return;
    if (widget.mode == LdFormMode.edit && !_form.dirty) return;
    setState(() {
      _isSaving = true;
    });
    try {
      await _performSave();
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _performSave() async {
    if (_detail == null) return;
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }

    try {
      final model = context.read<LdModel<T, IdType, Object?, Object?>>();

      if (_mergeInProgress) return;
      if (_hasConflicts) return;

      // Pre save tries to fetch the server values and compute the conflicts.
      await _runPreSaveCheck();
      if (_hasConflicts) {
        return;
      }
      if (!mounted) return;

      if (widget.mode == LdFormMode.create) {
        final payload = widget.formToCreatePayload!(_form, _detail!);
        // ignore: use_build_context_synchronously
        final created = await model.create(context, payload);
        _form.markAsPristine();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onSubmitted?.call(context, created);
        });
        return;
      }

      final payload = widget.formToUpdatePayload!(_form, _detail!);
      final entityId = widget.item!.value!.id;
      // ignore: use_build_context_synchronously
      final updated = await model.update(context, entityId, payload);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onSubmitted?.call(context, updated);
      });
      _form.markAsPristine();
    } on LdFormConflictException<TDetail> catch (exception) {
      await _applyVersionConflict(exception);
      rethrow;
    }
  }

  void _reset() {
    _patchFormFromDetail(markPristine: true);
  }

  /// Resolves a single [conflict] by applying the [resolution] to the form.
  void _resolveConflict({
    required LdMonkeyFieldConflict conflict,
    required LdMonkeyFieldConflictResolution resolution,
  }) {
    _applyConflictResolution(conflict, resolution);
    setState(() {});
  }

  void _onFieldBlurred(String fieldKey) {
    if (!_form.contains(fieldKey)) return;
    if (_blurSaveEnabled) {
      _triggerSubmit();
    }
  }

  void _onFieldCommitted(String fieldKey) {
    if (!_form.contains(fieldKey)) return;
    if (_blurSaveEnabled) {
      _triggerSubmit();
    }
  }

  void _onDiscardFieldChanges(String fieldKey) {
    if (!_form.contains(fieldKey)) return;
    final values = widget.detailToFormValues(_detail!);

    final value = values[fieldKey];
    _form.control(fieldKey).value = value;
    _form.control(fieldKey).markAsPristine();

    setState(() {});
  }

  LdFormState _buildFormState() {
    return LdFormState(
      mode: widget.mode,
      isSaving: _isSaving,
      onSubmit: _triggerSubmit,
      onReset: _reset,
      discardFieldChanges: _onDiscardFieldChanges,
      onFieldBlurred: _onFieldBlurred,
      onFieldCommitted: _onFieldCommitted,
      detail: _detail,
      conflicts: LdFormConflicts(
        conflicts: _conflicts,
        resolveConflict: _resolveConflict,
      ),
      isMergeInProgress: _mergeInProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_detail == null) {
      return const Center(child: LdLoader());
    }
    if (widget.mode == LdFormMode.edit && widget.item?.value == null) {
      return const Center(child: LdLoader());
    }

    return LdLocationLockGuard(
      locked: _editsAtRisk,
      pathPrefix: GoRouter.of(context).state.uri.path,
      onLeave: _onLeaveLockedLocation,
      onBlockedPop: _confirmDiscardAndPop,
      child: ReactiveForm(
        formGroup: _form,
        child: Provider.value(
          value: _buildFormState(),
          child: widget.child,
        ),
      ),
    );
  }
}
