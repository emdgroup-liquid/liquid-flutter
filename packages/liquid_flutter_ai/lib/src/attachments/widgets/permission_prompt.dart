import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'empty_state.dart';

/// A permission-denied / limited-access prompt shown inside a picker tab.
class LdAttachmentPermissionPrompt extends StatelessWidget {
  const LdAttachmentPermissionPrompt({
    super.key,
    required this.message,
    required this.actionLabel,
    this.onAction,
    this.icon = LucideIcons.imageOff,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LdAttachmentEmptyState(
      icon: icon,
      message: message,
      action: LdButton.outline(
        onPressed: onAction ?? () {},
        size: LdSize.m,
        child: Text(actionLabel),
      ),
    );
  }
}
