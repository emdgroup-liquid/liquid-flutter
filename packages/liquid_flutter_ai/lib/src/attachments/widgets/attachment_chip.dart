import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/attachments/attachment_models.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact attachment chip used by the compose strip and user bubbles.
///
/// Image/video previews keep their intrinsic aspect ratio inside [maxHeight]
/// / [maxWidth]. Files, locations, and contacts render as a labeled tag.
class LdComposeAttachmentTile extends StatelessWidget {
  const LdComposeAttachmentTile({
    super.key,
    required this.attachment,
    this.onDismiss,
    this.onRetry,
    this.maxHeight = 80,
    this.maxWidth = 140,
  });

  final LdComposeAttachment attachment;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  /// Maximum height of an image/video preview.
  final double maxHeight;

  /// Maximum width of an image/video preview (ultra-wide images cap here).
  final double maxWidth;

  bool get _hasVisualPreview =>
      attachment.preview != null &&
      (attachment.isImage || attachment.kind == LdAttachmentKind.video);

  @override
  Widget build(BuildContext context) {
    final child = _hasVisualPreview
        ? _buildPreview(context)
        : _buildTag(context);
    return _wrapPersistChrome(context, child);
  }

  Widget _wrapPersistChrome(BuildContext context, Widget child) {
    final theme = LdTheme.of(context);
    final showProgress = attachment.isPersisting;
    final showError = attachment.hasPersistError;
    if (!showProgress && !showError) {
      return child;
    }

    final retry = onRetry;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showProgress)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.background.withValues(alpha: 0.55),
                  borderRadius: theme.radius(LdSize.s),
                ),
                child: Center(
                  child: SizedBox(
                    key: ValueKey('ld-persist-progress-${attachment.id}'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      value: attachment.persistProgress,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showError)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.errorColor.withValues(alpha: 0.82),
                borderRadius: theme.radius(LdSize.s),
              ),
              child: Center(
                child: LdButton.filled(
                  key: ValueKey('ld-persist-retry-${attachment.id}'),
                  size: LdSize.s,
                  color: theme.error,
                  onPressed: retry ?? () {},
                  child: const Icon(LucideIcons.rotateCcw),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final theme = LdTheme.of(context);
    final preview = ClipRRect(
      borderRadius: theme.radius(LdSize.s),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
        child: FittedBox(fit: BoxFit.contain, child: attachment.preview),
      ),
    );
    final dismiss = onDismiss;
    if (dismiss == null) {
      return preview;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        preview,
        Positioned(
          top: -6,
          right: -6,
          child: LdButton.vague(
            size: LdSize.xs,
            onPressed: dismiss,
            child: const Icon(LucideIcons.x),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context) {
    final size = attachment.size;
    final showSize =
        size != null &&
        (attachment.kind == LdAttachmentKind.file ||
            (attachment.kind == null && !attachment.isImage));

    return LdTag(
      onDismiss: onDismiss,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ldIconForComposeAttachment(attachment)),
          ldHSpacerXS,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              attachment.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (showSize) ...[ldHSpacerXS, Text(ldFormatBytes(size))],
        ],
      ),
    );
  }
}

/// Icon for a compose/message attachment, based on [LdComposeAttachment.kind]
/// when present.
IconData ldIconForComposeAttachment(LdComposeAttachment attachment) {
  final kind = attachment.kind;
  if (kind != null) {
    return switch (kind) {
      LdAttachmentKind.image => LucideIcons.image,
      LdAttachmentKind.video => LucideIcons.film,
      LdAttachmentKind.file => LucideIcons.file,
      LdAttachmentKind.location => LucideIcons.mapPin,
      LdAttachmentKind.contact => LucideIcons.user,
      LdAttachmentKind.custom => LucideIcons.paperclip,
    };
  }
  if (attachment.isImage) {
    return LucideIcons.image;
  }
  if (attachment.isAudio) {
    return LucideIcons.mic;
  }
  return LucideIcons.paperclip;
}
