import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vertical timeline of [LdTimelineItem]s with a rail and optional gap labels.
class LdTimeline extends StatelessWidget {
  const LdTimeline({
    super.key,
    required this.items,
  });

  final List<LdTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: items.map((item) => item.build(context)).toList(),
    );
  }
}

enum LdTimelineLineType { fadeStart, solid, fadeEnd, none, start, end }

/// A single rail row used by [LdTimeline] (and list builders that need one row).
class LdTimelineItem {
  const LdTimelineItem({
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

  Widget _fadeStart(BuildContext context) {
    final theme = LdTheme.of(context);
    return Container(
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
    );
  }

  Widget _solid(BuildContext context) {
    final theme = LdTheme.of(context);
    return VerticalDivider(
      color: theme.border,
      thickness: theme.borderWidth,
      width: theme.paragraphSize(LdSize.s),
    );
  }

  Widget _fadeEnd(BuildContext context) {
    final theme = LdTheme.of(context);
    return Container(
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
    );
  }

  TableRow build(BuildContext context) {
    final theme = LdTheme.of(context);
    final effectiveColor = color ?? theme.palette.neutral;
    final indicatorColor = effectiveColor.center(theme.isDark);
    final effectiveIcon = icon ?? LucideIcons.circleDot;

    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Column(
            children: [
              if (lineType == LdTimelineLineType.start) ldSpacerS,
              if (lineType != LdTimelineLineType.none && lineType != LdTimelineLineType.start)
                Expanded(
                  child: switch (lineType) {
                    LdTimelineLineType.fadeStart => _fadeStart(context),
                    _ => _solid(context),
                  },
                ),
              IconTheme(
                data: IconThemeData(
                  size: theme.paragraphSize(LdSize.s),
                  color: indicatorColor,
                ),
                child: Icon(
                  effectiveIcon,
                ),
              ),
              if (lineType != LdTimelineLineType.none && lineType != LdTimelineLineType.end && connectorLabel != null)
                Expanded(
                  child: _solid(context),
                ),
              if (connectorLabel != null)
                DefaultTextStyle(
                  style: ldBuildTextStyle(theme, LdTextType.label, LdSize.xs, color: theme.textMuted),
                  child: connectorLabel!,
                ),
              if (lineType != LdTimelineLineType.none && lineType != LdTimelineLineType.end)
                Expanded(
                  child: switch (lineType) {
                    LdTimelineLineType.fadeEnd => _fadeEnd(context),
                    _ => _solid(context),
                  },
                )
              else
                Spacer()
            ],
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ldSpacerXS,
              if (title != null) ...[
                DefaultTextStyle(
                  style: ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m),
                  textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                  child: title!,
                ),
                ldSpacerXS,
              ],
              DefaultTextStyle(
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.caption,
                  LdSize.s,
                  color: theme.textMuted,
                ),
                child: time,
              ),
              if (subtitle != null) ...[
                ldSpacerXS,
                DefaultTextStyle(
                  style: ldBuildTextStyle(
                    theme,
                    LdTextType.label,
                    LdSize.s,
                    color: theme.textMuted,
                  ),
                  child: subtitle!,
                ),
              ],
              if (subContent != null) ...[
                ldSpacerS,
                subContent!,
              ],
            ],
          ).insetLeft().insetBottom(),
        ),
      ],
    );
  }
}
