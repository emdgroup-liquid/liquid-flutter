import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A small caption header used to group sections inside the picker
/// (e.g. "RECENTLY SENT FILES", "OR CHOOSE A PLACE").
class LdAttachmentSectionHeader extends StatelessWidget {
  const LdAttachmentSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.padding,
  });

  final String label;

  /// Optional trailing widget, typically a text action such as "MANAGE".
  final Widget? trailing;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return Padding(
      padding:
          padding ??
          EdgeInsets.only(
            left: theme.paddingSize(size: LdSize.xs),
            right: theme.paddingSize(size: LdSize.xs),
            bottom: theme.paddingSize(size: LdSize.xs),
          ),
      child: Row(
        children: [
          Expanded(
            child: LdText.caption(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
