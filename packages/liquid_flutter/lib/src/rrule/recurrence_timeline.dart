import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdRecurrenceTimelineEntry {
  const LdRecurrenceTimelineEntry({
    required this.date,
    required this.isLastOccurrence,
    this.connectorLabel,
  });

  final DateTime date;
  final bool isLastOccurrence;
  final String? connectorLabel;
}

List<LdRecurrenceTimelineEntry> ldRecurrenceTimelineEntries({
  required List<DateTime> occurrences,
  DateTime? last,
  required LiquidLocalizations l10n,
}) {
  if (occurrences.isEmpty && last == null) {
    return const [];
  }

  final lastIsSeparate = last != null && (occurrences.isEmpty || occurrences.last != last);
  final entries = <LdRecurrenceTimelineEntry>[];
  for (var index = 0; index < occurrences.length; index++) {
    final date = occurrences[index];
    final isLastNext = index == occurrences.length - 1;
    final connectorLabel = switch ((isLastNext, lastIsSeparate, isLastNext ? null : occurrences[index + 1])) {
      (false, _, final next) when next != null => ldRecurrenceDeltaLabel(date, next, l10n),
      (true, true, _) => '…',
      _ => null,
    };
    entries.add(
      LdRecurrenceTimelineEntry(
        date: date,
        isLastOccurrence: last != null && date == last,
        connectorLabel: connectorLabel,
      ),
    );
  }

  if (lastIsSeparate) {
    entries.add(
      LdRecurrenceTimelineEntry(
        date: last,
        isLastOccurrence: true,
      ),
    );
  }

  return entries;
}

class LdRecurrenceTimeline extends StatelessWidget {
  const LdRecurrenceTimeline({
    super.key,
    required this.entries,
    required this.dateFormat,
    required this.lastOccurrenceLabel,
  });

  final List<LdRecurrenceTimelineEntry> entries;
  final DateFormat dateFormat;
  final String lastOccurrenceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++)
          LdRecurrenceTimelineItem(
            entry: entries[index],
            dateFormat: dateFormat,
            lastOccurrenceLabel: lastOccurrenceLabel,
            isLastItem: index == entries.length - 1,
          ),
      ],
    );
  }
}

class LdRecurrenceTimelineItem extends StatelessWidget {
  const LdRecurrenceTimelineItem({
    super.key,
    required this.entry,
    required this.dateFormat,
    required this.lastOccurrenceLabel,
    required this.isLastItem,
  });

  final LdRecurrenceTimelineEntry entry;
  final DateFormat dateFormat;
  final String lastOccurrenceLabel;
  final bool isLastItem;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final dotColor = switch (entry.isLastOccurrence) {
      true => theme.primaryColor,
      false => theme.textMuted,
    };
    final caption = switch (entry.isLastOccurrence) {
      true => lastOccurrenceLabel,
      false => null,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              IconTheme(
                data: IconThemeData(
                  size: theme.paragraphSize(LdSize.s),
                  color: dotColor,
                ),
                child: Icon(
                  switch (entry.isLastOccurrence) {
                    true => LucideIcons.circleDot,
                    false => LucideIcons.circle,
                  },
                ),
              ),
              if (!isLastItem)
                Expanded(
                  child: VerticalDivider(
                    color: theme.border,
                    thickness: theme.borderWidth,
                    width: theme.paragraphSize(LdSize.s),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdText.l(dateFormat.format(entry.date)),
                if (caption != null) LdText.ls(caption),
                if (entry.connectorLabel != null)
                  LdMute(
                    child: LdText.ls(entry.connectorLabel!),
                  ),
              ],
            ).insetLeft(size: LdSize.s),
          ),
        ],
      ),
    );
  }
}
