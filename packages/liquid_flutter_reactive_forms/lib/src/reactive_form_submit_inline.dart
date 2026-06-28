import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_reactive_detail_form_mode.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Mode-aware inline submit button for reactive forms.
class LdReactiveFormSubmitInline extends StatelessWidget {
  final LdMonkeyReactiveDetailFormMode mode;
  final LdSubmitController<void, void> saveController;
  final FormGroup form;
  final String? submitText;
  final bool isSaving;

  const LdReactiveFormSubmitInline({
    super.key,
    required this.mode,
    required this.saveController,
    required this.form,
    required this.isSaving,
    this.submitText,
  });

  bool get _disabled {
    if (isSaving || !form.valid) {
      return true;
    }
    return switch (mode) {
      LdMonkeyReactiveDetailFormMode.edit => form.pristine,
      LdMonkeyReactiveDetailFormMode.create => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LdSubmit<void, void>(
      controller: saveController,
      child: LdButton.filled(
        size: LdSize.l,
        disabled: _disabled,
        leading: Icon(LucideIcons.save),
        child: Text(submitText ?? _defaultSubmitText),
        onPressed: () async {
          await saveController.trigger();
        },
      ),
    );
  }

  String get _defaultSubmitText => switch (mode) {
        LdMonkeyReactiveDetailFormMode.edit => 'Save',
        LdMonkeyReactiveDetailFormMode.create => 'Create',
      };
}
