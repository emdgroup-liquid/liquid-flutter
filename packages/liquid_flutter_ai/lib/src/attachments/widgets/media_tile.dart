import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_models.dart';
import 'selection_badge.dart';

/// A square media thumbnail used by the gallery and file grids.
///
/// Renders the decoded [thumbnail] when available, a video duration pill, a
/// selection badge, and press feedback.
class LdAttachmentMediaTile extends StatelessWidget {
  const LdAttachmentMediaTile({
    super.key,
    required this.asset,
    required this.selected,
    this.selectionIndex,
    this.thumbnail,
    this.loading = false,
    this.onTap,
  });

  final LdMediaAsset asset;
  final bool selected;
  final int? selectionIndex;
  final Uint8List? thumbnail;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final radius = theme.radius(LdSize.s);

    return LdTouchableSurface(
      onPressed: onTap ?? () {},
      disabled: onTap == null,
      active: selected,
      autoFocus: false,
      builder: (context, status, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: radius, child: child),
            if (status.pressed || status.hovering)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.text.withValues(alpha: 0.08),
                  borderRadius: radius,
                ),
              ),
            if (status.focus)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: theme.primaryColor, width: 2),
                ),
              ),
          ],
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: theme.neutralShade(theme.isDark ? 2 : 1),
            child: _buildThumbnail(context, theme),
          ),
          if (asset.isVideo)
            Positioned(
              left: 6,
              bottom: 6,
              child: _DurationPill(duration: asset.duration),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: LdAttachmentSelectionBadge(
              selected: selected,
              index: selectionIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, LdTheme theme) {
    if (loading) {
      return const Center(child: LdLoader(size: 18));
    }
    final bytes = thumbnail;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackIcon(theme, asset.isVideo),
      );
    }
    return _fallbackIcon(theme, asset.isVideo);
  }

  Widget _fallbackIcon(LdTheme theme, bool video) {
    return Center(
      child: Icon(
        video ? LucideIcons.film : LucideIcons.image,
        color: theme.textMuted,
        size: 22,
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        ldFormatMediaDuration(duration),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

/// Formats a media duration as `m:ss` (or `h:mm:ss` for long videos).
String ldFormatMediaDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 1 << 31);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}
