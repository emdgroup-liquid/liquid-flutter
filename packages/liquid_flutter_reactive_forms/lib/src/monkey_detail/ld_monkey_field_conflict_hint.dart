import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_field_conflict.dart';

/// Inline hint for a field with an unresolved server conflict.
class LdMonkeyFieldConflictHint extends StatefulWidget {
  final LdMonkeyFieldConflict conflict;
  final void Function(LdMonkeyFieldConflictResolution resolution) onResolve;
  final void Function(bool isShowing, LdMonkeyFieldConflictResolution resolution) onPreviewResolution;
  const LdMonkeyFieldConflictHint({
    super.key,
    required this.conflict,
    required this.onResolve,
    required this.onPreviewResolution,
  });

  @override
  State<LdMonkeyFieldConflictHint> createState() => _LdMonkeyFieldConflictHintState();
}

class _LdMonkeyFieldConflictHintState extends State<LdMonkeyFieldConflictHint> {
  LdMonkeyFieldConflictResolution _selectedResolution = LdMonkeyFieldConflictResolution.keepLocal;
  @override
  Widget build(BuildContext context) {
    return LdHint(
      crossAxisAlignment: CrossAxisAlignment.start,
      type: LdHintType.warning,
      child: LdAutoSpace(
        children: [
          LdText.p(
            'Changed on the server while you were editing.',
          ),
          LdBundle(
            children: [
              LdRadio(
                label: (LiquidLocalizations.of(context).fieldConflictKeepMine),
                checked: _selectedResolution == LdMonkeyFieldConflictResolution.keepLocal,
                onChanged: (value) {
                  setState(() {
                    _selectedResolution = LdMonkeyFieldConflictResolution.keepLocal;
                  });
                  widget.onPreviewResolution(true, LdMonkeyFieldConflictResolution.keepLocal);
                },
              ),
              LdRadio(
                label: (LiquidLocalizations.of(context).fieldConflictUseServer),
                checked: _selectedResolution == LdMonkeyFieldConflictResolution.preferServer,
                onChanged: (value) {
                  setState(() {
                    _selectedResolution = LdMonkeyFieldConflictResolution.preferServer;
                  });
                  widget.onPreviewResolution(true, LdMonkeyFieldConflictResolution.preferServer);
                },
              ),
            ],
          ),
          LdButton(
            size: LdSize.m,
            child: Text(LiquidLocalizations.of(context).apply),
            onPressed: () => widget.onResolve(_selectedResolution),
          ),
        ],
      ),
    );
  }
}
