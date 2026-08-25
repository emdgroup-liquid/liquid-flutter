import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';

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

/// Occurrence preview timeline built on [LdTimeline].
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
    return LdTimeline(
      items: [
        for (final entry in entries)
          LdTimelineItem(
            time: Text(dateFormat.format(entry.date)),
            subtitle: switch (entry.isLastOccurrence) {
              true => Text(lastOccurrenceLabel),
              false => null,
            },
            lineType: switch (entry.isLastOccurrence) {
              true => LdTimelineLineType.none,
              false => entry == entries.last
                  ? LdTimelineLineType.fadeEnd
                  : (entry == entries[entries.length - 1] ? LdTimelineLineType.fadeEnd : LdTimelineLineType.solid)
            },
          )
      ],
    );
  }
}
