import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/tool_call_detail_modal.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact fixed-size row for a single tool call (no nested accordion).
class LdToolCallCard extends StatefulWidget {
  final LdToolCallItem item;

  /// When true, plays a short size/fade entrance on first mount.
  final bool animateAppear;

  /// Custom tap handler. When null, tap opens [showLdToolCallDetailModal].
  final VoidCallback? onPressed;

  const LdToolCallCard({
    super.key,
    required this.item,
    this.animateAppear = true,
    this.onPressed,
  });

  @override
  State<LdToolCallCard> createState() => _LdToolCallCardState();
}

class _LdToolCallCardState extends State<LdToolCallCard>
    with SingleTickerProviderStateMixin {
  void _handlePressed(BuildContext context) {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    showLdToolCallDetailModal(context, item: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return LdReveal(
      revealed: true,
      initialRevealed: false,
      child: LdListItem.trailingForward(
        borderRadius: theme.radius(LdSize.s),
        title: Text(widget.item.name),
        subtitle: widget.item.argsPreview != null
            ? Text(widget.item.argsPreview!)
            : null,
        leading: _buildLeading(theme),
        onPressed: () => _handlePressed(context),
      ),
    );
  }

  Widget _buildLeading(LdTheme theme) {
    return switch (widget.item.status) {
      LdToolCallStatus.pending => LdAvatar(child: Icon(LucideIcons.clock)),
      LdToolCallStatus.running => LdAvatar(
        child: Center(child: LdLoader(size: theme.labelSize(LdSize.s) * 2)),
      ),
      LdToolCallStatus.done => LdAvatar(
        color: theme.success,
        child: Icon(LucideIcons.check),
      ),

      LdToolCallStatus.error => LdAvatar(
        color: theme.error,
        child: Icon(LucideIcons.x),
      ),
    };
  }
}
