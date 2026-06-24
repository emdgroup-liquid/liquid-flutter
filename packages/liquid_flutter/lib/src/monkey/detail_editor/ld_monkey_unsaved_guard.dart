import 'package:flutter/material.dart';

/// Blocks route pop / modal dismiss while detail edits are dirty or saving.
///
/// When [isDirty] and not [isSaving], a back gesture or pop attempt shows
/// [onConfirmDiscard]. Navigation proceeds only when the callback returns
/// `true`.
///
/// While [isSaving], navigation is blocked without a discard prompt.
class LdMonkeyUnsavedGuard extends StatelessWidget {
  final bool isDirty;
  final bool isSaving;
  final Future<bool> Function() onConfirmDiscard;
  final Widget child;

  const LdMonkeyUnsavedGuard({
    super.key,
    required this.isDirty,
    required this.isSaving,
    required this.onConfirmDiscard,
    required this.child,
  });

  bool get _canPop => !isDirty && !isSaving;

  Future<void> _onPopInvoked(BuildContext context, bool didPop) async {
    if (didPop || isSaving || !isDirty) {
      return;
    }

    final discard = await onConfirmDiscard();
    if (discard && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(context, didPop),
      child: child,
    );
  }
}
