import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/attachments/widgets/attachment_chip.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:liquid_flutter_ai/src/models/outgoing.dart';
import 'package:liquid_flutter_ai/src/send/send_fly_scope.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// End-aligned bubble for user messages.
class LdUserBubble extends StatelessWidget {
  final String text;
  final List<LdComposeAttachment> attachments;
  final LdMessageDelivery delivery;
  final LdException? deliveryError;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onRetryAttachment;
  final Widget? trailing;

  /// When true, expands to fill parent constraints (used by send-fly).
  final bool fill;

  const LdUserBubble({
    super.key,
    required this.text,
    this.attachments = const [],
    this.delivery = LdMessageDelivery.sent,
    this.deliveryError,
    this.onRetry,
    this.onRetryAttachment,
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
        if (hasAttachments) _buildAttachments(),
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

    final deliveryChrome = _buildDelivery(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: bubble),
            if (trailing != null) ...[ldHSpacerS, trailing!],
          ],
        ),
        if (deliveryChrome != null) ...[ldSpacerS, deliveryChrome],
      ],
    );
  }

  Widget? _buildDelivery(BuildContext context) {
    final persistFailed = attachments.any(
      (attachment) => attachment.hasPersistError,
    );
    if (delivery != LdMessageDelivery.error ||
        persistFailed ||
        deliveryError == null) {
      return null;
    }
    return _buildSendError(context);
  }

  Widget _buildSendError(BuildContext context) {
    final theme = LdTheme.of(context);
    final message = deliveryError!.localize(context).message;
    final retry = onRetry;
    return Row(
      key: const ValueKey('ld-send-error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: LdText.ls(message, color: theme.errorColor)),
        if (retry != null) ...[
          ldHSpacerS,
          LdButton.ghost(
            key: const ValueKey('ld-send-retry'),
            size: LdSize.s,
            onPressed: retry,
            child: const Icon(LucideIcons.rotateCcw),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachments() {
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        for (final attachment in attachments)
          LdComposeAttachmentTile(
            attachment: attachment,
            maxHeight: 160,
            maxWidth: 240,
            onRetry: _retryFor(attachment),
          ),
      ],
    ).spaceS();
  }

  VoidCallback? _retryFor(LdComposeAttachment attachment) {
    if (!attachment.hasPersistError) {
      return null;
    }
    final onRetryAttachment = this.onRetryAttachment;
    if (onRetryAttachment != null) {
      return () => onRetryAttachment(attachment.id);
    }
    return onRetry;
  }
}
