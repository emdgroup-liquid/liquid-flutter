import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Shows a discard-confirmation modal for unsaved detail edits.
///
/// Returns `true` when the user chooses to keep editing.
/// Returns `false` when the user chooses to discard the edits.
/// Returns `null` when the modal is dismissed.
Future<bool?> ldFormConfirmDiscardEdits(
  BuildContext context, {
  String? description,
  Widget? title,
  Widget? discardLabel,
  Widget? keepEditingLabel,
}) {
  final l10n = LiquidLocalizations.of(context);
  return ldConfirmModal(
    context: context,
    title: title,
    description: description ?? l10n.discardUnsavedChanges,
    positive: keepEditingLabel ?? Text(l10n.keepEditing),
    negative: discardLabel ?? Text(l10n.discard),
    useRootNavigator: true,
  );
}
