import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_field_conflict.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_field_conflict_error.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Inline hint for a field with an unresolved server conflict.
class LdMonkeyFieldConflictHint extends StatelessWidget {
  final AbstractControl<dynamic> control;
  final String? label;
  final ValueChanged<LdMonkeyFieldConflictResolution> onResolve;

  const LdMonkeyFieldConflictHint({
    super.key,
    required this.control,
    required this.onResolve,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final error = control.getError(kLdMonkeyServerConflictKey);
    if (error is! LdMonkeyFieldConflictError) {
      return const SizedBox.shrink();
    }

    final fieldLabel = label ?? 'Field';

    return LdHint(
      type: LdHintType.warning,
      child: LdAutoSpace(
        children: [
          LdText.p(
            '$fieldLabel was changed on the server while you were editing.',
          ),
          Row(
            children: [
              LdButton.outline(
                size: LdSize.s,
                child: const Text('Keep mine'),
                onPressed: () => onResolve(LdMonkeyFieldConflictResolution.keepLocal),
              ),
              ldHSpacerS,
              LdButton.filled(
                size: LdSize.s,
                child: const Text('Use server'),
                onPressed: () => onResolve(LdMonkeyFieldConflictResolution.preferServer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
