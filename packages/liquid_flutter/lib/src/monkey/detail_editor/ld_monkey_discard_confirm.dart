import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Shows a discard-confirmation modal for unsaved detail edits.
///
/// Returns `true` when the user chooses to discard; `false` when they keep
/// editing.
Future<bool> ldMonkeyConfirmDiscardEdits(
  BuildContext context, {
  String? description,
  Widget? title,
  Widget? discardLabel,
  Widget? keepEditingLabel,
}) {
  return ldConfirmModal(
    context: context,
    title: title,
    description: description ?? 'Discard unsaved changes?',
    positive: discardLabel ?? const Text('Discard'),
    negative: keepEditingLabel ?? const Text('Keep editing'),
    useRootNavigator: true,
  );
}
