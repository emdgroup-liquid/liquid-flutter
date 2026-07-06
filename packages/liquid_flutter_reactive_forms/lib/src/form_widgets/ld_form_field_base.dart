import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

export 'package:liquid_flutter_reactive_forms/src/validation_messages.dart' show ldReactiveFormShowErrors;
export 'package:reactive_forms/reactive_forms.dart'
    show ReactiveFormField, ReactiveFormFieldState, ValidationMessageFunction;

/// Builds the standard field chrome: the field widget, optional conflict hint,
/// error text, and optional hint — in the correct priority order.
///
/// Intended to be used inside [ReactiveFormField.builder] by all Ld form
/// field widgets.
Widget ldBuildFormFieldChrome<TModel, TView>({
  required ReactiveFormFieldState<TModel, TView> state,
  required Widget field,
  required String formKey,
  required LdHint? Function(ReactiveFormFieldState<TModel, TView>)? hintBuilder,
  required BuildContext context,
}) {
  final scope = context.watch<LdFormState?>();
  final form = ReactiveForm.of(context) as FormGroup;

  final conflicts = scope?.conflicts.conflicts.where((conflict) => conflict.fieldKey == formKey).toList() ?? [];

  final hasConflict = conflicts.isNotEmpty;

  return LdWrapConditional(
    condition: hasConflict,
    builder: (context, child) {
      return LdCard(
        footer: LdAutoSpace(
          children: [
            if (hasConflict)
              for (final conflict in conflicts)
                LdMonkeyFieldConflictHint(
                  conflict: conflict,
                  onPreviewResolution: (isShowing, resolution) {
                    if (isShowing && resolution == LdMonkeyFieldConflictResolution.preferServer) {
                      form.control(conflict.fieldKey).value = conflict.serverValue;
                    } else {
                      form.control(conflict.fieldKey).value = conflict.localValue;
                    }
                  },
                  onResolve: (resolution) => scope!.conflicts.resolveConflict(
                    conflict: conflict,
                    resolution: resolution,
                  ),
                ),
          ],
        ),
        child: child,
      );
    },
    child: LdAutoSpace(
      children: [
        field,
        if (state.errorText != null)
          LdHint(type: LdHintType.error, child: Text(state.errorText!))
        else if (hintBuilder != null)
          hintBuilder(state) ?? const SizedBox.shrink(),
      ],
    ),
  );
}
