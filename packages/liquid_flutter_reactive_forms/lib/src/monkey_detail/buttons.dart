import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LdFormSubmitButton extends StatelessWidget {
  const LdFormSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<LdFormState>();
    final form = ReactiveForm.of(context)!;

    return LdSubmit<void, void>(
      disabled: !form.dirty || formState.isMergeInProgress || formState.isSaving,
      config: LdSubmitConfig(
        submitText: switch (formState.mode) {
          LdFormMode.edit => LiquidLocalizations.of(context).save,
          LdFormMode.create => LiquidLocalizations.of(context).create,
        },
        loadingText: switch (formState.mode) {
          LdFormMode.edit => LiquidLocalizations.of(context).saving,
          LdFormMode.create => LiquidLocalizations.of(context).creating,
        },
        action: (_) async {
          await formState.onSubmit();
        },
      ),
      child: LdSubmitDialogBuilder<void, void>(),
    );
  }
}

class LdFormResetButton extends StatelessWidget {
  const LdFormResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context)!;
    final formState = context.watch<LdFormState>();

    return LdButton.outline(
      color: LdTheme.of(context).error,
      autoLoading: false,
      onPressed: () async {
        final confirm = await ldConfirmModal(
          useRootNavigator: true,
          context: context,
          title: Text('Discard changes'),
          description: 'Are you sure you want to discard the changes?',
          positive: Text(LiquidLocalizations.of(context).discardChanges),
          negative: Text(LiquidLocalizations.of(context).cancel),
          confirmColor: LdTheme.of(context).error,
          cancelColor: LdTheme.of(context).palette.neutral,
        );
        if (confirm) {
          formState.onReset();
        }
      },
      disabled: !form.dirty || formState.isMergeInProgress || formState.isSaving,
      child: Text(LiquidLocalizations.of(context).discardChanges),
    );
  }
}
