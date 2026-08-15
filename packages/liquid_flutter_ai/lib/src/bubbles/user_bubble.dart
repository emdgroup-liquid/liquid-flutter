import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:liquid_flutter_ai/src/send/send_fly_scope.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// End-aligned bubble for user messages.
class LdUserBubble extends StatelessWidget {
  final String text;
  final List<LdComposeAttachment> attachments;
  final Widget? trailing;

  /// When true, expands to fill parent constraints (used by send-fly).
  final bool fill;

  const LdUserBubble({
    super.key,
    required this.text,
    this.attachments = const [],
    this.trailing,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final hasAttachments = attachments.isNotEmpty;
    final hasText = text.isNotEmpty;
    final textStyle = ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m);

    final measureKey = LdSendFlyMeasureKey.maybeOf(context);
    final content = LdAutoSpace(
      crossAxisAlignment: fill
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (hasAttachments) _buildAttachments(theme),
        if (hasText)
          SelectableText(
            text,
            style: textStyle,
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
      ],
    );

    final bubble = Container(
      key: measureKey,
      width: fill ? double.infinity : null,
      height: fill ? double.infinity : null,
      alignment: fill ? Alignment.centerLeft : null,
      padding: theme.pad(size: LdSize.m),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: theme.radius(LdSize.m),
      ),
      // Fill mode is laid out under animating tight heights; allow intrinsic
      // content and clip instead of overflowing the Column.
      child: fill
          ? ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxHeight: double.infinity,
                child: content,
              ),
            )
          : content,
    );

    if (fill) {
      return bubble;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: bubble),
        if (trailing != null) ...[ldHSpacerS, trailing!],
      ],
    );
  }

  Widget _buildAttachments(LdTheme theme) {
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        for (final attachment in attachments)
          _buildAttachmentChip(theme, attachment),
      ],
    ).spaceS();
  }

  Widget _buildAttachmentChip(LdTheme theme, LdComposeAttachment attachment) {
    if (attachment.isImage && attachment.preview != null) {
      return ClipRRect(
        borderRadius: theme.radius(LdSize.s),
        child: SizedBox(width: 56, height: 56, child: attachment.preview),
      );
    }

    return LdTag(
      size: LdSize.s,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            attachment.isImage
                ? LucideIcons.image
                : attachment.isAudio
                ? LucideIcons.mic
                : LucideIcons.paperclip,
            size: theme.labelSize(LdSize.s),
          ),
          ldHSpacerXS,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
