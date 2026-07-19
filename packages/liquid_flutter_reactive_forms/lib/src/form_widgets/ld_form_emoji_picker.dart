import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// A reactive emoji-picker field that binds to a [FormControl<String>] by
/// [formKey].
///
/// Tapping the [LdButton.ghost] trigger opens [LdEmojiPickerModal] inside an
/// [LdModalRoute].  When the user selects an emoji the value is propagated
/// back to the form control.
///
/// [label] is optional — omit it for a label-free trigger button.
///
/// Example:
/// ```dart
/// LdFormEmojiPicker(formKey: 'emoji', label: 'Icon'),
/// ```
class LdFormEmojiPicker extends StatelessWidget {
  final String formKey;
  final String? label;
  final bool? disabled;
  final LdSize size;

  final LdHint? Function(ReactiveFormFieldState<String, String>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormEmojiPicker({
    super.key,
    required this.formKey,
    this.label,
    this.disabled,
    this.size = LdSize.m,
    this.hintBuilder,
    this.validationMessages,
  });

  Future<void> _openPicker(
    BuildContext context,
    String? currentValue,
    bool isRequired,
    void Function(String) onSelected,
  ) {
    return LdModalRoute<String>(
      context: context,
      dialogSize: LdSize.m,
      pageBuilder: (ctx) => LdEmojiPickerModal(
        value: currentValue,
        allowEmptySelection: !isRequired,
        onEmojiSelected: onSelected,
      ),
    ).show(context, useRootNavigator: true);
  }

  double _getEmojiSize(LdSize size) => switch (size) {
        LdSize.xs => 16,
        LdSize.s => 20,
        LdSize.m => 24,
        LdSize.l => 28,
      };

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) {
        final isDisabled = disabled ?? state.control.disabled;
        final currentEmoji = state.value;
        final hasEmoji = currentEmoji != null && currentEmoji.isNotEmpty;
        final isRequired =
            state.control.validators.contains(Validators.required);
        final scope = context.watch<LdFormState?>();
        return ldBuildFormFieldChrome(
          state: state,
          formKey: formKey,
          hintBuilder: hintBuilder,
          context: context,
          field: Tooltip(
            message: label ?? '',
            child: LdTouchableSurface(
              disabled: isDisabled,
              onPressed: () =>
                  _openPicker(context, currentEmoji, isRequired, (emoji) {
                state.didChange(emoji);
                state.control.markAsDirty();
                scope?.onFieldCommitted(formKey);
              }),
              builder: (context, status, child) {
                final colors = inputColor(
                  LdTheme.of(context),
                  status,
                  isValid: state.control.valid,
                );
                return Container(
                  padding: LdTheme.of(context).pad(),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: LdTheme.of(context).radius(LdSize.s),
                    border: Border.all(color: colors.border),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(fontSize: _getEmojiSize(size)),
                    child: hasEmoji
                        ? LdEmoji(currentEmoji)
                        : SizedBox(width: 20, height: 20, child: Placeholder()),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
