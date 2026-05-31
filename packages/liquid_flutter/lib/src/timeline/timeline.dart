import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Visual state of a single [LdTimeline] entry.
enum LdTimelineEntryState {
  past,
  completed,
  active,
  idle,
}

/// Base type for rows in an [LdTimeline].
sealed class LdTimelineItem {
  const LdTimelineItem();
}

/// One row in an [LdTimeline].
class LdTimelineEntry extends LdTimelineItem {
  const LdTimelineEntry({
    required this.title,
    required this.icon,
    required this.duration,
    this.subtitle,
    this.state = LdTimelineEntryState.idle,
    this.progress,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget icon;
  final Duration duration;
  final LdTimelineEntryState state;

  /// Share of this entry already completed, from `0` to `1`.
  ///
  /// When null and [LdTimeline.now] is set, progress for [LdTimelineEntryState.active]
  /// entries is derived from [now] within this entry's [duration].
  final double? progress;

  factory LdTimelineEntry.fromStrings({
    required String title,
    required Widget icon,
    required Duration duration,
    String? subtitle,
    LdTimelineEntryState state = LdTimelineEntryState.idle,
    double? progress,
    LdSize textSize = LdSize.m,
  }) {
    return LdTimelineEntry(
      title: LdText.l(title, size: textSize),
      subtitle: subtitle == null ? null : LdText.p(subtitle, size: LdSize.s),
      icon: icon,
      duration: duration,
      state: state,
      progress: progress,
    );
  }
}

/// A non-proportional break between timeline entries.
///
/// Renders a fixed-height dashed segment with muted duration text. [duration]
/// is used for labeling and [LdTimeline.now] positioning, not segment height.
class LdTimelineGap extends LdTimelineItem {
  const LdTimelineGap({
    required this.duration,
    this.label,
  });

  final Duration duration;

  /// When null, [duration] is formatted automatically.
  final Widget? label;
}

/// Vertical timeline with duration-proportional segment heights.
class LdTimeline extends StatelessWidget {
  const LdTimeline({
    required this.entries,
    super.key,
    this.minSegmentHeight,
    this.durationScale,
    this.gapHeight,
    this.gapSpacing,
    this.size = LdSize.m,
    this.now,
    this.nowLabel,
  });

  final List<LdTimelineItem> entries;
  final double? minSegmentHeight;
  final double? durationScale;

  /// Fixed height for [LdTimelineGap] segments (not scaled by [duration]).
  final double? gapHeight;

  /// Vertical space above and below each gap, separating it from adjacent entries.
  final double? gapSpacing;
  final LdSize size;

  /// Elapsed time from the start of the first entry. When set, a horizontal
  /// [now] indicator is drawn at the matching position along the timeline.
  final Duration? now;

  /// Optional label shown at the end of the [now] indicator row.
  final Widget? nowLabel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      assert(() {
        debugPrint('LdTimeline: entries must not be empty');
        return true;
      }());
      return const SizedBox.shrink();
    }

    final theme = LdTheme.of(context, listen: true);
    final minH = minSegmentHeight ?? theme.paddingSize(size: size) * 4;
    final scale = durationScale ?? theme.paddingSize(size: size) * 0.5;
    final gapH = gapHeight ?? theme.paddingSize(size: size) * 5;
    final gapSpace = gapSpacing ?? theme.paddingSize(size: size);
    final trackWidth = theme.paddingSize(size: size) * 3;
    final nodeSize = theme.paddingSize(size: size) * 3;

    final segmentHeights = [
      for (final item in entries)
        ldTimelineItemHeight(
          item,
          minSegmentHeight: minH,
          durationScale: scale,
          gapHeight: gapH,
          gapSpacing: gapSpace,
        ),
    ];

    final timeline = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          switch (entries[i]) {
            final LdTimelineEntry entry => _LdTimelineSegment(
                entry: entry,
                segmentKey: ValueKey('ld_timeline_segment_$i'),
                segmentHeight: segmentHeights[i],
                segmentProgress: ldTimelineSegmentProgress(
                  items: entries,
                  itemIndex: i,
                  now: now,
                ),
                isLast: i == entries.length - 1,
                size: size,
                trackWidth: trackWidth,
                theme: theme,
              ),
            final LdTimelineGap gap => _LdTimelineGapSegment(
                gap: gap,
                segmentKey: ValueKey('ld_timeline_gap_$i'),
                segmentHeight: segmentHeights[i],
                gapHeight: gapH,
                gapSpacing: gapSpace,
                size: size,
                trackWidth: trackWidth,
                theme: theme,
              ),
          },
      ],
    );

    if (now == null) {
      return timeline;
    }

    final nowOffset = ldTimelineNowOffset(
      entries,
      now!,
      segmentHeights: segmentHeights,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        timeline,
        Positioned(
          top: nowOffset,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: const Offset(0, -0.5),
            child: _LdTimelineNowIndicator(
              trackWidth: trackWidth,
              nodeSize: nodeSize,
              theme: theme,
              label: nowLabel,
            ),
          ),
        ),
      ],
    );
  }
}

/// Computes the height of one timeline row.
@visibleForTesting
double ldTimelineItemHeight(
  LdTimelineItem item, {
  required double minSegmentHeight,
  required double durationScale,
  required double gapHeight,
  double gapSpacing = 0,
}) {
  return switch (item) {
    LdTimelineEntry entry => ldTimelineSegmentHeight(
        entry,
        minSegmentHeight: minSegmentHeight,
        durationScale: durationScale,
      ),
    LdTimelineGap() => gapHeight + gapSpacing * 2,
  };
}

/// Computes the height of one timeline segment from its [duration].
@visibleForTesting
double ldTimelineSegmentHeight(
  LdTimelineEntry entry, {
  required double minSegmentHeight,
  required double durationScale,
}) {
  if (entry.duration <= Duration.zero) {
    return minSegmentHeight;
  }
  final seconds = entry.duration.inMilliseconds / 1000.0;
  return minSegmentHeight + seconds * durationScale;
}

/// Scheduled [Duration] of a timeline row (entry or gap).
@visibleForTesting
Duration ldTimelineItemDuration(LdTimelineItem item) {
  return switch (item) {
    LdTimelineEntry entry => entry.duration,
    LdTimelineGap gap => gap.duration,
  };
}

/// Total scheduled duration of all [items].
@visibleForTesting
Duration ldTimelineTotalDuration(List<LdTimelineItem> items) {
  var total = Duration.zero;
  for (final item in items) {
    final duration = ldTimelineItemDuration(item);
    if (duration > Duration.zero) {
      total += duration;
    }
  }
  return total;
}

/// Formats a [duration] for gap labels.
@visibleForTesting
String ldFormatTimelineDuration(Duration duration) {
  if (duration.inDays > 0) {
    final hours = duration.inHours.remainder(24);
    if (hours > 0) {
      return '${duration.inDays} d $hours h';
    }
    return '${duration.inDays} d';
  }
  if (duration.inHours > 0) {
    final minutes = duration.inMinutes.remainder(60);
    if (minutes > 0) {
      return '${duration.inHours} h $minutes min';
    }
    return '${duration.inHours} h';
  }
  if (duration.inMinutes > 0) {
    return '${duration.inMinutes} min';
  }
  if (duration.inSeconds > 0) {
    return '${duration.inSeconds} s';
  }
  return '0 min';
}

/// Vertical offset of the [now] indicator from the top of the timeline.
@visibleForTesting
double ldTimelineNowOffset(
  List<LdTimelineItem> items,
  Duration now, {
  required List<double> segmentHeights,
}) {
  if (items.isEmpty || segmentHeights.length != items.length) {
    return 0;
  }

  if (now <= Duration.zero) {
    return 0;
  }

  var elapsed = Duration.zero;
  var offset = 0.0;

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final segmentHeight = segmentHeights[i];
    final segmentDuration = ldTimelineItemDuration(item);

    if (segmentDuration <= Duration.zero) {
      if (now <= elapsed) {
        return offset;
      }
      offset += segmentHeight;
      continue;
    }

    final segmentEnd = elapsed + segmentDuration;
    if (now < segmentEnd) {
      final progress =
          (now.inMilliseconds - elapsed.inMilliseconds) / segmentDuration.inMilliseconds;
      return offset + progress.clamp(0.0, 1.0) * segmentHeight;
    }

    elapsed = segmentEnd;
    offset += segmentHeight;
  }

  return offset;
}

/// Progress through an active segment, or null when not shown.
@visibleForTesting
double? ldTimelineSegmentProgress({
  required List<LdTimelineItem> items,
  required int itemIndex,
  Duration? now,
}) {
  if (itemIndex < 0 || itemIndex >= items.length) {
    return null;
  }

  final item = items[itemIndex];
  if (item is! LdTimelineEntry) {
    return null;
  }

  final entry = item;

  if (entry.progress != null) {
    if (entry.state != LdTimelineEntryState.active) {
      return null;
    }
    return entry.progress!.clamp(0.0, 1.0);
  }

  if (now == null || entry.state != LdTimelineEntryState.active) {
    return null;
  }

  var elapsed = Duration.zero;
  for (var i = 0; i < itemIndex; i++) {
    final duration = ldTimelineItemDuration(items[i]);
    if (duration > Duration.zero) {
      elapsed += duration;
    }
  }

  final segmentDuration = entry.duration;
  if (segmentDuration <= Duration.zero) {
    return null;
  }

  if (now <= elapsed) {
    return 0;
  }

  final segmentEnd = elapsed + segmentDuration;
  if (now >= segmentEnd) {
    return 1;
  }

  return (now.inMilliseconds - elapsed.inMilliseconds) / segmentDuration.inMilliseconds;
}

class _TimelineStyle {
  const _TimelineStyle({
    required this.nodeFill,
    required this.nodeBorder,
    required this.nodeBorderWidth,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.connectorColor,
    required this.muteTitle,
  });

  final Color nodeFill;
  final Color nodeBorder;
  final double nodeBorderWidth;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color connectorColor;
  final bool muteTitle;

  factory _TimelineStyle.fromState(LdTimelineEntryState state, LdTheme theme) {
    return switch (state) {
      LdTimelineEntryState.past => _TimelineStyle(
          nodeFill: theme.neutralShade(2),
          nodeBorder: theme.neutralShade(4),
          nodeBorderWidth: theme.borderWidth,
          iconColor: theme.textMuted,
          titleColor: theme.textMuted,
          subtitleColor: theme.textMuted,
          connectorColor: theme.textMuted,
          muteTitle: true,
        ),
      LdTimelineEntryState.completed => _TimelineStyle(
          nodeFill: theme.successColor.withAlpha(38),
          nodeBorder: theme.successColor,
          nodeBorderWidth: theme.borderWidth,
          iconColor: theme.successColor,
          titleColor: theme.text,
          subtitleColor: theme.textMuted,
          connectorColor: theme.successColor,
          muteTitle: false,
        ),
      LdTimelineEntryState.active => _TimelineStyle(
          nodeFill: theme.primaryColor.withAlpha(38),
          nodeBorder: theme.primaryColor,
          nodeBorderWidth: theme.borderWidth * 2,
          iconColor: theme.primaryColor,
          titleColor: theme.text,
          subtitleColor: theme.textMuted,
          connectorColor: theme.primaryColor,
          muteTitle: false,
        ),
      LdTimelineEntryState.idle => _TimelineStyle(
          nodeFill: theme.surface,
          nodeBorder: theme.border,
          nodeBorderWidth: theme.borderWidth,
          iconColor: theme.textMuted,
          titleColor: theme.textMuted,
          subtitleColor: theme.textMuted,
          connectorColor: theme.border,
          muteTitle: false,
        ),
    };
  }
}

class _LdTimelineNowIndicator extends StatelessWidget {
  const _LdTimelineNowIndicator({
    required this.trackWidth,
    required this.nodeSize,
    required this.theme,
    this.label,
  });

  final double trackWidth;
  final double nodeSize;
  final LdTheme theme;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final lineHeight = theme.borderWidth * 2;
    final dotSize = nodeSize * 0.4;
    final labelStyle = ldBuildTextStyle(
      theme,
      LdTextType.label,
      LdSize.s,
      color: theme.primaryColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: trackWidth,
          child: Center(
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.background,
                  width: theme.borderWidth * 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withAlpha(64),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        ldHSpacerM,
        Expanded(
          child: Container(
            height: lineHeight,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: theme.radius(LdSize.xs),
            ),
          ),
        ),
        if (label != null) ...[
          ldHSpacerS,
          DefaultTextStyle(
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: label!,
          ),
        ],
      ],
    );
  }
}

class _LdTimelineGapSegment extends StatelessWidget {
  const _LdTimelineGapSegment({
    required this.gap,
    required this.segmentHeight,
    required this.gapHeight,
    required this.gapSpacing,
    required this.size,
    required this.trackWidth,
    required this.theme,
    this.segmentKey,
  });

  final LdTimelineGap gap;
  final double segmentHeight;
  final double gapHeight;
  final double gapSpacing;
  final LdSize size;
  final double trackWidth;
  final LdTheme theme;
  final Key? segmentKey;

  @override
  Widget build(BuildContext context) {
    final lineWidth = theme.borderWidth * 2;
    final label = gap.label ??
        LdText.p(
          ldFormatTimelineDuration(gap.duration),
          size: LdSize.s,
        );

    final gapContent = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: trackWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: theme.paddingSize(size: LdSize.xs) / 2,
            ),
            child: _DashedVerticalLine(
              color: theme.textMuted,
              width: lineWidth,
            ),
          ),
        ),
        ldHSpacerM,
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: LdMute(child: label),
          ),
        ),
      ],
    );

    return SizedBox(
      key: segmentKey,
      height: segmentHeight,
      child: Column(
        children: [
          SizedBox(height: gapSpacing),
          SizedBox(
            height: gapHeight,
            child: gapContent,
          ),
          SizedBox(height: gapSpacing),
        ],
      ),
    );
  }
}

class _DashedVerticalLine extends StatelessWidget {
  const _DashedVerticalLine({
    required this.color,
    required this.width,
  });

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedVerticalLinePainter(
        color: color,
        strokeWidth: width,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DashedVerticalLinePainter extends CustomPainter {
  _DashedVerticalLinePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 4.0;
    const gapLength = 4.0;
    final x = size.width / 2;
    var y = 0.0;

    while (y < size.height) {
      final endY = math.min(y + dashLength, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, endY), paint);
      y += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _LdTimelineSegment extends StatelessWidget {
  const _LdTimelineSegment({
    required this.entry,
    required this.segmentHeight,
    required this.isLast,
    required this.size,
    required this.trackWidth,
    required this.theme,
    this.segmentKey,
    this.segmentProgress,
  });

  final LdTimelineEntry entry;
  final double segmentHeight;
  final bool isLast;
  final LdSize size;
  final double trackWidth;
  final LdTheme theme;
  final Key? segmentKey;
  final double? segmentProgress;

  @override
  Widget build(BuildContext context) {
    final style = _TimelineStyle.fromState(entry.state, theme);
    final nodeSize = theme.paddingSize(size: size) * 3;

    final title = DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.label,
        size,
        color: style.titleColor,
      ),
      child: entry.title,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        style.muteTitle ? LdMute(child: title) : title,
        if (entry.subtitle != null) ...[
          ldVSpacerXS,
          DefaultTextStyle(
            style: ldBuildTextStyle(
              theme,
              LdTextType.paragraph,
              LdSize.s,
              color: style.subtitleColor,
              lineHeight: 1.5,
            ),
            child: entry.subtitle!,
          ),
        ],
      ],
    );

    return SizedBox(
      key: segmentKey,
      height: segmentHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: trackWidth,
            child: Column(
              children: [
                _TimelineNode(
                  icon: entry.icon,
                  nodeSize: nodeSize,
                  style: style,
                ),
                if (!isLast)
                  Expanded(
                    child: _TimelineConnector(
                      color: style.connectorColor,
                      progress: segmentProgress,
                      progressColor: theme.primaryColor,
                      trackColor: theme.border,
                      theme: theme,
                    ),
                  ),
              ],
            ),
          ),
          ldHSpacerM,
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.icon,
    required this.nodeSize,
    required this.style,
  });

  final Widget icon;
  final double nodeSize;
  final _TimelineStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        color: style.nodeFill,
        shape: BoxShape.circle,
        border: Border.all(
          color: style.nodeBorder,
          width: style.nodeBorderWidth,
        ),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: style.iconColor,
            size: nodeSize * 0.45,
          ),
          child: icon,
        ),
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({
    required this.color,
    required this.theme,
    this.progress,
    this.progressColor,
    this.trackColor,
  });

  final Color color;
  final LdTheme theme;
  final double? progress;
  final Color? progressColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final lineWidth = theme.borderWidth * 2;
    final padding = EdgeInsets.symmetric(vertical: theme.paddingSize(size: LdSize.xs) / 2);

    Widget line(Color lineColor) {
      return Center(
        child: Container(
          width: lineWidth,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: theme.radius(LdSize.xs),
          ),
        ),
      );
    }

    if (progress == null) {
      return Padding(
        padding: padding,
        child: line(color),
      );
    }

    final completedFlex = (progress!.clamp(0.0, 1.0) * 1000).round().clamp(1, 1000);
    final remainingFlex = (1000 - completedFlex).clamp(1, 1000);
    final doneColor = progressColor ?? color;
    final pendingColor = trackColor ?? color.withAlpha(64);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Expanded(
            flex: completedFlex,
            child: line(doneColor),
          ),
          Expanded(
            flex: remainingFlex,
            child: line(pendingColor),
          ),
        ],
      ),
    );
  }
}
