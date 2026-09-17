import 'package:flutter/widgets.dart';

import 'attachment_labels.dart';
import 'attachment_result.dart';

/// A host-provided attachment tab.
///
/// Register one or more on [LdAttachmentPickerConfig.customTabs] to add a tab
/// with a custom icon, label and page. The page is rendered in place of the
/// built-in tab bodies and reports its result through
/// [LdAttachmentCustomController].
class LdAttachmentCustomTab {
  const LdAttachmentCustomTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.pageBuilder,
  });

  /// Stable identifier, unique across tabs. Used as the navigation route.
  final String id;

  /// Tab bar label.
  final String label;

  /// Tab bar icon.
  final IconData icon;

  /// Builds the tab body.
  final LdAttachmentCustomPageBuilder pageBuilder;
}

/// Builds the body of an [LdAttachmentCustomTab].
typedef LdAttachmentCustomPageBuilder =
    Widget Function(
      BuildContext context,
      LdAttachmentCustomController controller,
    );

/// Narrow surface handed to a custom tab page.
///
/// Custom tabs never touch the picker controller directly: they either add an
/// attachment to the running selection ([pick]) or finish the picker with one
/// ([complete]).
class LdAttachmentCustomController {
  const LdAttachmentCustomController({
    required this.labels,
    required this.pick,
    required this.complete,
  });

  /// The picker's active labels, for consistent copy.
  final LdAttachmentPickerLabels labels;

  /// Adds [attachment] to the selection (or completes it in single-select
  /// mode), leaving the picker open in multi-select mode.
  final void Function(LdPickedAttachment attachment) pick;

  /// Adds [attachment] and finishes the picker, resolving the current
  /// selection.
  final void Function(LdPickedAttachment attachment) complete;
}
