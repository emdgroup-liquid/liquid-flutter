import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Intercepts [LdMonkeySelection.viewing] changes while detail edits are at risk.
///
/// | Condition | Behaviour |
/// |-----------|-----------|
/// | [isSaving] | Reverts the viewing change until the save completes |
/// | [isDirty] && !isSaving | Prompts via [onConfirmDiscard]; cancel restores prior viewing |
/// | pristine and idle | Allows navigation |
class LdMonkeyViewingGuard<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final bool isDirty;
  final bool isSaving;
  final Future<bool> Function() onConfirmDiscard;
  final Widget child;

  const LdMonkeyViewingGuard({
    super.key,
    required this.isDirty,
    required this.isSaving,
    required this.onConfirmDiscard,
    required this.child,
  });

  @override
  State<LdMonkeyViewingGuard<T, IdType>> createState() => _LdMonkeyViewingGuardState<T, IdType>();
}

class _LdMonkeyViewingGuardState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyViewingGuard<T, IdType>> {
  Set<IdType>? _stableViewing;
  bool _handlingViewingChange = false;

  @override
  Widget build(BuildContext context) {
    final viewing = context.watch<LdMonkeySelection<T, IdType>>().viewing;
    _stableViewing ??= viewing;

    if (!_handlingViewingChange && !setEquals(viewing, _stableViewing)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleViewingChange(viewing);
        }
      });
    }

    return widget.child;
  }

  Future<void> _handleViewingChange(Set<IdType> requestedViewing) async {
    if (_handlingViewingChange) {
      return;
    }

    final previousViewing = _stableViewing ?? requestedViewing;
    if (setEquals(requestedViewing, previousViewing)) {
      return;
    }

    if (!widget.isDirty && !widget.isSaving) {
      _stableViewing = requestedViewing;
      return;
    }

    _handlingViewingChange = true;
    try {
      if (widget.isSaving) {
        if (mounted) {
          LdMonkeySelection.updateViewing<T, IdType>(context, previousViewing);
        }
        return;
      }

      final discard = await widget.onConfirmDiscard();
      if (!mounted) {
        return;
      }

      if (discard) {
        _stableViewing = requestedViewing;
      } else {
        LdMonkeySelection.updateViewing<T, IdType>(context, previousViewing);
      }
    } finally {
      _handlingViewingChange = false;
    }
  }
}
