import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Visual weight of the rail indicator on an [LdTimelineItem].
enum LdTimelineIndicator {
  /// Outline circle (default).
  circle,

  /// Filled emphasis circle (e.g. a terminal / highlighted step).
  circleDot,
}

/// Vertical timeline of [LdTimelineEntry]s with a rail and optional gap labels.
class LdTimeline extends StatelessWidget {
  const LdTimeline({
    super.key,
    required this.items,
  });

  final List<LdTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...items],
    );
  }
}

enum LdTimelineLineType { fadeStart, solid, fadeEnd, none }

/// A single rail row used by [LdTimeline] (and list builders that need one row).
class LdTimelineItem extends StatelessWidget {
  const LdTimelineItem({
    super.key,
    this.title,
    required this.time,
    this.subtitle,
    this.subContent,
    this.connectorLabel,
    this.icon,
    this.color,
    this.lineType = LdTimelineLineType.solid,
  });

  final LdColor? color;
  final IconData? icon;
  final Widget? title;
  final LdTimelineLineType lineType;
  final Widget time;
  final Widget? subtitle;
  final Widget? subContent;
  final Widget? connectorLabel;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final effectiveColor = color ?? theme.palette.neutral;
    final indicatorColor = effectiveColor.center(theme.isDark);
    final effectiveIcon = icon ?? LucideIcons.circleDot;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              IconTheme(
                data: IconThemeData(
                  size: theme.paragraphSize(LdSize.s),
                  color: indicatorColor,
                ),
                child: Icon(
                  effectiveIcon,
                ),
              ),
              Expanded(
                child: switch (lineType) {
                  LdTimelineLineType.fadeStart => Container(
                      width: theme.borderWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.border.withAlpha(0),
                            theme.border,
                          ],
                          stops: [0, 0.2],
                        ),
                      ),
                    ),
                  LdTimelineLineType.solid => VerticalDivider(
                      color: theme.border,
                      thickness: theme.borderWidth,
                      width: theme.paragraphSize(LdSize.s),
                    ),
                  LdTimelineLineType.fadeEnd => Container(
                      width: theme.borderWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.border,
                            theme.border.withAlpha(0),
                          ],
                          stops: [0.2, 1],
                        ),
                      ),
                    ),
                  LdTimelineLineType.none => SizedBox.shrink(),
                },
              ),
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.caption,
                  LdSize.m,
                  color: theme.textMuted,
                ),
                child: time,
              ),
              if (title != null)
                DefaultTextStyle(
                  style: ldBuildTextStyle(theme, LdTextType.label, LdSize.m),
                  child: title!,
                ),
              ldSpacerXS,
              if (subtitle != null)
                DefaultTextStyle(
                  style: ldBuildTextStyle(
                    theme,
                    LdTextType.label,
                    LdSize.s,
                    color: theme.textMuted,
                  ),
                  child: subtitle!,
                ),
              if (subContent != null) subContent!,
              ldSpacerS,
            ],
          )),
        ],
      ).spaceS(),
    );
  }
}
